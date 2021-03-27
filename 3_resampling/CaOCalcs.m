function [CaOStar, CaOStarApprox] = CaOCalcs(Na2O, TIC, CaO, P2O5)
    % CaOcalcs takes in Na2O, TIC, CaO, P2O5 and then returns 
    % CaOStar and CaO Approx
    % CaO if molar Ca = Na
    CaONaEquiv = Na2O * (56.0774 / 30.989269282);
    % Assuming all TIC is as CaCO3; less if CaMgCO3
    CaOCarbonate = TIC * (1 / 12.011) * (56.0774);
    % CaO in carbonate cannot be greater than total CaO
    CaOCarbonate(CaOCarbonate > CaO) = ...
        CaO(CaOCarbonate > CaO);
    % Assuming all P is as CaPO4
    CaOApatite = P2O5 * (2 / 141.942523997) * (56.0774);
    % CaO in apatite cannot be greater than total CaO
    CaOApatite(CaOApatite > CaO) = ...
        CaO(CaOApatite > CaO);
    % Non-silicate CaO
    CaONonSilicate = CaOApatite + CaOCarbonate;
    % Non-silicate CaO cannot be greater than total CaO
    CaONonSilicate(CaONonSilicate > CaO) = ...
        CaO(CaONonSilicate > CaO);
    % So now, accurate silicate CaO
    CaOStar = CaO - CaONonSilicate;
    % Approximate silicate CaO
    CaOStarApprox = ...
        nanmin([CaO - CaOApatite, CaONaEquiv], [], 2);
end