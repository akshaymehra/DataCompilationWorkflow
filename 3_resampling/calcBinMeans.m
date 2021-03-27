function [binCenters, means, variance, counts] = calcBinMeans(toBinBy, dataset, bMin, bMax, nBins, resamplingRatio)
    % First, what are the bin widths?
    binWidths = (bMax-bMin) / nBins;
    % The edges?
    binEdges = linspace(bMin, bMax, nBins + 1);
    % And the centers
    binCenters = (bMin + binWidths / 2): binWidths :(bMax - binWidths / 2);
    % Let's discretize using binEdges
    binsRef = discretize(toBinBy, binEdges);
    % Okay, let's create means and errors outputs
    % How many elements?
    numElements = size(dataset, 2);
    means = zeros(nBins, numElements);
    variance = zeros(nBins, numElements);
    counts = zeros(nBins, numElements);
    % Finally, let's populate...
    for x = 1:nBins
        toAverage = dataset(binsRef == x, :);
        means(x, :) = nanmean(toAverage, 1);
        variance(x, :) = calcVariance(toAverage, 1, resamplingRatio);
        counts(x,:) = sum(~isnan(toAverage), 1);
    end
end