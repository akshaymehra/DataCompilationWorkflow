function [weightsStruct, resampledStruct] = resampleDataUsingSensitivityTests(dataCSV, ...
    sensitivitySpatialScales, sensitivityAgeScales, outputDirectory,...
    overwriteResults)
    close all
    % sensitivitySpatialScales = logspace(log10(0.5), log10(180), 25);
    % sensitivityAgeScales = logspace(log10(10), log10(1000), 25);
    % dataDir = './0_data_files/matlabParsing';
    % outputDirectory = 'outputs/sensitivities';
    % overwriteResults = true;
    % finalFiltered = fullfile(dataDir, '8.shalesFinalFilteredUSGSCutoffs.csv');
    % [weightsStruct, resampledStruct] = resampleDataUsingSensitivityTests(finalFiltered, ...
    % sensitivitySpatialScales, sensitivityAgeScales, outputDirectory,...
    % overwriteResults);
    % Let's begin by loading in the CSV...we use readtable to do so
    sgp = importGeochemCSV(dataCSV);
    % Now, should we run sensitivity tests?
    % First, let's look for the weights and resampled files
    weightsFile = fullfile(outputDirectory, "weightsStruct.mat");
    resampledFile = fullfile(outputDirectory, "resampledStruct.mat");
    % Let's plot out the spatial and age scale histograms
    plotSpatialAndAgeHistograms(sensitivitySpatialScales,...
        sensitivityAgeScales, 5);
    % Begin with weighting
    if overwriteResults || ~isfile(weightsFile)
        weightsStruct = sensitivityWeightsCollector(sgp,...
            sensitivitySpatialScales, sensitivityAgeScales, weightsFile);
    else
        load(weightsFile, "weightsStruct");
    end
    % Oh! we want to plot weights
    plotWeightsAndProbs(weightsStruct, [0.5, 10], 100, outputDirectory);
    % Now, let's move on to resampling
    if overwriteResults || ~isfile(resampledFile)
        % Which elements are we resampling?
        elementsMap = createElementsMap(["Age", "Al2O3", "CaO", "TIC", "P2O5", "MgO", ...
            "Nd", "Sm", "Gd", "Tb", "Na2O", "K2O", "U", "Ca", "Cr", "Fe", "Al"]);
        resampledStruct = resampleUsingWeights(sgp, weightsStruct, ...
             elementsMap, 1e3, resampledFile);
    else
        load(resampledFile, "resampledStruct");
    end
    % Okay, now, let's go ahead and plot the results of resampling with
    % respect to different age and spatial scales
    plotResampledData(weightsStruct, resampledStruct, outputDirectory);
end

function weightsStruct = sensitivityWeightsCollector(dataset ,...
            spatialScales, ageScales, outputFile)
    % How many to process?
    numSpace = length(spatialScales);
    numAge = length(ageScales);
    % We start with a nice little structure
    weightsStruct = struct();
    % Create some collectors, which we'll drop into weights eventually
    scalesSpace = zeros(numSpace, numAge);
    scalesAge = zeros(numSpace, numAge);
    weights = cell(numSpace, numAge);
    probs = cell(numSpace, numAge);
    % So, for each spatial and age scale, we want to calculate some weights
    % To speed up the par for loop, we're going to explicitly decalre
    % latitude, longitude, and age from the databse
    lat = dataset.("Latitude");
    lng = dataset.("Longitude");
    age = dataset.("Age");
    % Start up a parallel wait bar
    [dataQueue, bar] = startParallelWaitbar(numSpace * numAge);
    tic
    parfor y = 1:numSpace
        for x = 1:numAge
            tic
            % First, let's calculate the weights
            weights{y, x} = invWeight(lat, lng, age, 2, ...
                spatialScales(y), ageScales(x));
            % Then, let's figure out the normalized weights, reported here
            % as probablities
            probs{y, x} = normalizeWeights(weights{y, x}, .2);
            scalesSpace(y, x) = spatialScales(y);
            scalesAge(y, x) = ageScales(x);
            elapsed = toc;
            disp(strcat("Spatial scale: ", num2str(spatialScales(y)), " and Age scale: ", ...
                num2str(ageScales(x)), " processed. ", num2str(elapsed), ...
                " seconds elapsed."));
            send(dataQueue, "updated");
        end
    end
    toc
    % Let's store and save the weights
    weightsStruct.spatialScales = scalesSpace;
    weightsStruct.ageScales = scalesAge;
    weightsStruct.weights = weights;
    weightsStruct.probs = probs;
    save(outputFile, 'weightsStruct'); 
    close(bar);
