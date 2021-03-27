function CIA = calculateCIA(Al2O3, CaO, Na2O, K2O)
    % All we're doing here is calculating CIA...
    A = Al2O3 / 101.96007714;
    C = CaO / 56.0774;
    N = Na2O / 61.978538564;
    K = K2O / 94.19562;
    CIA = (A ./ (A + C + N + K)) * 100;
end