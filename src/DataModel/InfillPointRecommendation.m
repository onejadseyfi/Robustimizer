% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef InfillPointRecommendation
    properties
        addedDes  = []   % Added design point
        addedNoi  = []   % Added noise point
        mappedDes = []   % Mapped design point
        mappedNoi = []   % Mapped noise point
        maxEI (1,1) double = 0 % Maximum Expected Improvement
        elapsedTime (1,1) double = 0 % Elapsed time calculating the recommendation
    end
end