end


function [resampledStruct] = resampleUsingWeights(dataset, weightsStruct, ...
    elementsMap, numReplicates, outputFile)
    % Okay, we're going to want to resample here
    % But first, let's calculate errors
    errors = generateErrors(dataset, elementsMap);
    % Now, we have errors, we'll want to run through every combination of
    % spatial and age scale
    numToProcess = numel(weightsStruct.spatialScales);
    % Let's also limit the dataset
    culledDataset = cullDataset(dataset, elementsMap);
    % Okay, let's pass in an elementsStruct, with the only field being
    % elementsMap
    elementsStruct = struct();
    elementsStruct.elementsMap = elementsMap;
    % Finally, how many to process?
    [numSamples,  ~] = calculateSamplesElements(dataset, elementsMap);
    resampledAndBinned = cell(size(weightsStruct.ageScales));
    [dataQueue, bar] = startParallelWaitbar(numToProcess);
    for y = 1:numToProcess
        tic
        % We're going to resample each combination, bin the outcomes,
        % calculate means and stds, and repeat for n number of replicates.
        % Finally, we're going to calculate a mean and std of means for 
        % bin and store it.
        % Note that we set bMin, bMax, and nBins here
        bMin = 0;
        bMax = 4020;
        bSpacing = 30;
        nBins = (bMax - bMin)/bSpacing;
        [outResampledAndBinned, outElementsStruct] = meansStds(culledDataset, numSamples, numReplicates, ...
            elementsStruct, weightsStruct.probs{y}, errors, ...
            bMin, bMax, nBins, ["ciaCalcs"]);
        resampledAndBinned{y} = outResampledAndBinned;
        elapsed = toc;
        disp(strcat("Age and spatial combination resampled. ", ...
            num2str(elapsed), " seconds elapsed."));
        % Now, if this is the last iteration, update elements struct
        if y == numToProcess
            elementsStruct = outElementsStruct;
        end
        send(dataQueue, "updated");
    end
    close(bar);
    resampledStruct.resampledAndBinned = resampledAndBinned;
    resampledStruct.elementsStruct = elementsStruct;
    save(outputFile, 'resampledStruct');
end

function plotWeightsAndProbs(weightsStruct, spaceAndAge, plotMultiple, outputDirectory)
    % Weights to plot
    % First, find the index of the value you want
    spaceIdxs = find(weightsStruct.spatialScales == spaceAndAge(1));
    agesIdxs = find(weightsStruct.ageScales == spaceAndAge(2));
    % Okay, which idx is common to both?
    toPlotIdx = intersect(spaceIdxs, agesIdxs);
    weightsToPlot = weightsStruct.("weights"){toPlotIdx};
    % Get the maximum x value, in 100s
    maxXValue = limMax(weightsToPlot, plotMultiple);
    % Now, let's create a new figure
    figure;
    weightsHist = histogram(weightsToPlot, 0:plotMultiple:maxXValue,...
        'DisplayStyle', 'stairs', 'EdgeColor', 'black');
    ylim([0, limMax(weightsHist.Values, plotMultiple)]);
    xlim([0, maxXValue]);
    xlabel("Weight value");
    ylabel("Count");
    grid on
    pbaspect([1 1 1]);
    print(fullfile(outputDirectory, 'originalWeights'), '-painters', '-dpdf');
    % Another figure
    figure;
    probHist = histogram(weightsStruct.("probs"){toPlotIdx}, 0:0.05:1,...
        'DisplayStyle', 'stairs', 'EdgeColor', 'black');
    ylim([0, limMax(probHist.Values, plotMultiple)]);
    xlim([0, 1]);
    xlabel("Probability value");
    ylabel("Count");
    pbaspect([1,1,1]);
    grid on
    hold on
    % Plot the median value
    medianProbValue = nanmedian(weightsStruct.("probs"){toPlotIdx});
    line([medianProbValue, medianProbValue], ylim);
    % Add median value to the plot
    medianText = text(medianProbValue, 0.5 * sum(ylim), num2str(medianProbValue));
    set(medianText, 'Rotation', 90);
    print(fullfile(outputDirectory, 'rescaledProbabilities'), '-painters', '-dpdf');
end

