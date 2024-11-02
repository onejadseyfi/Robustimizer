% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = saveOutputValues(project, fileName)
    % Save output values to a file
    %
    % project: Project
    % fileName: file name
    arguments
        project Project
        fileName string
    end

    [success, errorMessage] = saveAsTabSeparated(fileName, project.outputVal);
end