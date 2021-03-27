function dataset = screenData(dataset)

dataset.SiO2((dataset.SiO2 >= 100) | (dataset.SiO2 <= 1e-2)) = NaN;
dataset.TiO2((dataset.TiO2 >= 30) | (dataset.TiO2 <= 1e-4)) = NaN;
dataset.Al2O3((dataset.Al2O3 >= 50) | (dataset.Al2O3 <= 2e-3)) = NaN;
dataset.Fe2O3((dataset.Fe2O3 >= 100) | (dataset.Fe2O3 <= 1e-2)) = NaN;
dataset.FeO((dataset.FeO >= 100) | (dataset.FeO <= 1e-2)) = NaN;
dataset.FeOT((dataset.FeOT >= 100) | (dataset.FeOT <= 1e-2)) = NaN;
dataset.FeOT((dataset.FeOT >= 100) | (dataset.FeOT <= 1e-2)) = NaN;
dataset.MgO((dataset.MgO >= 48) | (dataset.MgO <= 1e-2)) = NaN; % 48% is pure MgCO3
dataset.CaO((dataset.CaO >= 57) | (dataset.CaO <= 1e-3)) = NaN; % 57% is pure CaCO3
dataset.Na2O((dataset.Na2O >= 58) | (dataset.Na2O <= 1e-3)) = NaN; % 58% is pure Na2CO3
dataset.K2O((dataset.K2O >= 68) | (dataset.K2O <= 1e-3)) = NaN; % 68% is pure K2CO3
dataset.P2O5((dataset.P2O5 >= 100) | (dataset.P2O5 <= 2e-3)) = NaN;
dataset.MnO((dataset.MnO >= 62) | (dataset.MnO <= 1e-4)) = NaN; % 61.7 is pure MnCO3
dataset.TIC((dataset.TIC >= 14.245) | (dataset.TIC <= 1e-2)) = NaN; % 14.245% is C in pure MgCO3 (c.f. 12.001% in CaCO3)
dataset.TOC((dataset.TOC >= 100) | (dataset.TOC <= 1e-3)) = NaN;
dataset.TC((dataset.TC >= 100) | (dataset.TC <= 1e-3)) = NaN; % "Total Carbon"

% Metals. Units = PPM:
dataset.La((dataset.La >= 1e4) | (dataset.La <= 1e-1)) = NaN;
dataset.Ce((dataset.Ce >= 1e4) | (dataset.Ce <= 1e-1)) = NaN;
dataset.Pr((dataset.Pr >= 1e3) | (dataset.Pr <= 1e-2)) = NaN;
dataset.Nd((dataset.Nd >= 2e3) | (dataset.Nd <= 2e-2)) = NaN;
dataset.Sm((dataset.Sm >= 1e3) | (dataset.Sm <= 1e-2)) = NaN;
dataset.Eu((dataset.Eu >= 1e2) | (dataset.Eu <= 1e-3)) = NaN;
dataset.Gd((dataset.Gd >= 1e3) | (dataset.Gd <= 1e-2)) = NaN;
dataset.Tb((dataset.Tb >= 1e2) | (dataset.Tb <= 1e-3)) = NaN;
dataset.Dy((dataset.Dy >= 1e3) | (dataset.Dy <= 1e-2)) = NaN;
dataset.Ho((dataset.Ho >= 1e2) | (dataset.Ho <= 1e-2)) = NaN;
dataset.Er((dataset.Er >= 1e3) | (dataset.Er <= 1e-2)) = NaN;
dataset.Tm((dataset.Tm >= 2e2) | (dataset.Tm <= 2e-3)) = NaN;
dataset.Yb((dataset.Yb >= 2e2) | (dataset.Yb <= 1e-2)) = NaN;
dataset.Lu((dataset.Lu >= 1e2) | (dataset.Lu <= 1e-3)) = NaN;
dataset.Hf((dataset.Hf >= 1e3) | (dataset.Hf <= 1e-2)) = NaN;
dataset.Y((dataset.Y >= 1e3) | (dataset.Y <= 1e-2)) = NaN;