function plotSpatialAndAgeHistograms(space, age, nBins)
    % Simple function, returns histogram plots of spatial and age values
    % Start by merging the two into a cell array
    toPlot = {space, age};
    toPlotTitles = {'Spatial Values', 'Age Values'};
    for x = 1:2
        figure;
        thisHist = histogram(toPlot{x}, nBins,...
        'DisplayStyle', 'stairs', 'EdgeColor', 'black');
        ylim([0, limMax(thisHist.Values, 10)]);
        xlim([0, limMax(max(toPlot{x}), 10)]);
        xlabel("Value");
        ylabel("Count");
        pbaspect([1,1,1]);
        title(toPlotTitles{x});
        grid on
    end
end

function plotResampledData(weightsStruct, resampledStruct, outputDirectory)
    % Simple plot, for CIA*_approx through time, let's plot up all the
    % options
    plotElement(resampledStruct, "CIAUncorr", outputDirectory);
    plotElement(resampledStruct, "CIAStarApprox", outputDirectory);
    plotElement(resampledStruct, "CIAStar", outputDirectory);
    plotElement(resampledStruct, "WIP", outputDirectory);
    plotElement(resampledStruct, "U", outputDirectory);
    plotElement(resampledStruct, "Al2O3", outputDirectory);
    plotElement(resampledStruct, "Fe", outputDirectory);
    plotSingleElementVariation(weightsStruct, resampledStruct, "U", 525, outputDirectory);
end

function plotElement(resampledStruct, element, outputDirectory)
    colSpec = resampledStruct.elementsStruct.elementsMap(element);
    % Min and Max collector
    maxEnvelope = nan(size(resampledStruct.resampledAndBinned{1}{2}(:, colSpec)));
    minEnvelope = maxEnvelope; 
    numToProcess = numel(resampledStruct.resampledAndBinned);
    figure;
    hold on
    for x = 1:numToProcess
        % This means
        thisMeans = resampledStruct.resampledAndBinned{x}{2}(:, colSpec);
        thisErrors = resampledStruct.resampledAndBinned{x}{3}(:, colSpec);
        thisMeansUpper = thisMeans + thisErrors;
        thisMeansLower = thisMeans - thisErrors;
        % If thisMeansLower is less than 0, set to 0
        thisMeansLower(thisMeansLower < 0) = 0;
        % Okay, take the max of maxEnvelope or thisMeansUpper
        maxEnvelope = nanmax(maxEnvelope, thisMeansUpper);
        minEnvelope = nanmin(minEnvelope, thisMeansLower);
        thisBinsCenters =  resampledStruct.resampledAndBinned{x}{1};
        plot(thisBinsCenters, thisMeans, 'color', [0.5,0.5,0.5, 0.05]);
        % Okay, if this is the last run
        if x == numToProcess
            plot(thisBinsCenters, maxEnvelope, 'color', 'black');
            plot(thisBinsCenters, minEnvelope, 'color', 'black');
        end
    end
    pbaspect([4,1,1]);
    grid on
    xlabel("Age (Ma)");
    xlim([min(thisBinsCenters), max(thisBinsCenters)]);
    ylabel("Value");
    set (gca, 'xdir', 'reverse');
    title(element, 'interpreter', 'none');
    print(fullfile(outputDirectory, rectifyFilename(strcat(element, 'Resampled'))), '-painters', '-dpdf');
end

function plotSingleElementVariation(weightsStruct, resampledStruct, element, ...
    timeBin, outputDirectory)
    colSpec = resampledStruct.elementsStruct.elementsMap(element);
    whichTimeIdx = find(resampledStruct.resampledAndBinned{1}{1} == timeBin);
    if ~isempty(whichTimeIdx)
        collector = zeros(size(weightsStruct.ageScales));
        for x = 1:numel(collector)
            collector(x) = ...
                resampledStruct.resampledAndBinned{x}{2}(whichTimeIdx, colSpec);
        end
        timeMean = nanmean(collector(:));
        vsMean = timeMean - collector;
        percentVs = (vsMean / timeMean) * 100;
        figure
        heatmap(weightsStruct.ageScales(1, :), ...
            weightsStruct.spatialScales(:, 1), percentVs, 'Colormap', jet);
        ylabel("Spatial Scale");
        xlabel("Age Scale")
        title(strcat(element, " Variation at ", num2str(timeBin), " Ma"));
        print(fullfile(outputDirectory, rectifyFilename(strcat(element, 'Variation'))), '-painters', '-dpdf');
    else
        disp("No matching time bin found!");
    end
end