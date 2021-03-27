function resampledDataStruct = resampleSingleElementsData(spatialScale, ...
    ageScale, dataCSV, elementsMap, resampleOptions, bMin, bMax, nBins, ...
    createPlots, outputDirectory)
    % Here, we load in a dataset, calculate weights for a given age and
    % spatial scale, resample chosenElements, and return the results as a
    % structure
    % Example:
    % resampledDataStruct = resampleSingleElementsData(0.5, ...
    %   10, '0_data_files/filteredSGP.csv', ["Age", "CaO"], 0, 1200, 40, true);
    close all
    % First, let's import the dataset
    dataset = importGeochemCSV(dataCSV);
    % Next, let's generate weights based the ageScale and spatialScale
    tic
    weights = invWeight(dataset.Latitude, dataset.Longitude, dataset.Age, ...
        2, spatialScale, ageScale);
    probs = normalizeWeights(weights, 0.2);
    disp(strcat("Weights calculated. " , num2str(toc), " seconds elapsed."));
    % Check for an "age" element in elementsMap
    if ~isKey(elementsMap,'Age')
        % Also add to elementsMap
        elementsMap = modifyElementsMap(elementsMap, ["Age"]);
    end
    % Now, generate errors
    errors = generateErrors(dataset, elementsMap);
    disp(strcat("Errors generated. " , num2str(toc), " seconds elapsed."));
    % Cull the dataset, to match the errors
    culledDataset = cullDataset(dataset, elementsMap);
    disp(strcat("Dataset culled. " , num2str(toc), " seconds elapsed."));
    [numSamples,  ~] = calculateSamplesElements(dataset, elementsMap);
    % Prepare the elementsStruct
    elementsStruct = struct();
    elementsStruct.elementsMap = elementsMap;
    % Awesome, let's now resample
    [resampledAndBinned, elementsStruct] = meansStds(culledDataset, numSamples, 1e4, ...
            elementsStruct, probs, errors, ...
            bMin, bMax, nBins, resampleOptions);
    disp(strcat("Resampled. " , num2str(toc), " seconds elapsed."));
    % Let's plot
    if createPlots
        plotAllResampledElements(culledDataset, resampledAndBinned, elementsStruct, "Age", ...
            bMin, bMax, nBins, outputDirectory)
    end
    % Alright, let's return a structure
    resampledDataStruct = struct();
    resampledDataStruct.resampledAndBinned = resampledAndBinned;
    resampledDataStruct.elementsStruct = elementsStruct;
end