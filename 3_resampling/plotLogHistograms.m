function plotLogHistograms(dataCSV, plotAll, toPlot, outputDirectory)
    close all
    % First, import the dataCSV
    dataset = importGeochemCSV(dataCSV);
    if plotAll
        % If plotAll, let's look for any elements with a _sigma 
        toPlot = findAllElements(dataset);
    end
    numToPlot = length(toPlot);
    % Now, let's plot log values of data, as histograms
    for x = 1:numToPlot
         % We'd like to center these plots on the page
        thisFig = figure('PaperPosition',[.25 .25 8 10.5]) ;
        thisElement = toPlot{x};
        thisData = dataset.(thisElement);
        thisDataLog = log(thisData(thisData >= 0));
        % Create a histogram
        [numberPerBin, edgeValues] = histcounts(thisDataLog, 50);
        % Plot it up
        histogram('BinEdges', edgeValues, 'BinCounts', numberPerBin ,...
            'DisplayStyle', 'stairs', 'EdgeColor', 'black');
        pbaspect([3,1,1]);
        % Now, let's plot the .5 and 99.5 percentiles
        percentiles = prctile(thisDataLog, [.5, 99.5]);
        for y = 1:length(percentiles)
            thisPercentile = percentiles(y);
            if isreal(thisPercentile) && isfinite(thisPercentile)
                xline(thisPercentile, 'Color', 'red');
            end
        end
        xlabel('Log value');
        ylabel('Count');
        grid on
        % Custom labelling
        customLabelling();
        % Let's title this plot
        title(thisElement, 'Interpreter', 'None');
        % Fianlly, let's save this plot
        print(fullfile(outputDirectory, ...
            rectifyFilename(strcat(thisElement, 'LogHistogram'))), '-painters', '-dpdf');
        close(thisFig);
    end
end

function customLabelling()
    ax1 = gca;
    ax2 = axes('Position', get(ax1, 'Position'), 'Color', 'none');
    set(ax2, 'XAxisLocation', 'top');
    % set the same Limits and Ticks on ax2 as on ax1
    set(ax2, 'XLim', get(ax1, 'XLim'));
    set(ax2, 'XTick', get(ax1, 'XTick'));
    OppTickLabels = round(exp(get(ax1, 'XTick')), 3, 'significant');
    % Set the x-tick and y-tick  labels for the second axes
    set(ax2, 'XTickLabel', OppTickLabels);
    set(ax2, 'YTick',[]);
    xlabel('Value');
    pbaspect(ax1.PlotBoxAspectRatio);
end