% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setConstraintSigmaLevel(project, sigmaValue, i)
    % Set the sigma level for the i-th constraint in the project    
    arguments
        project Project
        sigmaValue double
        i   int32
    end

    project.constraintSpec(i,1).sigmaLevel = sigmaValue;
    project.clearOptimizationResults();
end