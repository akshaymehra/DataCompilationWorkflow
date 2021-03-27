function variance = calcVariance(data, dim, resamplingRatio)
    % variance = nanstd(data, 0, dim) * sqrt(resamplingRatio) / sqrt(size(data, dim));
    variance = nanstd(data, 0, dim);
end
