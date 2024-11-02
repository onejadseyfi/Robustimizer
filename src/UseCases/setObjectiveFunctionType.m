% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setObjectiveFunctionType(project, type)
    arguments
        project Project
        type ObjectiveFunctionType
    end
    project.optSettings.objectiveFuncSpec.type = type;
    project.clearOptimizationResults();
end