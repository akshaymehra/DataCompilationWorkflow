function status = SGPProcessing(spatialScale, ageScale, dataCSV, outputJSON)
    status = false;
    % This function resamples both single elements and ratios, then
    % produces a set of crossplots as well
    % This function is used for Mehra et al 2020 on provenance.
    % Run doing the following:
    %{
    spatialScale = 0.5;
    ageScale = 10;
    dataCSV = '0_data_files/matlabParsing/8.shalesFinalFilteredUSGSCutoffs.csv';
    outputJSON = false;
    SGPProcessing(spatialScale, ageScale, dataCSV, outputJSON)
    %}
    singleElements = ["Age", "Al2O3", "CaO", "TIC", "P2O5", "MgO", ...
            "Nd", "Sm", "Gd", "Tb", "Na2O", "K2O", "U", "Ca", "Cr", "Fe", ...
            "Fe2O3", "Mo", "V", "Ni", "Ti", "TiO2", "Th", "Rb", "Sc"];
    % Now, we list the numerator and denominators of ratios
    numeratorElements = ["Th", "Cr", "Y", "Ti", "Zr", "Th", "Th"];
    denominatorElements = ["Sc", "V", "Ni", "Al", "Sc", "Ni", "U"];
    % Also set bMin, bMax, nBins
    bMin = 0;
    bMax = 850;
    % Note that bin size is 25 Ma!
    nBins = bMax/25;
    singleElementsStruct = resampleSingleElementsData(spatialScale, ...
        ageScale, dataCSV, createElementsMap(singleElements), ["ciaCalcs"],  ...
        bMin, bMax, nBins, true, directoryTest("outputs/resamplingAfterFinalFiltering/singleElements"));
    ratiosStruct = resampleRatios(spatialScale, ...
        ageScale, dataCSV, numeratorElements, denominatorElements, ...
        bMin, bMax, nBins, true, directoryTest("outputs/resamplingAfterFinalFiltering/ratios"));
    % Okay, now, what cross plots would we like?
    crossplotsX = ["CIAStarApprox", "CIAStarApprox", "CIAStarApprox", "CIAStarApprox", "CIAStarApprox", "CIAStarApprox", "CIAStarApprox",  ...
        "Th/Sc", "Th/Sc", "Th/Sc", "Th/Sc", "Th/Sc", "Th/Sc", ...
        "Th/Sc", ...
        "TiO2", ...
        "Th/U", ...
        "Cr/V"];
    crossplotsY = ["Th/Sc", "Ni", "V", "Cr", "Mo", "Ti", "U", ...
        "Ni", "V", "Cr", "Mo", "Ti", "U", ...
        "Zr/Sc", ...
        "Al2O3", ...
        "Th", ...
        "Y/Ni"];
    % Okay, let's go ahead and make some crossplots!
    close all
    numCrossplots = length(crossplotsX);
    % If we're going to output JSON data, then we'll need several collectors
    if outputJSON
        crossPlots = cell(1, numCrossplots);
    end
    % First, list all the ratioStrings
    ratioStrings = generateRatioStrings(ratiosStruct.elementsStruct);
    for x = 1:numCrossplots
        figure
        % Now, determine whether to extract from singleElementsStruct or
        % ratiosStruct
        xVsYSpec = [crossplotsX(x), crossplotsY(x)];
        xVsYData = cell(2, 1);
        xVsYUpper = cell(2,1);
        xVsYLower = cell(2,1);
        for ax = 1:2
            if ismember(xVsYSpec(ax), ratioStrings)
                % So if this is a ratio...
                thisStruct = ratiosStruct;
            else
                thisStruct = singleElementsStruct;
            end
            colSpec = thisStruct.elementsStruct.elementsMap(xVsYSpec(ax));
            xVsYData{ax} = thisStruct.resampledAndBinned{2}(:, colSpec);
            xVsYUpper{ax} = thisStruct.resampledAndBinned{4}(:, colSpec) - xVsYData{ax};
            xVsYLower{ax} =  xVsYData{ax} - thisStruct.resampledAndBinned{5}(:, colSpec);
        end
        % Take the binCenters from anywhere
        bins = ratiosStruct.resampledAndBinned{1};
        hold on
        errorbar(xVsYData{1}, xVsYData{2}, xVsYLower{2}, xVsYUpper{2}, ...
            xVsYLower{1}, xVsYUpper{1}, 'o', 'Color', 'black');
        toColor = colormap(flipud(bone(length(bins))));
        scatter(xVsYData{1}, xVsYData{2}, [], bins, 'filled');
        pbaspect([1,1,1]);
        grid on
        titleSpec = strcat(xVsYSpec(1), " vs. ", strcat(xVsYSpec(2)));
        title(titleSpec, 'Interpreter', 'none');
        xlabel(xVsYSpec(1), 'Interpreter', 'none');
        ylabel(xVsYSpec(2), 'Interpreter', 'none');
        colorbar
        % Save 
        print(fullfile(directoryTest("outputs/resamplingAfterFinalFiltering/crossplots"), ...
                rectifyFilename(strcat(titleSpec, 'Resampled'))), '-painters', '-dpdf');
        % If JSON
        if outputJSON
            thisPlot = struct();
            thisPlot.x = xVsYData(1);
            thisPlot.y = xVsYData(2);
            thisPlot.lowerY = xVsYLower(2);
            thisPlot.lowerX = xVsYLower(1);
            thisPlot.upperY = xVsYUpper(2);
            thisPlot.upperX = xVsYUpper(1);
            crossPlots{x} = thisPlot;
        end
    end
    % Now, create a JSON object
    if outputJSON
        JSONStruct = struct();
        JSONStruct.crossplotsX = crossplotsX;
        JSONStruct.crossplotsY = crossplotsY;
        JSONStruct.crossplotsData = crossPlots;
        JSONStruct.ageBins = ratiosStruct.resampledAndBinned{1};
        % Now, encode
        encodedJSON =jsonencode(JSONStruct);
        % Write it
        fID = fopen('outputs/resamplingAfterFinalFiltering/crossplotsJSON.json', 'w');
        fprintf(fID, '%s', encodedJSON);
        fclose(fID);
    end
    status = true;
end