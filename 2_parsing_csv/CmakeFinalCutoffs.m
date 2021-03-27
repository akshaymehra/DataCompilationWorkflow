function finalDataset = CmakeFinalCutoffs(dataCSV, cutoffCSV, outputFile,...
    createPlots, zoomElements, zoomLims, saveOutput)
    close all
    % One way to run this code:
%     cutoffCSV = '0_data_files/elementBounds.csv';
%     CmakeFinalCutoffs('./0_data_files/matlabParsing/7.shalesFinalFilteredUSGS.csv',...
%     cutoffCSV, './0_data_files/matlabParsing/8.shalesFinalFilteredUSGSCutoffs.csv',...
%     true, ["Al2O3", "U"], {{[-2, log10(1)], [0, 25]}, {[log10(100),log10(10000)],...
%     [0,25]}}, false);
    % Begin by loading in dataCSV
    dataset = importGeochemCSV(dataCSV);
    % Also, read in cutoffCSV
    opts = detectImportOptions(cutoffCSV);
    cutoffs = readtable(cutoffCSV, opts);
    numberCutoffs = height(cutoffs);
    % Now, if createPlots is set to true, we need to output multiple
    % figures in a 3x3 layout
    if createPlots
        % Layout 
        layout = [4, 4];
        numberPlotsPerFig = prod(layout);
        % Create a counter
        counter = 1;
        % And one to track how many figures we make
        numFigs = 1;
    end
    % Great, let's process the cutoffs
    shouldWeDelete = zeros(height(dataset), 1, 'logical');
    for x = 1:numberCutoffs
        % Pull out this element and associated lower and upper bounds
        thisElement = cutoffs(x, :);
        elementName = thisElement.Element{1};
        datasetValues = dataset.(elementName);
        datasetAges = dataset.Age_Interpreted;
        toDelete = datasetValues < thisElement.LowerBound ...
            | datasetValues > thisElement.UpperBound;
        shouldWeDelete(toDelete) = 1;
        % Now, if createPlots is true
        if createPlots
            % If first plot in figure, create the figure
            if counter == 1
                currentFig = figure('PaperPosition',[0 0 7.125 7.125]) ;
            end
            % Generate a subplot
            thisSubplot = subplot(layout(1), layout(2), counter);
            thisDataLog = log10(datasetValues(datasetValues >= 0));
            thisAges = datasetAges(datasetValues >= 0);
            % Create a histogram of log values
            [numberPerBin, edgeValues] = histcounts(thisDataLog, 50);
            % Plot it up
            thisHisto = histogram('BinEdges', edgeValues, 'BinCounts', numberPerBin ,...
                'DisplayStyle', 'stairs', 'EdgeColor', 'black');
            % Go ahead and add the upper and lower bounds
            hold on
            boundsToPlot = [thisElement.LowerBound, thisElement.UpperBound];
            % Let's also get the percentiles
            percentiles = prctile(thisDataLog, [.5, 99.5]);
            % Plot those boundaries
            plotBoundaries(boundsToPlot, percentiles, true);
            pbaspect([1,1,1]);
            title(elementName);
            ylabel('Count');
            xlabel('Log value');
            % Now, let's do a zoom in, if necessary
            if ismember(elementName, zoomElements)
                % Index in zoomElements
                [~, thisIdx] = find(strcmp(elementName, zoomElements));
                thisLims = zoomLims{thisIdx};
                subplotYLims = ylim;
                % First, let's add a rectangle to the subplot, so we know
                % where we will zoom in
                rectangle('Position', [thisLims{1}(1), thisLims{2}(1),...
                    thisLims{1}(2) - thisLims{1}(1), thisLims{2}(2) - thisLims{2}(1)]);
                % Create a temporary figure
                tempZoomIn = figure;
                tempAxes = axes;
                % Copy over the histogram
                copyobj(thisHisto, tempAxes);
                % Plot boundaries
                plotBoundaries(boundsToPlot, percentiles, true);
                % Now, where do we want to zoom in (x axis?)
                xlim(thisLims{1});
                ylim(thisLims{2});
                pbaspect([1,1,1]);
                xlabel('Log_10 value');
                ylabel('Count');
                % Let's print and close this temporary figure
                print(strcat(elementName, 'zoomIn.pdf'), '-painters', '-dpdf');
                close(tempZoomIn);
                % Now, what about a plot of values vs ages
                toFilter = thisDataLog >= thisLims{1}(1) ...
                    & thisDataLog <= thisLims{1}(2);
                zoomedValues = thisDataLog(toFilter);
                zoomedAges = thisAges(toFilter);
                tempScatter = figure;
                scatter(zoomedAges, zoomedValues, 'filled');
                % Add the bounds
                plotBoundaries(boundsToPlot, percentiles, false);
                ylim(thisLims{1});
                pbaspect([1,1,1]);
                grid on
                xlabel('Age (Ma)');
                ylabel('Log_10 value');
                set (gca, 'xdir', 'reverse');
                % Let's print and close this temporary figure
                print(strcat(elementName, 'zoomInScatter.pdf'), '-painters', '-dpdf');
                close(tempScatter);
            end
            % Now, update counter
            counter = counter + 1;
            % If counter is greater than the numberPlotsPerFig, set counter
            % to 1
            if counter > numberPlotsPerFig || x == numberCutoffs
                % You might as well print the existing figure
                print(strcat('Cutoffs', num2str(numFigs), '.pdf'), '-painters', '-dpdf');
                numFigs = numFigs +1;
                counter = 1;
            end
        end
    end
    % By doing the NOT of shouldWeDelete, we get the rows that we need to
    % keep
    finalDataset = dataset(~shouldWeDelete, :);
    % Let's write it
    if saveOutput
        writetable(finalDataset, outputFile);
    end
    disp(strcat('Number of samples deleted:', {' '}, ...
        num2str(sum(shouldWeDelete))));
end

function plotBoundaries(boundsToPlot, percentiles, plotXline)
    for bound = 1:length(boundsToPlot)
        thisBound = log10(boundsToPlot(bound));
        if plotXline
            xline(percentiles(bound), 'Color', 'blue');
        else
            yline(percentiles(bound), 'Color', 'blue');
        end
        if ~isnan(thisBound)
            if plotXline
                xline(thisBound, '--', 'Color', 'red');
            else
                yline(thisBound, '--', 'Color', 'red');
            end
        end
    end
end
