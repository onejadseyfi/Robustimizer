% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [succes, errorMessage, errorRows] = setNoiseVariableRanges(project, means, stdDevs)
    % Set the ranges of the noise variables in the project
    arguments
        project Project
        means (:,1) double
        stdDevs (:,1) double
    end

    if (height(means) ~= height(stdDevs))
        errorMessage = "The number of means and standard deviations must be equal";
        succes = false;
        errorRows = [];
        return;
    end

    if (height(means) > AppConstants.MAX_NOISE_VARIABLES)
        errorMessage = "The number of noise variables cannot exceed " + AppConstants.MAX_NOISE_VARIABLES;
        succes = false;
        errorRows = [];
        return;
    end

    if (height(means) < AppConstants.MIN_NOISE_VARIABLES)
        errorMessage = "The number of noise variables must be at least " + AppConstants.MIN_NOISE_VARIABLES;
        succes = false;
        errorRows = [];
        return;
    end

    % Note that we still set the requested values even if there are errors
    % as the user may want to correct the errors later
    project.noiseSource = NoiseDataSource(means, stdDevs);
    project.varsDef.setNoiseRanges(project.noiseSource.ranges);

    ranges = project.varsDef.noiseRanges;
    names = project.varsDef.noiseVariables;
    [errorRows, messages] = ParametersDefinition.validateNoiseVariableRanges(ranges, names);
    succes = isempty(errorRows);
    if succes
        errorMessage = "";
    else
        errorMessage = messages(1); % Only show the first error due to space constraints
    end
    project.clearDOE();
end
