% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage, project] = loadProject(fileName)
    % Load project from file
    project = Project();
    try
        data = load(fileName, '-mat');
    catch
        % Lower level error, e.g. file not found.
        success = false;
        errorMessage = sprintf("Error loading project from file %s: %s", fileName, exception.message);
        return
    end

    % Before Robustimizer 2024.1, the file structure was very different.
    if ~isfield(data, 'applicationName') || ~isfield(data, 'applicationVersion')
        success = false;
        errorMessage = sprintf("This file is not a valid %s project file.", AppConstants.APPLICATION_NAME);
        return
    end
    if data.applicationName ~= AppConstants.APPLICATION_NAME
        success = false;
        errorMessage = sprintf("This file is not a valid %s project file.", AppConstants.APPLICATION_NAME);
        return
    end

    % Check if too old
    fileVersion = data.fileVersion;
    if fileVersion < AppConstants.FILEFORMAT_MIN_SUPPORTED_VERSION
        success = false;
        errorMessage = "The file was saved by a too old version of the application and cannot be loaded.";
        return
    end

    % Check if too new
    if fileVersion > AppConstants.FILEFORMAT_MAX_SUPPORTED_VERSION
        success = false;
        errorMessage = "The file was saved by a newer version of the application and cannot be loaded.";
        return
    end

    if fileVersion < AppConstants.FILEFORMAT_VERSION
        % Implement upgrade mechanism here (preferably in a separate function)
        % For now, just show a warning
        warning("The file was saved by an older version of the application. Some data may be lost.");
    end
    if fileVersion > AppConstants.FILEFORMAT_VERSION
        % Implement downgrade mechanism here (preferably in a separate function)
        % For now, just show a warning
        warning("The file was saved by a newer version of the application. Some data may be lost.");
    end

    project = data.project;
    errorMessage = "";
    success = true;
end