% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setConstraintType(project, type, i)
    arguments
        project Project
        type ConstraintType
        i   int32
    end
    project.constraintSpec(i,1).type = type;
    project.clearOptimizationResults();
end