% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [succeeded, errorMessage] = renameNoiseVariables(project, newNames)
    if length(newNames) < AppConstants.MIN_NOISE_VARIABLES
        errorMessage = "The number of noise variables must be at least " + AppConstants.MIN_NOISE_VARIABLES;
        succeeded = false;
        return;
    end
    if length(newNames) > AppConstants.MAX_NOISE_VARIABLES
        errorMessage = "The number of noise variables cannot exceed " + AppConstants.MAX_NOISE_VARIABLES;
        succeeded = false;
        return;
    end

    [succeeded, errorMessage] = project.varsDef.areValidParameterNames(newNames);
    if succeeded
        project.varsDef.setNoiseVariables(newNames);        
        project.clearDOE();
    end
end
