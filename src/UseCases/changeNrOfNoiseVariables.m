% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = changeNrOfNoiseVariables(project, newNrOfVariables)
    % Change the number of noise variables in the project
    arguments
        project Project
        newNrOfVariables (1,1) double
    end

    if newNrOfVariables < AppConstants.MIN_NOISE_VARIABLES
        errorMessage = "The number of noise variables must be at least " + AppConstants.MIN_NOISE_VARIABLES;
        success = false;
        return;
    end
    if newNrOfVariables > AppConstants.MAX_NOISE_VARIABLES
        errorMessage = "The number of noise variables cannot exceed " + AppConstants.MAX_NOISE_VARIABLES;
        success = false;
        return;
    end

    errorMessage = "";
    success = true;
    if newNrOfVariables == project.varsDef.nNoiseVars
        return;
    end

    project.noiseSource.resize(newNrOfVariables);
    project.varsDef.setNoiseRanges(project.noiseSource.ranges);

    % Clear downstream dependencies, as they are no longer valid
    project.clearDOE();
end