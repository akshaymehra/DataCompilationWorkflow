function weights = invWeight(lat, lon, age, lp, spatialScale, ageScale)
    % Samples to process
    toProcess = length(lat);
    % A weights collector
    weights = zeros(toProcess, 1);
    % Begin by checking if there is lat, lon, or age data
    noData = isnan(lat) | isnan(lon) | isnan(age);
    % For each element, let's calculate weights
    for sample = 1:toProcess
        if noData(sample)
            % If there's no data, then set this weight to Inf
            weights(sample) = inf;
        else
            % Otherwise, let's calculate a weight
            % Begin with getting arc lengths
            [spaceDistances, ~] = distance(lat(sample), lon(sample), lat, lon);
            % Now, let's calculate the distance weighting
            distanceWeighting = 1 ./ ((spaceDistances ./ spatialScale).^lp + 1.0);
            % Let's also calculate the age weighting
            ageDistances = abs(age(sample) - age);
            ageWeighting = 1 ./ ((ageDistances ./ ageScale).^lp + 1.0);
            % Let's sum the two up
            weights(sample) = nansum(distanceWeighting + ageWeighting);
        end
    end
end