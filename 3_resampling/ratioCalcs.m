function resampledData = ratioCalcs(resampledData, elementsStruct)
    % For ease of reading, get out elementsMap, numeratorElements, and
    % denominatorElements
    elementsMap = elementsStruct.elementsMap;
    numeratorElements = elementsStruct.numeratorElements;
    denominatorElements = elementsStruct.denominatorElements;
    % Ratio strings
    ratioStrings = generateRatioStrings(elementsStruct);
    % How many ratios?
    numRatios = length(ratioStrings);
    % Now, for each ratio
    for x = 1:numRatios
        numeratorData = resampledData(:, elementsMap(numeratorElements(x)));
        denominatorData = resampledData(:, elementsMap(denominatorElements(x)));
        thisRatio = numeratorData ./ denominatorData;
        resampledData(:, elementsMap(ratioStrings(x))) = thisRatio;
    end
end