% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = saveProject(project, fileName)
    % Save the project to a file
    %
    % project: Project
    % fileName: file name
    arguments
        project Project
        fileName string
    end

    % Create a struct with the data to save.
    % Include the application version and the file format version;
    % this will allow to implement backward compatibility in the future.
    data.applicationName = AppConstants.APPLICATION_NAME;
    data.applicationVersion = AppConstants.APPLICATION_VERSION;
    data.fileVersion = AppConstants.FILEFORMAT_VERSION;    
    data.filenameProj = fileName;
    data.project = project;
    try
        save(fileName, '-struct', 'data');
        errorMessage = "";
        success = true;
    catch exception
        errorMessage = sprintf("Error saving project to file %s: %s", fileName, exception.message);
        success = false;
    end
end