% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [seqMthdNum] = seqMethodNrFor(infillMethod)
    arguments
        infillMethod (1,1) SeqUpdateType
    end
    switch infillMethod
        case SeqUpdateType.JonesCriteria
            seqMthdNum = 1;
        case SeqUpdateType.MaxUncertaintyObj
            seqMthdNum = 2;
        case SeqUpdateType.AtRobustOpt
            seqMthdNum = 3;
        otherwise
            error("Unsupported infill method selected");
    end
end