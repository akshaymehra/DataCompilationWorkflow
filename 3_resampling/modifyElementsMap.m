function elementsMap = modifyElementsMap(elementsMap, toAdd)
    % We add keys, with incremental values to elementsMap and return the results.
    for x = 1:length(toAdd)
        elementsMap(toAdd(x)) = length(elementsMap) + 1;
    end
end