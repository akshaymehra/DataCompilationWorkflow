function [resampled, randomSamples] = bsresample(dataset, numDraws, probs, errors)
    [numSamples, numElements] = size(dataset);
    % Okay, now, let's randomly sample, WITH replacement! 
    % First, which of the samples will we take?
    sampleIds = [1:numSamples]';
    randomSamples = randsample(sampleIds, numDraws, true, probs);
    % Now, let's define resampled
    resampled = dataset(randomSamples, :);
    % Also, let's figure out errors
    errorsResampled = errors(randomSamples, :);
    % Now, finally, let's draw randomly from a normal distribution
    toMultiply = normrnd(0, 1, [numDraws, numElements]);
    % multiply errorsResampled with toMultiply to come up with a new error
    err = errorsResampled .* toMultiply;
    % And add that error to resampled!
    resampled = resampled + err;
    % If resampled is less than 0, set to NaN
    resampled(resampled < 0) = NaN;
end