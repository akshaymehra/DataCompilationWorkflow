function updatedDataset = BtestForUSGS(dataCSV, propertiesToTest, ...
    valuesToDiscard, outputFile)
    % Here, we go through the dataset, find sample that are from the USGS,
    % query the USGS database to figure out if they are mineralized, and
    % then discard those samples that are. We return an updatedDataset, one
    % without any mineralized samples.
    % One way to run this code:
    % propertiesToTest = {'mineralztn', 'addl_attr'};
    % valuesToDiscard = {{'mineralized', 'mineralization present', 'unknown mineralization'}, ...
    % {'radioactive', 'mineralized'}}
    % updatedDataset = BtestForUSGS('./0_data_files/matlabParsing/6.shalesFinalFiltered.csv', ...
    % propertiesToTest, valuesToDiscard, './0_data_files/matlabParsing/7.shalesFinalFilteredUSGS.csv');
    close all
    % First, import the dataCSV
    dataset = importGeochemCSV(dataCSV);
    % Great, now, find which samples are USGS samples
    isUSGS = strcmpi(dataset.Sample_Notes, 'USGS Samples');
    % Great, now, extract the original sample numbers
    originalSampleNumbers = dataset.Original_Num(isUSGS);
    % Row numbers
    rowNumbersUSGS = find(isUSGS);
    % Number of USGS samples
    numUSGSSamples = length(originalSampleNumbers);
    % Number of properties to test
    numProperties = length(propertiesToTest);
    % What should we delete?
    toDelete = zeros(numUSGSSamples, numProperties, 'logical');
    % Also, which samples contained a mineralization property?
    hadProperty = toDelete;
    % Content type for web request
    options = weboptions('ContentType', 'json');
    % Now, for each USGS sample, let's query the USGS database
    [dataQueue, bar] = startParallelWaitbar(numUSGSSamples);
    parfor x = 1:numUSGSSamples
        tic
        % This sample
        thisSample = originalSampleNumbers(x);
        % USGS JSON request string
        jsonRequestString = strcat('https://mrdata.usgs.gov/ngdb/rock/json/', thisSample);
        % USGS data
        thisSampleData = webread(jsonRequestString, options);
        % We're just interested in sample charactersitics
        sampleCharacteristics = thisSampleData.properties.characteristics;
        % Now, for each property in propertiesToTest
        for y = 1:numProperties
            thisProperty = propertiesToTest{y};
            % Check to see if this property exists
            if isfield(sampleCharacteristics, thisProperty)
                % Okay, now, let's check to see if there are any values
                % indicating that we should discard this sample
                % First, record that this sample had this property
                hadProperty(x, y) = 1;
                % Now, let's compare
                % If this property contains any of the valuesToDiscard for
                % this property, then we set toDelete to 1
                if contains(sampleCharacteristics.(thisProperty),...
                        valuesToDiscard{y}, 'IgnoreCase', true)
                    toDelete(x, y) = 1;
                end
            end
        end
        disp(strcat('Sample ', thisSample, ' checked in', {' '}, num2str(toc), ' seconds.'));
        send(dataQueue, "updated");
    end
    close(bar);
    % Now, for each property
    for x = 1:numProperties
        thisProperty = propertiesToTest{x};
        thisHadProperty = hadProperty(:, x);
        figure
        % Plot up a little pie chart showing how many samples had the property
        colormap('gray')
        pie(categorical(thisHadProperty));
        pbaspect([1,1,1]);
        title(strcat('Samples with the property ', thisProperty ,...
            '; n = ', {' '}, num2str(numUSGSSamples)), 'Interpreter', 'none');
    end
    % Now, update the database
    % What are the row numbers to delete?
    toDeleteRows = rowNumbersUSGS(any(toDelete, 2));
    updatedDataset = dataset;
    updatedDataset(toDeleteRows, :) = [];
        % Now, write to file
    writetable(updatedDataset, outputFile);
end