% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setResultsGeneratorScript(project, fileName)
    % Set the script to generate the output values from the DOE
    %
    % project: Project
    % fileName: file name of the executable
    arguments
        project Project
        fileName string
    end

    project.scriptFileName = fileName;
end
