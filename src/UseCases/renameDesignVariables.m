% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [succeeded, errorMessage] = renameDesignVariables(project, newNames)
    if length(newNames) < AppConstants.MIN_DESIGN_VARIABLES
        errorMessage = "The number of design variables must be at least " + AppConstants.MIN_DESIGN_VARIABLES;
        succeeded = false;
        return;
    end
    if length(newNames) > AppConstants.MAX_DESIGN_VARIABLES
        errorMessage = "The number of design variables cannot exceed " + AppConstants.MAX_DESIGN_VARIABLES;
        succeeded = false;
        return;
    end

    [succeeded, errorMessage] = project.varsDef.areValidParameterNames(newNames);
    if succeeded
        project.varsDef.setDesignVariables(newNames);
        project.clearDOE();
    end
end
