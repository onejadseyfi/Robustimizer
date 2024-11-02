% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = importDOE(project, fileName)
    % Import a design of experiments (DOE) from a file
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
        return;
    end

    % Validate 
    nDOEPoints = height(data);
    columns = width(data);
    if nDOEPoints < AppConstants.MIN_DOE_SIZE
        errorMessage = 'Minimum DOE size is ' + AppConstants.MIN_DOE_SIZE;
    elseif nDOEPoints > AppConstants.MAX_DOE_SIZE
        errorMessage = 'Maximum DOE size is ' + AppConstants.MAX_DOE_SIZE;
    elseif project.varsDef.count ~= columns
        errorMessage = 'The number of columns does not match the total number of variables'; 
    end
    success = isempty(errorMessage);

    if success
        project.DOE = data;
        project.simulResDOE = data;
        project.clearOutputValues();
    end
end