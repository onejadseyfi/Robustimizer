% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [Con, skewConIncl, nSigSkewCon] = convertConstraintSpecs(constraintSpec)
    arguments
        constraintSpec (:,1) ConstraintSpecification
    end

    if ~isempty(constraintSpec)
        counterNameG=0;
        counterNameH=0;
        nSigSkewCon=[];
        for ic = 1:length(constraintSpec)
            constraint = constraintSpec(ic);
            if constraint.type == ConstraintType.Equality
                counterNameH = counterNameH + 1;
                counter = counterNameH;
            else
                counterNameG = counterNameG + 1;
                counter = counterNameG;
            end
            Con(ic).name = constraint.namePrefix + counter;
            Con(ic).con = constraint.formula(ic);
            skewConIncl(ic) = constraint.includeSkewness;
            if constraint.includeSkewness
                nSigSkewCon(ic) = abs(constraint.sigmaLevel);
            end
        end
    else
        Con = [];
        skewConIncl = [];
        nSigSkewCon = [];
    end
end
