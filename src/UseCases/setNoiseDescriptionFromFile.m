% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [succeeded, errorMessage] = setNoiseDescriptionFromFile(project, fileName)
    % Set the noise description from a file
    arguments
        project Project
        fileName string
    end

    try
        realData = importdata(fileName);
        succeeded = true;
    catch ex
        errorMessage = "Could not read file " + fileName;
        succeeded = false;
        return;
    end
    
    nNoiseVars = size(realData, 2);

    if nNoiseVars < AppConstants.MIN_NOISE_VARIABLES
        errorMessage = "The number of noise variables must be at least " + AppConstants.MIN_NOISE_VARIABLES;
        succeeded = false;
        return;
    end
    if nNoiseVars > AppConstants.MAX_NOISE_VARIABLES
        errorMessage = "The number of noise variables cannot exceed " + AppConstants.MAX_NOISE_VARIABLES;
        succeeded = false;
        return;
    end

    succeeded = true;
    errorMessage = "";

    project.noiseSource.initializeFromInputData(realData);
    project.varsDef.setNoiseVariables("PC " + (1:nNoiseVars));
    project.varsDef.setNoiseRanges(project.noiseSource.ranges);
    project.clearDOE();
end