% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setObjectiveFunctionIncludeSkewness(project, includeSkewness)
    % Set whether to include skewness in the objective function
    %
    % project: Project
    % includeSkewness: boolean
    arguments
        project Project
        includeSkewness logical
    end

    project.optSettings.objectiveFuncSpec.includeSkewness = includeSkewness;
    project.clearOptimizationResults();
end