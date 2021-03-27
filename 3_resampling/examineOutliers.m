function tablesStore = examineOutliers(dataCSV, elementList, bMin, bMax)
    % Here, we plot up element data
    close all
    % Load dataCSV
    dataset = importGeochemCSV(dataCSV);
    % Let's extract age, sampleID, and source information
    ages = dataset.Age;
    lat = dataset.Latitude;
    lng = dataset.Longitude;
    sampleIds = dataset.Sample_ID;
    originalNum = dataset.Original_Num;
    sampleNotes = dataset.Sample_Notes;
    doi = dataset.Ref_DOI;
    envNotes = dataset.Env_Notes;
    % Now, let's figure out which rows of data are within bMin and bMax
    limits = (bMin <= ages) & (ages <=bMax);
    % Limit ages samples and ref info
    agesLimited = ages(limits);
    latLimited = lat(limits);
    lngLimited = lng(limits);
    sampleIdsLimited = sampleIds(limits);
    sampleNumLimited = originalNum(limits);
    sampleNotesLimited = sampleNotes(limits);
    doiLimited = doi(limits);
    envNotesLimited = envNotes(limits);
    % Great, now, let's plot up the data for each element in elementList
    
    numElements = length(elementList);
    
    % We'll want to store the tables output by the plotting and brushing
    
    tablesStore = cell(numElements, 1);
    
    for itr = 1:numElements
        thisFigure = figure;
        thisElement = elementList(itr);
        % What's selected?
        whatSelected = [];
        % First, does this element even exist?
        if ismember(thisElement, dataset.Properties.VariableNames)
            % Get this data
            thisData = dataset.(thisElement);
            % Limit this data
            thisDataLimited = thisData(limits);
            % Let's plot
            thisScatter = scatter(agesLimited, log(thisDataLimited), [], 'black', 'filled', 'MarkerFaceAlpha', 0.2);
            pbaspect([2,1,1]);
            grid on
            title(strcat(elementList(itr), " through time"));
            xlabel('Age (Ma)');
            ylabel('Value');
            b = brush;
            b.Enable = 'on';
            b.Color = 'red';
            % Add a push button
            pushButton = uicontrol;
            pushButton.String = 'Finished';
            pushButton.Callback = @pushButtonPushed;
            uiwait
            % Let's close this figure
            close(thisFigure);
            % Let's also plot lat/lng of samples up
            mapPlot = figure;
            geoscatter(latLimited(whatSelected), lngLimited(whatSelected), [], ...
                'red', 'filled', 'MarkerFaceAlpha', 0.75);
            geobasemap('grayland');
            geolimits([-90, 90], [-180, 180]);
            title('Map of selected sample locations');
            % Add a push button
            mapContinue = uicontrol;
            mapContinue.String = 'Continue';
            mapContinue.Callback = @mapContinuePushed;
            uiwait
            % Alright, let's close the map and move on
            close(mapPlot);
        end 
    end
    
    function pushButtonPushed(~, ~)
        % Let's store brush data information
        selected = logical(thisScatter.BrushData);
        selectedNames = {'Sample ID', 'Original Sample Number', 'Sample Value', 'Sample Notes', ...
            'Sample Age', 'DOI', 'Environment Notes'};
        % Make a table!
        selectedTable = table(sampleIdsLimited(selected), sampleNumLimited(selected), thisDataLimited(selected), ...
            sampleNotesLimited(selected), agesLimited(selected), doiLimited(selected), ...
            envNotesLimited(selected), 'VariableNames', selectedNames);
        % Display this table
        display(selectedTable);
        % Store this table
        tablesStore{itr} = selectedTable;
        whatSelected = selected;
        uiresume
    end

    function mapContinuePushed(~, ~)
        uiresume
    end
end

