% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = exportDOE(project, fileName)
    % Export the design of experiments (DOE) to a file
    %
    % fileName: file name
    arguments
        project Project
        fileName string
    end

    [success, errorMessage] = saveAsTabSeparated(fileName, project.DOE);
end