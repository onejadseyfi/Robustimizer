% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [finishedOK, errorMessage] = runSelectedScript(executablePath, options)
    % Run a script and wait for it to finish
    %
    % Wrapper around runSubprocess() that captures any exceptions and returns
    % a boolean indicating whether the script finished successfully. 
    arguments
        executablePath string
        options.on_output function_handle {mustBeScalarOrEmpty} = function_handle.empty
        options.cancel_requested function_handle {mustBeScalarOrEmpty} = function_handle.empty
    end
    try
        % We set the working directory for the subprocess to the directory
        % containing the executable script, so that we are independent of 
        % the current working directory.
        [dir, ~, ~] = fileparts(executablePath);
        [status, ~] = runSubprocess(executablePath, ...
            'on_output', options.on_output, ...
            'cancel_requested', options.cancel_requested, ...
            'cwd', dir);
        finishedOK = (status == 0);
        if ~finishedOK
            errorMessage = "Received a non-zero exit status, " ...
                + "this usually indicates an error " ...
                + "while executing " + executablePath;
        else
            errorMessage = "";
        end
    catch exception
        finishedOK = false;
        errorMessage = exception.message;
    end
end