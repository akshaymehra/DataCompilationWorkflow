function [numSamples, numElements] = calculateSamplesElements(dataset, elementsMap)
    % A simple function: 
    % How many elements are we working with?
    numElements = length(elementsMap);
    % And...how many samples?
    numSamples = height(dataset(:,1));
end