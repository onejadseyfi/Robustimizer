% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = importMCSample(project, fileName)
    % Import the Monte Carlo sample from a file
    %
    % project: Project
    % fileName: file name
    arguments
        project Project
        fileName string
    end

    % Attempt to read the file
    [data, success, errorMessage] = loadTabSeparated(fileName);
    if ~success
        errorMessage = "Failed to load Monte Carlo sample: " + errorMessage;
        return;
    end

    if height(data) < AppConstants.MIN_MC_SIZE
        errorMessage = "Monte Carlo sample must have at least " + AppConstants.MIN_MC_SIZE + " rows";
        success = false;
        return;
    end
    if height(data) > AppConstants.MAX_MC_SIZE
        errorMessage = "Monte Carlo sample must have at most " + AppConstants.MAX_MC_SIZE + " rows";
        success = false;
        return;
    end

    project.optSettings.nMC = size(data, 1);
    project.optSettings.noiDesOfExp = data;
end