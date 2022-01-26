function resampledData = ciaCalcs(resampledData, elementsStruct)
    % Let's take this resampledData and make some corrections
    % For ease of reading, let's set elementsMap
    elementsMap = elementsStruct.elementsMap;
    % Some intermediate values
    % Not fully DRY!
    % ciaCalcs just strings together a set of calls to CaOCalcs and CIA and WIP
    [CaOStar, CaOStarApprox, CaOStarHybrid] = CaOCalcs(resampledData(:, elementsMap("Na2O")), ...
        resampledData(:, elementsMap("TIC")), ...
        resampledData(:, elementsMap("CaO")), ...
        resampledData(:, elementsMap("P2O5")));
    % Add accurate silicate CaO
    resampledData(:, elementsMap("CaOStar")) = CaOStar;
    % Approximate silicate CaO
    resampledData(:, elementsMap("CaOStarApprox")) = CaOStarApprox;
    % Hybrid CaO
    resampledData(:, elementsMap("CaOStarHybrid")) = CaOStarHybrid;
    % Calculated variables...stored in the dataset
    resampledData(:, elementsMap("CIAUncorr")) = ...
        calculateCIA(resampledData(:, elementsMap("Al2O3")), resampledData(:, elementsMap("CaO")), resampledData(:, elementsMap("Na2O")), resampledData(:, elementsMap("K2O")));
    resampledData(:, elementsMap("CIAStar")) = ...
        calculateCIA(resampledData(:, elementsMap("Al2O3")), resampledData(:, elementsMap("CaOStar")), resampledData(:, elementsMap("Na2O")), resampledData(:, elementsMap("K2O")));
    resampledData(:, elementsMap("CIAStarApprox")) = ...
        calculateCIA(resampledData(:, elementsMap("Al2O3")), resampledData(:, elementsMap("CaOStarApprox")), resampledData(:, elementsMap("Na2O")), resampledData(:, elementsMap("K2O")));
     resampledData(:, elementsMap("CIAStarHybrid")) = ...
        calculateCIA(resampledData(:, elementsMap("Al2O3")), resampledData(:, elementsMap("CaOStarHybrid")), resampledData(:, elementsMap("Na2O")), resampledData(:, elementsMap("K2O")));
    resampledData(:, elementsMap("WIP")) = ...
        calculateWIP(resampledData(:, elementsMap("Na2O")), resampledData(:, elementsMap("MgO")), resampledData(:, elementsMap("K2O")), resampledData(:, elementsMap("CaO")));
end
