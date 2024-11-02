% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [succes, errorMessage, errorRows] = setDesignVariableRanges(project, ranges)
    % Set the ranges of the design variables in the project
    arguments
        project Project
        ranges (:,2) double
    end
    
    if (height(ranges) > AppConstants.MAX_DESIGN_VARIABLES)
        errorMessage = "The number of design variables cannot exceed " + AppConstants.MAX_DESIGN_VARIABLES;
        succes = false;
        errorRows = [];
        return;
    end
    if (height(ranges) < AppConstants.MIN_DESIGN_VARIABLES)
        errorMessage = "The number of design variables must be at least " + AppConstants.MIN_DESIGN_VARIABLES;
        succes = false;
        errorRows = [];
        return;
    end

    % Note that we still set the design ranges even if there are errors
    % as the user may want to correct the errors later
    project.varsDef.setDesignRanges(ranges);

    [errorRows, messages] = ParametersDefinition.validateDesignVariableRanges(ranges, project.varsDef.designVariables);
    succes = isempty(errorRows);
    if succes
        errorMessage = "";
    else
        errorMessage = messages(1); % Only show the first error due to space constraints
    end
    project.clearDOE();
end

