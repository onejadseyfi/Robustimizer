% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setConstraintTargetValue(project, targetValue, i)
    % Set the target value of the objective function
    %
    % project: Project
    % targetValue: double
    arguments
        project Project
        targetValue double
        i   int32
    end

    project.constraintSpec(i,1).value = targetValue;
    project.clearOptimizationResults();
end