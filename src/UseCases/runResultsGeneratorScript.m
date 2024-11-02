% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = runResultsGeneratorScript(project, options)
    % Run the script to generate the output values from the DOE
    % Note: This function is blocking and will wait until the script has finished.
    %
    % project: Project
    % options: struct
    %   - on_output: function_handle, called when the script writes to stdout
    %   - cancel_requested: function_handle, called to check if the user has requested to cancel
    arguments
        project Project
        options.on_output function_handle {mustBeScalarOrEmpty} = function_handle.empty
        options.cancel_requested function_handle {mustBeScalarOrEmpty} = function_handle.empty
    end

    errorMessage = "";
    if ~isfile(project.scriptFileName)
        errorMessage = 'Script file not found';
        success = false;
        return;
    end

    filenameIn  = inputDataFilePath(project.scriptFileName);
    filenameOut = outputDataFilePath(project.scriptFileName);
    delete(filenameOut);

    [success, err] = saveAsTabSeparated(filenameIn, project.DOE);
    if ~success
        errorMessage = "Failed to save DOE to working directory:\n" + err;
        return;
    end

    [success, err] = runSelectedScript(project.scriptFileName, ...
        'on_output', options.on_output, ...
        'cancel_requested', options.cancel_requested);
    if ~success
        errorMessage = "Something went wrong:\n" + err;
        return;
    end

    fileWasFound = waitUntilFileExists(filenameOut, 3, 0.5);
    if ~fileWasFound
        errorMessage = "no output file was generated!";
        success = false;
        return;
    end

    [success, err] = importResults(project, filenameOut);
    if ~success
        errorMessage = "Failed to load results:\n" + err;
    else
        project.clearSurrogateModel();
    end
end

% Helper functions

function filepath = inputDataFilePath(executable)
    filepath = inSameDirAs(executable, 'in.txt');
end

function filepath = outputDataFilePath(executable)
    filepath = inSameDirAs(executable, 'out.txt');
end

