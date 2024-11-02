% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = changeNrOfDesignVariables(project, newNrOfVariables)
    % Change the number of design variables in the project
    arguments
        project Project
        newNrOfVariables (1,1) double
    end

    if newNrOfVariables < AppConstants.MIN_DESIGN_VARIABLES
        errorMessage = "The number of design variables must be at least " + AppConstants.MIN_DESIGN_VARIABLES;
        success = false;
        return;
    end
    if newNrOfVariables > AppConstants.MAX_DESIGN_VARIABLES
        errorMessage = "The number of design variables cannot exceed " + AppConstants.MAX_DESIGN_VARIABLES;
        success = false;
        return;
    end

    errorMessage = "";
    success = true;
    if newNrOfVariables == project.varsDef.nDesignVars
        return;
    end

    project.varsDef.resizeDesignVariables(newNrOfVariables);

    % Clear downstream dependencies, as they are no longer valid
    project.clearDOE();
end