function [weightedMean, weightedSigma, MSWD] = weightedMean(data, sigma)
    % Geochronologist's weighted mean, which includes a MSWD
    % How many to process?
    toProcess = length(data);
    % If only one, just return the input
    if toProcess == 1
        weightedMean = data;
        weightedSigma = sigma;
        MSWD = nan;
    else
        % Okay, let's begin by calculating the weighted mean
        % The weighted mean comprises a numerator that is the sume of x(i) / sigma(i)^2
        % and a denominator that is the sum of 1/sigma(i)^2 for i =
        % 1:toProcess
        % Let's define those values
        weightedMeanNumerator = sum(data ./ (sigma .^ 2));
        weightedMeanDenominator = sum(1 ./ (sigma .^ 2));
        weightedMean = weightedMeanNumerator/weightedMeanDenominator;
        % Let's also calculate a MSWD, which is defined as 1 / degrees of
        % freedom * the sum of (x(i) - weighted mean) ^ 2 / sigma(i)^2
        % degrees of freedom is effecitively toProcess - 1
        MSWD = sum( ((data - weightedMean) .^ 2) ./ (sigma .^ 2) ) / (toProcess - 1);
        % Finally, let's get the weighted sigma, which is defined as the
        % square root of the MSWD / weightedMeanDenominator
        weightedSigma = sqrt(MSWD / weightedMeanDenominator);
    end
end