function closest = limMax(values, multiple)
    % First, extract the maximum value
    % Remove infs
    maximumValue = nanmax(values(~isinf(values)));
    % Now, what's the closest upper bound for the multiple
    % chosen---assuming that the max value is greater than the multiple
    if maximumValue >= multiple
        closest = ceil(maximumValue/multiple) * multiple;
    else
        closest = maximumValue;
    end
end