function AparseSGPExport(SGPExport, UCCDatafile, sigmaString, ...
    outputDirectory, yesPlot)
    %% INITIAL PARSING
    close all
    % Begin by importing the CSV export
    opts = detectImportOptions(SGPExport, 'Delimiter', ',');
    % Note, that everything should be a string!
    opts.VariableTypes(:) = {'string'};
    dataset = readtable(SGPExport, opts);
    % Let's also load in the Rudnick UCC
    UCCData = readtable(UCCDatafile);
    % Which columns should we ignore for parsing purposes?
    % toIgnore = ["Sample_ID", "Original_Num", "Sample_Notes", "Ref_Title", ...
    %    "Ref_URL", "Ref_DOI", "Coll_Events_Notes", "Env_Notes", "Lith_Name"];
    % Now, cycle through each column header
    colHeaders = dataset.Properties.VariableNames;
    for x = 1:length(colHeaders)
        % Really easy check to see if this is a variable we're interested
        % in
        thisHeader = colHeaders{x};
        % Let's replace any newlines, which can be totally nefarious
        dataset.(thisHeader) = regexprep(dataset.(thisHeader),'[\n\r]+',' ');
        sigmaStringLength = length(sigmaString);
        isSigma = contains(thisHeader, sigmaString);
        if isSigma
            % Okay, let's look for the element to which this sigma
            % corresponds
            sansSigma = thisHeader(1:end-sigmaStringLength);
            % Great, now let's get the element data and the sigma data from
            % the original dataset
            elementData = dataset.(sansSigma);
            sigmaData = dataset.(thisHeader);
            % Now, let's look in the element data for multiple analyses
            hasMultiple = contains(elementData, ';');
            % Produce a mean and sigma output
            calculatedMean = nan(size(elementData));
            calculatedSigma = calculatedMean;
            % For each row in elementData, we want to look for multiple
            % values and calculate the mean and sigma accordingly. We don't
            % update single values yet.
            for y = 1:length(elementData)
                % Now, for each row
                if hasMultiple(y)
                    splitElementString = strsplit(elementData(y), ';');
                    splitSigmaString = strsplit(sigmaData(y), ';');
                    % Convert split elementData string to a number
                    convertedElementData = str2double(splitElementString);
                    if ~isempty(splitSigmaString) && ~ismissing(splitSigmaString)
                        % If we have some sigma data to work with, we'll
                        % try to calculate the weighted mean
                        [wM, wS, ~] = weightedMean(convertedElementData, ...
                            str2double(splitSigmaString));
                        calculatedMean(y) = wM;
                        calculatedSigma(y) = wS;
                    else
                        % Set mean to the mean of element data
                        calculatedMean(y) = mean(convertedElementData);
                        % Set sigma to sigma of element data
                        calculatedSigma(y) = std(convertedElementData);
                    end
                end
            end
            % Now, we mass copy single values over to calculatedMean and
            % calculatedSigma
            calculatedMean(~hasMultiple) = str2double(elementData(~hasMultiple));
            calculatedSigma(~hasMultiple) = str2double(sigmaData(~hasMultiple));
            % Update the dataset to include our newly calculated values
            dataset.(sansSigma) = calculatedMean;
            dataset.(thisHeader) = calculatedSigma;
        end
    end
    % Now, let's write the updated dataset to file
    writetable(dataset, fullfile(outputDirectory, '1.parsed.csv'));
    % Clear some variables
    clear calculatedMean calculatedSigma elementData sigmaData
    disp("CSV parsed.");
    %% Iron Oxides
    % Moving on...
    % Let's convert iron oxides
    % And other oxides
    % To convert from Fe2O3 wt to FeO wt %, multiply by
    ironOxideConversionFactor = (55.845+15.999) / (55.845+1.5*15.999);
    % If FeOT already exists, use that...
    % First, let's get out all of the iron oxides we are interested in
    FeOTValues = dataset.FeOT;
    Fe2O3Values = dataset.Fe2O3;
    FeOValues = dataset.FeO;
    % Which rows lack feOT data BUT have either FeO or Fe2O3 data??
    toConvert = isnan(FeOTValues) & (~isnan(Fe2O3Values) | ~isnan(FeOValues));
    FeOTValues(toConvert) = nansum([Fe2O3Values(toConvert)*ironOxideConversionFactor, ...
        FeOValues(toConvert)], 2);
    dataset.FeOT = FeOTValues;
    disp("Iron oxides calculated.");
    %% Oxide Calculations
    % Here, we convert major elements (Ti, Al, etc.) into corresponding oxides (TiO2, Al2O3)...
    % Elements to convert
    source = ["Si", "Ti", "Al", "Fe", "Fe", "Mg", "Ca", "Mn", "Na", "K", "P", "Cr",...
        "Ni", "Co", "C", "S", "H"];
    destination = ["SiO2", "TiO2", "Al2O3", "FeOT", "Fe2O3T", "MgO", "CaO", "MnO", ...
        "Na2O", "K2O", "P2O5", "Cr2O3", "NiO", "CoO", "CO2", "SO2", "H2O"];
    conversionFactor = [2.13932704290547, 1.66847584248889, 1.88944149488507, ...
        1.28648836426407, 1.42973254639611, 1.65825961736268, 1.39919258253823, ...
        1.29121895771597, 1.34795912485574, 1.20459963614796, 2.29133490474735, ...
        1.46154369861159, 1.27258582901258, 1.27147688434143, 3.66405794688203, ...
        1.99806612601372, 8.93601190476191];
    % For each source...
    for x = 1:length(source)
        % Does this source exist? 
        if ismember(source(x), dataset.Properties.VariableNames)
            % Okay, what about the destination?
            if ~ismember(destination(x), dataset.Properties.VariableNames)
                % If not, add it to dataset
                dataset.(destination(x)) = nan(height(dataset), 1);
            end
            % Now, convert the source
            % ! Only ones that don't have values already
            sourceData = dataset.(source(x));
            converted = dataset.(destination(x));
            converted(isnan(converted)) = sourceData(isnan(converted)) ...
                * (conversionFactor(x) / 10000);
            dataset.(destination(x)) = converted;
        end
    end
    disp("Oxides converted.");
    %% AGE CONSIDERATIONS
    % Convert to double
    dataset.Age_Interpreted = str2double(dataset.Age_Interpreted);
    dataset.Age_Max = str2double(dataset.Age_Max);
    dataset.Age_Min = str2double(dataset.Age_Min);
    % First, add a column called Age, drawn from interpreted age
    dataset.Age = dataset.Age_Interpreted;
    % Now, calculate an age sigma from the min and max ages that are
    % reported
    dataset.Age_sigma = abs(dataset.Age_Max - dataset.Age_Min)/2;
    % Next, let's take any missing age sigma and default to 6% two-sigma
    % (roughly the mean, as it happens)
    dataset.Age_sigma(isnan(dataset.Age_sigma)) = 0.03 * ...
        dataset.Age_Interpreted(isnan(dataset.Age_sigma));
    % Now, optionally, we enforce a minimum relative age uncertainty
    minRelAgeUncert = 0.0;
    toEnforce = (dataset.Age_sigma ./ dataset.Age) < minRelAgeUncert;
    dataset.Age_sigma(toEnforce) = minRelAgeUncert * dataset.Age(toEnforce);
    % As well as a minimum ABSOLUTE age uncertainity (in Ma)
    minAbsAgeUncert = 25;
    dataset.Age_sigma(dataset.Age_sigma < minAbsAgeUncert) = minAbsAgeUncert;
    % Might as well save at this point
    writetable(dataset, fullfile(outputDirectory, '2.prefilter.csv'));
    disp("Ages caclulated.");
    %% Now, let's do some filtering
    % Define valid shale lithologies
    validShaleLithologies = ["shale", "mudstone", "mud", "ooze", "marl", ...
        "clay", "slate", "argillite", "meta-argillite", "pelite", ...
        "metapelite", "claystone"];
    % Also, define some valid sandstone lithologies
    validSandsLithologies = ["sandstone", "quartzite"];
    % Now, define a filtered shales and a filtered sands dataset...and then
    % write them to file
    filteredShalesDataset = dataset(ismember(dataset.Lith_Name, ...
        validShaleLithologies), :);
    writetable(filteredShalesDataset, fullfile(outputDirectory, '3.shalesFiltered.csv'));
    filteredSandsDatset = dataset(ismember(dataset.Lith_Name, ...
        validSandsLithologies), :);
    writetable(filteredSandsDatset, fullfile(outputDirectory, '3.sandsFiltered.csv'));
    disp("Data filtered.");
    %% Screen data
    fSShalesdDataset = screenData(filteredShalesDataset);
    % To implement in the future, were any values actually removed?
    % ...
    % Save the screened dataset
    writetable(fSShalesdDataset, ...
        fullfile(outputDirectory, '4.shalesScreenedAndFiltered.csv'));
    disp("Data screened.");
    %% Ca and P2O5 filtering
    numberToFilter = height(fSShalesdDataset);
    disp(strcat("Number of samples before Calcium and P2O5 filtering:", ... 
        {' '}, num2str(numberToFilter)));
    % To filter out carbonates, we are only including samples that have 
    % less than 10 wt% Calcium
    % Since Calcium is in ppm, we use a cutoff of 10^5
    CaCutoff = 10^5;
    belowCaCutoff = fSShalesdDataset.Ca < CaCutoff;
    numberBelowCaCutoff = sum(belowCaCutoff);
    disp(strcat("Number of valid samples after Calcium cutoff:", ...
        {' '}, num2str(numberBelowCaCutoff)));
    if yesPlot
        % We'll want to visualize the impact of these filters
        CaPPMBins = 0:10000:5*CaCutoff;
        filterImpact = figure();
        % Full histogram first
        histogram(fSShalesdDataset.Ca, CaPPMBins, 'DisplayStyle', 'stairs',...
            'EdgeColor', 'black');
        
        % Hold on
        hold on
        % Now, histogram of values under the cutoff
        histogram(fSShalesdDataset.Ca(belowCaCutoff), CaPPMBins, 'DisplayStyle',...
            'stairs', 'EdgeColor', 'red');
        pbaspect([1,1,1]);
        grid on
        xlabel('Ca value (ppm)');
        ylabel('Count');
    end
    % Next, we do a P2O5 correction
    % Designed to exclude phosphorites
    P2O5Cutoff = 1;
    belowP2O5Cutoff = fSShalesdDataset.P2O5 < P2O5Cutoff;
    % Samples that are below both cutoffs
    belowBoth = belowCaCutoff & belowP2O5Cutoff;
    numberBelowBoth = sum(belowBoth);
    disp(strcat( "Number of valid samples after P2O5 filter:", ...
        {' '}, num2str(numberBelowBoth) ));
    if yesPlot
        figure(filterImpact);
        histogram(fSShalesdDataset.Ca(belowBoth), CaPPMBins, 'DisplayStyle', ...
            'stairs', 'EdgeColor', 'blue');
        legend({'Shale data', 'After Ca cutoff', 'After P2O5 cutoff'});
        print(fullfile(outputDirectory, 'caP2O5cutoffs.eps'), '-painters', '-depsc');
    end
    % Now, update the dataset
    fSShalesdDataset = fSShalesdDataset(belowBoth, :);
    % Write to file
    writetable(fSShalesdDataset, ...
        fullfile(outputDirectory, '5.shalesPostCaP2O5Cutoffs.csv'));
    disp('Ca and P2O5 cutoffs applied');
    %% Intermediate calculations
    [CaOStar, CaOStarApprox, CaOStarHybrid] = CaOCalcs(fSShalesdDataset.Na2O, ...
        fSShalesdDataset.TIC, ...
        fSShalesdDataset.CaO, ...
        fSShalesdDataset.P2O5);
    % So now, accurate silicate CaO
    fSShalesdDataset.CaOStar = CaOStar;
    % Approximate silicate CaO
    fSShalesdDataset.CaOStarApprox = CaOStarApprox;
    % Hybrid form
    fSShalesdDataset.CaOStarHybrid = CaOStarHybrid;
    % Now, some CIA and WIP values
    % To do, calculate EuStar
    fSShalesdDataset.CIAUncorr = calculateCIA(fSShalesdDataset.Al2O3, ...
        fSShalesdDataset.CaO, fSShalesdDataset.Na2O, fSShalesdDataset.K2O);
    fSShalesdDataset.CIAStar = calculateCIA(fSShalesdDataset.Al2O3, ...
        fSShalesdDataset.CaOStar, fSShalesdDataset.Na2O, fSShalesdDataset.K2O);
    fSShalesdDataset.CIAStarApprox = calculateCIA(fSShalesdDataset.Al2O3, ...
        fSShalesdDataset.CaOStarApprox, fSShalesdDataset.Na2O, fSShalesdDataset.K2O);
    fSShalesdDataset.CIAStarHybrid = calculateCIA(fSShalesdDataset.Al2O3, ...
        fSShalesdDataset.CaOStarHybrid, fSShalesdDataset.Na2O, fSShalesdDataset.K2O);
    fSShalesdDataset.WIP = calculateWIP(fSShalesdDataset.Na2O, ...
        fSShalesdDataset.MgO, fSShalesdDataset.K2O, fSShalesdDataset.CaO);
    % fSShalesdDataset.Eu_star = eustar.(fSShalesDataset.Nd, ...
    %   fSShalesDataset.Sm, fSShalesDataset.Gd, fSShalesDataset.Tb);
    % Now, write to file
    writetable(fSShalesdDataset, ...
        fullfile(outputDirectory, '6.shalesFinalFiltered.csv'));
    disp("Intermediate and calculated values added.");
    disp("Filtered CSV output.");
end
