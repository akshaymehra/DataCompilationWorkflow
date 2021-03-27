function ratioStrings = generateRatioStrings(elementsStruct)
    % Generate ratios strings
    numRatios = length(elementsStruct.numeratorElements);
    ratioStrings = strings(numRatios, 1);
    for x = 1:numRatios
        ratioStrings(x) = strcat(elementsStruct.numeratorElements(x), ...
            "/", elementsStruct.denominatorElements(x));
    end
end