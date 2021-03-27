function culledDataset = cullDataset(dataset, elementsMap)
    % Returns a limited dataset, based on the elements in elementsMap
    % How many? 
    [numSamples, numElements] = calculateSamplesElements(dataset, elementsMap);
    % Allocate the output
    culledDataset = zeros(numSamples, numElements);
    % Notice we're generating a matrix, where each column is an element and
    % each row is a sample. The order of the columns corresponds to the
    % order of elements in elementsMap.
    % List of elements in elementsMap
    elements = keys(elementsMap);
    for x = 1:numElements
        culledDataset(:, elementsMap(elements{x})) = dataset.(elements{x});
    end
end