dataset.Ba((dataset.Ba >= 588420) | (dataset.Ba <= 1e0)) = NaN; % 588420 PPM is Ba in BaSO4
dataset.Sr((dataset.Sr >= 447038.) | (dataset.Sr <= 1e0)) = NaN; % 447038 PPM is Sr in SrSO4
dataset.Rb((dataset.Rb >= 1e3) | (dataset.Rb <= 1e-2)) = NaN;
dataset.Be((dataset.Be >= 2e2) | (dataset.Be <= 1e-2)) = NaN;
dataset.Co((dataset.Co >= 2e3) | (dataset.Co <= 1e-2)) = NaN;
dataset.Cr((dataset.Cr >= 1e4) | (dataset.Cr <= 1e-1)) = NaN;
dataset.Cs((dataset.Cs >= 2e2) | (dataset.Cs <= 2e-3)) = NaN;
dataset.Ge((dataset.Ge >= 1e3) | (dataset.Ge <= 1e-3)) = NaN;

% Suspicious elements
dataset.Li((dataset.Li >= 1e4) | (dataset.Li <= 1e-1)) = NaN; % Check for PPB
dataset.Mo((dataset.Mo >= 1e4) | (dataset.Mo <= 1e-2)) = NaN; % Check for PPB
dataset.Nb((dataset.Nb >= 2e2) | (dataset.Nb <= 2e-2)) = NaN; % Check for PPB
dataset.Ni((dataset.Ni >= 1e4) | (dataset.Ni <= 1e-1)) = NaN; % Check for PPB
dataset.Pb((dataset.Pb >= 3e4) | (dataset.Pb <= 2e-2)) = NaN; % Check for PPB
dataset.Sc((dataset.Sc >= 1e3) | (dataset.Sc <= 1e-2)) = NaN; % Check for PPB
dataset.Sn((dataset.Sn >= 1e3) | (dataset.Sn <= 1e-2)) = NaN; % Check for PPB
dataset.Th((dataset.Th >= 1e4) | (dataset.Th <= 1e-2)) = NaN; % Check for PPB
dataset.Cu((dataset.Cu >= 1e3) | (dataset.Cu <= 1e0)) = NaN; % Check for PPB
dataset.Ga((dataset.Ga >= 2e2) | (dataset.Ga <= 2e-2)) = NaN;  % Check for PPB
dataset.Ag((dataset.Ag >= 1e1) | (dataset.Ag <= 1e-3)) = NaN;  % Check for PPB. UCC is < 0.01 PPM
dataset.As((dataset.As >= 1e2) | (dataset.As <= 1e-3)) = NaN;  % Check for PPB.
dataset.Au((dataset.Au >= 1e-1) | (dataset.Au <= 1e-5)) = NaN;  % Check for PPB
dataset.Bi((dataset.Bi >= 3e0) | (dataset.Bi <= 1e-4)) = NaN;  % Check for PPB
dataset.Cd((dataset.Cd >= 1e3) | (dataset.Cd <= 1e-4)) = NaN;  % Check for PPB
dataset.Cu((dataset.Cu >= 1e5) | (dataset.Cu <= 1e-2)) = NaN;  % Check for PPB
dataset.Hg((dataset.Hg >= 2e2) | (dataset.Hg <= 1e-4)) = NaN;  % Check for PPB
dataset.In((dataset.In >= 1e2) | (dataset.In <= 1e-4)) = NaN;  % Check for PPB
dataset.Re((dataset.Re >= 1e1) | (dataset.Re <= 1e-4)) = NaN;  % Check for PPB
dataset.Sc((dataset.Sc >= 1e3) | (dataset.Sc <= 1e-2)) = NaN;  % Check for PPB
dataset.Se((dataset.Se >= 1e4) | (dataset.Se <= 1e-2)) = NaN;  % Check for PPB
dataset.Ta((dataset.Ta >= 1e1) | (dataset.Ta <= 1e-3)) = NaN;  % Check for PPB
dataset.Te((dataset.Te >= 1e2) | (dataset.Te <= 1e-3)) = NaN;  % Check for PPB
dataset.Tl((dataset.Tl >= 1e2) | (dataset.Tl <= 1e-3)) = NaN;  % Check for PPB
dataset.U((dataset.U >= 1e5) | (dataset.U <= 1e-2)) = NaN;  % Check for PPB
dataset.V((dataset.V >= 1e5) | (dataset.V <= 1e-2)) = NaN;  % Check for PPB
dataset.W((dataset.W >= 1e3) | (dataset.W <= 1e-2)) = NaN;  % Check for PPB
dataset.Zn((dataset.Zn >= 1e5) | (dataset.Zn <= 1e-1)) = NaN;  % Check for PPB
dataset.Zr((dataset.Zr >= 3e3) | (dataset.Zr <= 1e-1)) = NaN;  % Check for PPB

