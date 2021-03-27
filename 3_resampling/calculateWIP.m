function WIP = calculateWIP(Na2O, MgO, K2O, CaO)
    % "Weathering Index of Parker"
    Na = Na2O / 30.9895;
    Mg = MgO / 40.3044;
    K = K2O / 47.0980;
    Ca = CaO / 56.0774;
    % Denominator for each element is a measure of Nicholls' bond strengths
    WIP = (Na/0.35 + Mg/0.9 + K/0.25 + Ca/0.7) * 100;
end