% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setObjectiveFunctionTargetValue(project, targetValue)
    % Set the target value of the objective function
    %
    % project: Project
    % targetValue: double
    arguments
        project Project
        targetValue double
    end

    project.optSettings.objectiveFuncSpec.targetValue = targetValue;
    project.clearOptimizationResults();
end