function plotResampledValues(resampledAndBinned, thisElementCol, ...
    eventsAges, eventsNames, plotAsRectangles, bMin, bMax)
    % Now, the resampled values
    hold on
    
    errorbar(resampledAndBinned{1}, resampledAndBinned{2}(:, thisElementCol), ...
    resampledAndBinned{3}(:, thisElementCol), 'o', 'color', 'black');
    plot(resampledAndBinned{1}, resampledAndBinned{2}(:, thisElementCol), 'color', ...
        'red');
    xlim([bMin, bMax]);
    pbaspect([6,1,1]);
    grid on
    set(gca, 'XMinorTick', 'on', 'XMinorGrid', 'on');
    box on
    ylabel("Value");
    xlabel("Time (Ma)");
    
    % Adjust y lims
    plotYLim = ylim;
    yMax = limMax(plotYLim(2), 10);
    ylim([plotYLim(1), yMax]);

    if ~isempty(eventsAges)
        % Okay, we have events to plot
        % If plotAsRectangles is true, we want to make sure that there are
        % an even number of dates
        plotRectangles = false;
        numEvents = length(eventsAges);
        if plotAsRectangles
            if ~mod(numEvents, 2)
                plotRectangles = true;
            end
        end
        % Okay, now, let's plot
        if plotRectangles
            numRectangles = numEvents/2;
            for x = 1:numRectangles
                eventStartIdx = ((x - 1) * 2) + 1;
                eventStart = eventsAges(eventStartIdx);
                eventEnd = eventsAges(eventStartIdx + 1);
                % Now, what's the absolute difference?
                absoluteDiff = abs(eventStart - eventEnd);
                % Okay now, let's ensure that the eventStart and eventEnd
                % are within bounds
                if eventStart >= bMin && eventStart <= bMax && eventEnd >= bMin && eventEnd <= bMax
                    % Let's plot this rectangle!
                    yLims = ylim;
                    xStart = min(eventStart, eventEnd);
                    rectColor = [0.5 0.5 0.5 0.5];
                    thisRect = rectangle('Position', [xStart, yLims(1), ...
                        absoluteDiff, yLims(2) - yLims(1)], 'EdgeColor', rectColor, 'FaceColor', rectColor);
                    % Place a label in the center of this rectangle
                    thisLabel = text(xStart + absoluteDiff/2, yLims(1) + (yLims(2) - yLims(1)) / 2, ...
                        eventsNames{eventStartIdx}, 'HorizontalAlignment', 'center', ...
                        'Color', 'black');
                    set(thisLabel, 'Rotation', 90);
                    uistack(thisLabel, 'bottom');
                    uistack(thisRect, 'bottom');
                end
            end
        else
            % Now, plot as lines
            for x = 1:numEvents
                thisEvent = eventsAges(x);
                if thisEvent >= bMin && thisEvent <= bMax
                    line([thisEvent, thisEvent], ylim, 'Color', 'cyan');
                end
            end
        end
    end
    % Flip X axis
    set (gca, 'xdir', 'reverse');
end