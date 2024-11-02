% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef SeqUpdateType
    enumeration
        JonesCriteria
        MaxUncertaintyObj  % Maximum uncertainty of objective function
        AtRobustOpt        % At robust optimum design
    end
end