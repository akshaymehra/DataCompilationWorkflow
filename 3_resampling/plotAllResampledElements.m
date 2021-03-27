function plotAllResampledElements(originalDataset, resampledAndBinned, elementsStruct, toPlotAgainst, ...
    bMin, bMax, nBins, outputDirectory)
    % Here, we make plots
    % Load up some events and ages
    load('0_data_files/lipsTiming.mat', 'lipsTiming');
    load('0_data_files\supercontinentsTiming.mat', 'supercontinents');
    load('0_data_files\iceAgesTiming.mat', 'iceAges');
    % For each chosen element (excluding age)
    % elements listing
    elements = keys(elementsStruct.elementsMap);
    numToPlot = length(elements);
    % Which variable to plot against?
    xElement = elementsStruct.elementsMap(toPlotAgainst);
    for x = 1:numToPlot
        % What is this element
        thisElement = elements{x};
        % And what column are we looking for?
        thisElementCol = elementsStruct.elementsMap(thisElement);
        % As long as we're not plotting age
        if ~strcmpi(thisElement, toPlotAgainst)
            % We'd like to center these plots on the page
            figure('PaperPosition',[.25 .25 8 10.5]) 
            % We're going to plot several subplots here
            % In the first one, we want to plot raw data
            % Note that, because of ciaCalcs and ratios, the output
            % structure may contain more elements than in
            % dataset. So, here, we check to see if
            % thisElementCol is within the dataset col limits
            if thisElementCol <= size(originalDataset, 2)
                % Within age bounds
                withinBounds = bMin <= originalDataset(:, xElement) & originalDataset(:, xElement) <= bMax;
                % First, the raw data
                subplot(5, 1, 1);
                % Scatter plot!
                scatter(originalDataset(withinBounds, xElement), ...
                    originalDataset(withinBounds, thisElementCol), ...
                    [], 'black', 'filled', 'MarkerFaceAlpha', 0.2);
                pbaspect([6,1,1]);
                xlim([bMin, bMax]);
                grid on
                set(gca, 'XMinorTick', 'on', 'XMinorGrid', 'on');
                box on
                title(strcat(thisElement, " raw data age"), 'Interpreter', 'none');
                ylabel("Value");
                xlabel("Age (Ma)");
                set (gca, 'xdir', 'reverse');
                % Now, a histogram of densities
                subplot(6,1,2);
                % Has data
                hasData = ~isnan(originalDataset(:, thisElementCol));
                histogram(originalDataset(hasData, xElement), linspace(bMin, bMax, nBins+1),...
                    'DisplayStyle', 'stairs', 'EdgeColor', 'black');
                thisLegend = {'Raw data'};
                pbaspect([6,1,1]);
                xlim([bMin, bMax]);
                grid on
                set(gca, 'XMinorTick', 'on', 'XMinorGrid', 'on');
                box on
                title(strcat(thisElement, " histogram"), 'Interpreter', 'none');
                ylabel("Count");
                xlabel("Age (Ma)");
                legend(thisLegend);
                set (gca, 'xdir', 'reverse');
            end
            subplot(6,1,3);
            % Okay, just the regular element through time
            plotResampledValues(resampledAndBinned, thisElementCol, ...
                [], [], false, bMin, bMax);
            title(strcat(thisElement, " through time"), 'Interpreter', 'none');
            subplot(6,1,4);
            plotResampledValues(resampledAndBinned, thisElementCol, ...
                lipsTiming{:,2}, lipsTiming{:,1}, false, bMin, bMax);
            title(strcat(thisElement, " through time; LIPs timing"), 'Interpreter', 'none');
            subplot(6,1,5);
            plotResampledValues(resampledAndBinned, thisElementCol, ...
                supercontinents{:,2}, supercontinents{:,1}, true , bMin, bMax);
            title(strcat(thisElement, " through time; supercontinents timing"), 'Interpreter', 'none');
            subplot(6,1,6);
            plotResampledValues(resampledAndBinned, thisElementCol, ...
                iceAges{:,2}, iceAges{:,1}, true , bMin, bMax);
            title(strcat(thisElement, " through time; glaciations"), 'Interpreter', 'none');
            % Write this plot to file
            print(fullfile(outputDirectory, ...
                rectifyFilename(strcat(thisElement, 'Resampled'))), '-painters', '-dpdf');
        end
    end
end