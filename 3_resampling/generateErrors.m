function errors = generateErrors(dataset, elementsMap)
    % To do: rewrite generateErrors to take advantage of an elements map
    % Let's grab two-sigma relative uncertainties
    uncertainties = readtable("0_data_files/err2srel.csv", ...
        'PreserveVariableNames', true);
    % Grab the header names in dataset
    datasetHeaders = dataset.Properties.VariableNames;
    [numSamples, numElements] = calculateSamplesElements(dataset, elementsMap);
    % Empty matrix to hold all of these errors
    errors = nan(numSamples, numElements);
    % Okay, now, for each chosen element, let's assign the relative
    % uncertainity first
    % List the elements in elementsMap
    elements = keys(elementsMap);
    for x = 1:numElements
        % What is this element?
        thisElement = elements{x};
        % thisElement column...note we have to use this cumbersome form
        % because there is no forEach in matlab
        thisElementCol = elementsMap(thisElement);
        % Since the uncertainity is two sigma, we divide by 2
        errors(:, thisElementCol) = dataset.(thisElement) * uncertainties.(thisElement) / 2;
        % Now, let's search for existing uncertainities
        thisElementSigmaHeader = strcat(thisElement, "_sigma");
        % But only if it exists in the dataset
        if any(strcmpi(thisElementSigmaHeader, datasetHeaders))
            theseErrors = dataset.(thisElementSigmaHeader);
            % Exclude any nan values, by creating a logical mask of non nan
            % values
            toChange = ~isnan(theseErrors);
            % Now, update errors with any known sigma values!
            errors(toChange, thisElementCol) = theseErrors(toChange);
        end
    end
    % Let's consider any special cases
    specialCases = {"Latitude", "Longitude"; 0.01, 0.01};
    for sp = 1:size(specialCases, 2)
        if isKey(elementsMap, specialCases{1, sp})
            thisElementCol = elementsMap(specialCases{1, sp});
            errors(:, thisElementCol) = specialCases{2, sp};
        end
    end
    % And we're done
end