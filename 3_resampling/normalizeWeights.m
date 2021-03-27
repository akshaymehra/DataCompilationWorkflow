function normalized = normalizeWeights(weights, target)
    % Divide 1 by target, which should be in decimal percent
    toDivide = 1/target;
    normalized = 1.0 ./ ((weights .* median(toDivide ./ weights)) + 1.0);
end