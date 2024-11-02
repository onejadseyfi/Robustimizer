% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setConstraintIncludeSkewness(project, includeSkewness,i)
    % Set whether to include skewness in the objective function
    %
    % project: Project
    % includeSkewness: boolean
    arguments
        project Project
        includeSkewness logical
        i   int32
    end

    project.constraintSpec(i,1).includeSkewness = includeSkewness;
    project.clearOptimizationResults();
end