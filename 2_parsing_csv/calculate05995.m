function percentileTable = calculate05995(dataset)
    % This function just takes a dataset, loads it in, and then provides
    % the 0.5th and 99.5th percentile bounds...
    % This function returns a table (and outputs it into the command window
    % as well)
    % Load in the data
    data = importGeochemCSV(dataset);
    % For each element...
    elements = findAllElements(data);
    numElements = length(elements);
    % Create a place to put the .05 and .995 lines
    percentiles = zeros(numElements, 2);
    for x = 1:numElements
        percentiles(x, :) = prctile(data.(elements{x}), [0.5, 99.5]);
    end
    percentileTable = table(elements', percentiles(:, 1), percentiles(:,2), 'VariableNames', {'Element', ...
    '0.5', '99.5'});
    % Sort the table
    sortrows(percentileTable, 'Element')
end