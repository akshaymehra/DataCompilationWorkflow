function weights = invWeight(lat, lon, age, lp, spatialScale, ageScale)
    % In January 2022, invWeight handles multiple spatial and age scales at
    % one
    % Both spatial and age scales should be a 1xm matrix, where each column
    % corresponds to a single scale value
    % The size of both spatial and age scales should match
    % Samples to process
    toProcess = length(lat);
    % Number of scale values
    numScales = size(spatialScale, 2);
    % A weights collector
    weights = zeros(toProcess, numScales);
    % Begin by checking if there is lat, lon, or age data
    noData = isnan(lat) | isnan(lon) | isnan(age);
    % For each element, let's calculate weights
    [dataQueue, bar] = startParallelWaitbar(toProcess);
    parfor sample = 1:toProcess
        if noData(sample)
            % If there's no data, then set this weight to Inf
            weights(sample, :) = inf;
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
            weights(sample, :) = sum(distanceWeighting + ageWeighting, 1,'omitnan');
        end
        send(dataQueue, "updated");
    end
    close(bar);
end