% Elements that may be converted from oxides
dataset.Si((dataset.Si >= 467437.) | (dataset.Si <= 1e2)) = NaN; % 467437 PPM is Si in SiO2
dataset.Ti((dataset.Ti >= 2e4) | (dataset.Ti <= 1e0)) = NaN; % Maybe reassess after converting oxides to metals as well
dataset.Al((dataset.Al >= 529258.) | (dataset.Al <= 1e2)) = NaN; % 529258 PPM is Al in Al2O3
dataset.Fe((dataset.Fe >= 777310.) | (dataset.Fe <= 1e2)) = NaN; % 777310 PPM is Fe in FeO
dataset.Ca((dataset.Ca >= 400438.) | (dataset.Ca <= 1e1)) = NaN; % 400438 PPM is Ca in CaCO3
dataset.Mg((dataset.Mg >= 288271.) | (dataset.Mg <= 1e1)) = NaN; % 288271 PPM is Mg in MgCO3
dataset.Mn((dataset.Mn >= 477946) | (dataset.Mn <= 1e0)) = NaN; % 477946 PPM is pure MnCO3
dataset.Na((dataset.Na >= 433820.) | (dataset.Na <= 1e1)) = NaN; % 433820 PPM is Na in Na2CO3
dataset.K((dataset.K >= 565803.) | (dataset.K <= 1e1)) = NaN; % 565803 PPM is K in K2CO3
dataset.P((dataset.P >= 436429.) | (dataset.P <= 1e1)) = NaN; % 436429 PPM is P in P2O5
dataset.C((dataset.C >= 1e6) | (dataset.C <= 1e1)) = NaN;

% Isotopes
dataset.DELTA_C13_ORG((dataset.DELTA_C13_ORG >= 0) | (dataset.DELTA_C13_ORG <= -60)) = NaN;  % Includes everything
dataset.DELTA_C13_CARB((dataset.DELTA_C13_CARB >= 30) | (dataset.DELTA_C13_CARB <= -30)) = NaN;  % Includes everything
dataset.DELTA_N15((dataset.DELTA_N15 >= 30) | (dataset.DELTA_N15 <= -30)) = NaN; % Includes everything
dataset.DELTA_S34_PY((dataset.DELTA_S34_PY >= 100) | (dataset.DELTA_S34_PY <= -100)) = NaN;  % Includes everything
dataset.DELTA_S34_CAS((dataset.DELTA_S34_CAS >= 1000) | (dataset.DELTA_S34_CAS <= 0)) = NaN;  % Includes everything
dataset.DELTA_S34_GYP((dataset.DELTA_S34_GYP >= 1000) | (dataset.DELTA_S34_GYP <= 0)) = NaN;  % Includes everything
dataset.DELTA_S34_OBS((dataset.DELTA_S34_OBS >= 100) | (dataset.DELTA_S34_OBS <= -100)) = NaN;  % Includes everything
dataset.DELTA_S34_BULK((dataset.DELTA_S34_BULK >= 100) | (dataset.DELTA_S34_BULK <= -100)) = NaN;  % Includes everything
dataset.DELTA_Mo98((dataset.DELTA_Mo98 >= 30) | (dataset.DELTA_Mo98 <= -10)) = NaN; % Includes everything. I know nothing about this
dataset.Sr87_Sr86((dataset.Sr87_Sr86 >= 0.73) | (dataset.Sr87_Sr86 <= 0.7)) = NaN; % Includes everything
dataset.Nd143_Nd144((dataset.Nd143_Nd144 >= 0.52) | (dataset.Nd143_Nd144 <= 0.50)) = NaN; % Includes everything
dataset.Os187_Os188I((dataset.Os187_Os188I >= 3) | (dataset.Os187_Os188I <= 1e-3)) = NaN;
dataset.DELTA_U238((dataset.DELTA_U238 >= 1) | (dataset.DELTA_U238 <= -1)) = NaN;

end