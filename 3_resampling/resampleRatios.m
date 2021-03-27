function resampledDataStruct = resampleRatios(spatialScale, ...
    ageScale, dataCSV, numeratorElements, denominatorElements, ...
    bMin, bMax, nBins, createPlots, outputDirectory)
    % Here, we load in a dataset, calculate weights for a given age and
    % spatial scale, resample numerator and denominator elements, compute 
    % a ratio, and return the results as a structure
    close all
    % Ensure that the number of numerators matches the number of
    % denominators
    numNumerator = length(numeratorElements);
    numDenominator = length(denominatorElements);
    if numNumerator ~= numDenominator
        error("Numerator and denominator arrays must have the same size!");
    end
    % First, let's import the dataset
    dataset = importGeochemCSV(dataCSV);
    % Next, let's generate weights based the ageScale and spatialScale
    tic
    weights = invWeight(dataset.Latitude, dataset.Longitude, dataset.Age, ...
        2, spatialScale, ageScale);
    probs = normalizeWeights(weights, 0.2);
    disp(strcat("Weights calculated. " , num2str(toc), " seconds elapsed."));
    % Okay, now, we want to create a map of elements
    % Begin by creating a colllection of elements, including age, and any
    % unique elements in the numerator and denominator
    allElements = unique(["Age", numeratorElements, denominatorElements]);
    elementsMap = createElementsMap(allElements);
    % Now, generate errors
    errors = generateErrors(dataset, elementsMap);
    disp(strcat("Errors generated. " , num2str(toc), " seconds elapsed."));
    % Cull the dataset, to match the errors
    culledDataset = cullDataset(dataset, elementsMap);
    disp(strcat("Dataset culled. " , num2str(toc), " seconds elapsed."));
    % Finally, let's create a structure
    elementsStruct = struct();
    elementsStruct.elementsMap = elementsMap;
    elementsStruct.numeratorElements = numeratorElements;
    elementsStruct.denominatorElements = denominatorElements;
    
    [numSamples,  ~] = calculateSamplesElements(dataset, elementsMap);
    [resampledAndBinned, elementsStruct] = meansStds(culledDataset, numSamples, 1e4, ...
            elementsStruct, probs, errors, ...
            bMin, bMax, nBins, ["ratios"]);
    disp(strcat("Resampled. " , num2str(toc), " seconds elapsed."));
        
    % Now, let's go ahead and plot
    if createPlots
        % We only want to plot the ratios
        ratioStrings = generateRatioStrings(elementsStruct);
        for x = 1:length(ratioStrings)
            thisElementCol = elementsStruct.elementsMap(ratioStrings(x));
            figure
            errorbar(resampledAndBinned{1}, resampledAndBinned{2}(:, thisElementCol), ...
                resampledAndBinned{2}(:, thisElementCol) - resampledAndBinned{5}(:, thisElementCol), ...
                resampledAndBinned{4}(:, thisElementCol) - resampledAndBinned{2}(:, thisElementCol), ...
                'o', 'color', 'black');
            hold on
            plot(resampledAndBinned{1}, resampledAndBinned{2}(:, thisElementCol), 'color', ...
                'red');
            pbaspect([2,1,1]);
            grid on
            title(strcat(ratioStrings(x), " through time"));
            ylabel("Value");
            xlabel("Time (Ma)");
            % Flip x-axis direction
            set(gca, 'XDir','reverse');
            % Write this to file
            print(fullfile(outputDirectory, ...
                rectifyFilename(strcat(ratioStrings(x), 'Resampled'))), '-painters', '-dpdf');
        end
    end
    
    % Alright, let's return a structure
    resampledDataStruct = struct();
    resampledDataStruct.resampledAndBinned = resampledAndBinned;
    resampledDataStruct.elementsStruct = elementsStruct;
end