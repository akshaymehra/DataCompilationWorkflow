function elementsMap = createElementsMap(elements)
    % Generate a containers.Map based on a matrix of element strings
    elementsMap = containers.Map(elements, 1:length(elements));
end