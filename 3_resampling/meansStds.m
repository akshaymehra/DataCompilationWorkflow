function [resampledAndBinned, elementsStruct] = meansStds(dataset, numDraws, numReplicates, ...
            elementsStruct, probs, errors, bMin, bMax, ...
            nBins, runOptions)
    % Note that runOptions is a matrix that includes zero or more of 
    % the following strings:
    % a. "ciaCalcs": calculate CIA and return means that include CIA values
    % b. "ratios": calculate ratios -- elementsStruct must include
    % "numeratorElements" and "denominatorElements" fields
    % c. "returnAllResampled": returns all resampled data, unbinned
    % If runOptions is empty, we add an empty string
    if isempty(runOptions)
        runOptions = "";
    end
    % Note that meansStds will always assume that you want single elements
    % resampled, binned, and meaned.
    % To make life easier, we'll pull out elementsMap
    % We'll do it by making a copy, so as to keep the object from being
    % updated elsewhere
    elementsMap = containers.Map(elementsStruct.elementsMap.keys, ...
        elementsStruct.elementsMap.values); 
    % 1. We want to prepare for run time
    % 1a. First, we'll preallocate storage arrays
    % Bin centers depends entirely on nBins and numReplicates
    binCenters = zeros(nBins, numReplicates);
    % Next, we need to know--how many elements?
    % Essentially, we add additional columns to the resampled dataset if
    % and when we invoke runOptions
    % We'll add these columns by modifying elementsMap and then calculating
    % its length
    if ismember("ciaCalcs", runOptions)
        calcsToAdd = ["CaOStar", "CaOStarApprox", "CaOStarHybrid", "CIAUncorr", "CIAStar", "CIAStarApprox", "CIAStarHybrid", "WIP"];
        elementsMap = modifyElementsMap(elementsMap, calcsToAdd);
    elseif ismember("ratios", runOptions)
        ratioStrings = generateRatioStrings(elementsStruct);
        elementsMap = modifyElementsMap(elementsMap, ratioStrings);
    end
    numElements = length(elementsMap);
    % Finally, let's set up binMeans
    binMeans = nan(nBins, numElements, numReplicates);
    % Fold elementsMap back into elementsStruct
    elementsStruct.elementsMap = elementsMap;
    % Some more things to create 
    % If "returnAllResampled" was chosen
    if ismember("returnAllResampled", runOptions)
        allResampled = nan(numDraws, numElements, numReplicates);
    end
    % If "returnSampleIDs" was chosen
    if ismember("returnSampleIDs", runOptions)
        allSampleIDs = nan(numDraws, 1, numReplicates);
    end
    % We want to count how many non nan values are in each bin, per element
    binCounts = zeros(nBins, numElements, numReplicates);
    % Okay, now we resample
    parfor rep = 1:numReplicates
        % Begin by resampling data
        [resampledData, sampledIDs] = bsresample(dataset, numDraws, ...
            probs, errors);
        % Add to resampledData if necessary
        colsToAdd = numElements - size(resampledData, 2);
        if colsToAdd > 0
            dataToAdd = nan(size(resampledData, 1), colsToAdd);
            % Now add
            resampledData = [resampledData, dataToAdd];
        end
        if ismember("ciaCalcs", runOptions)
            resampledData = ciaCalcs(resampledData, elementsStruct);
        end
        if ismember("ratios", runOptions)
            resampledData = ratioCalcs(resampledData, elementsStruct);
        end
        if ismember("returnAllResampled", runOptions)
            allResampled(:,:,rep) = resampledData;
        end
        if ismember("returnSampleIDs", runOptions)
            allSampleIDs(:,:,rep) = sampledIDs;
        end
        % Great! Let's now calculate some binned means
        % Note that we'll calculate the errors of the means, so there's no
        % need to return that thisBinErrors
        [thisBinCenters, thisBinMeans, ~, thisCounts] = calcBinMeans(resampledData(:, ...
            elementsStruct.elementsMap("Age")), resampledData, bMin, bMax, nBins, 1);
        % Time to store...
        binCenters(:, rep) = thisBinCenters;
        binMeans(:, :, rep) = thisBinMeans;
        % Add to counts
        binCounts(:, :, rep) = thisCounts;
    end
    % mean of means
    meanOfMeans = nanmean(binMeans, 3);
    % error of means
    errorsOfMeans = calcVariance(binMeans, 3, 1);
    % Upper and lower bounds!
    upperBounds = prctile(binMeans, 97.5, 3);
    lowerBounds = prctile(binMeans, 2.5, 3);
    % Also, the sum of counts in each bin for each element
    summedCounts = sum(binCounts, 3);
    % Store it all
    resampledAndBinned = {binCenters(:, 1), meanOfMeans, errorsOfMeans, ...
        upperBounds, lowerBounds, summedCounts};
    % If returnAllResampled, include allResampled
    if ismember("returnAllResampled", runOptions)
        resampledAndBinned{end+1} = allResampled;
    end
    if ismember("returnSampleIDs", runOptions)
        resampledAndBinned{end+1} = allSampleIDs;
    end
end