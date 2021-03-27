function allElements = findAllElements(data)
    % All we do here is find all elements
    % Let's look for any elements with a _sigma 
    variableNames = data.Properties.VariableNames;
    containSigma = contains(variableNames, '_sigma');
    % Variable names including _sigma
    whichVariables = variableNames(containSigma);
    % Now, just get the variable names
    allElements = cellfun(@(x) strsplit(x, '_sigma'), whichVariables, 'UniformOutput', false);
    allElements = cellfun(@(x) x{1}, allElements, 'UniformOutput', false);
end