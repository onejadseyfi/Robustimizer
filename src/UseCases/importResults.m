% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = importResults(project, fileName)
    % Import results from a file
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
    nResults = height(data);
    nCols = width(data);
    nResponses = length(project.outputNames);

    if nCols < 1
        errorMessage = 'No data found in the file.';
        success = false;
        return
    end

    if nResults ~= height(project.DOE)
        errorMessage = sprintf("Dimensions of DOE (%d rows) and output (%d rows) do not match. Please provide a correct output.", ...
                               height(project.DOE), nResults);
        success = false;
        return
    end

    if nCols ~= nResponses
        errorMessage = sprintf("The number of columns in the file (%d) does not match the number of responses (%d).", ...
                               nCols, nResponses);
        success = false;
        return
    end

    project.outputVal = data;

    project.clearSurrogateModel();
end