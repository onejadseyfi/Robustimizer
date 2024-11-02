% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function fileExists = waitUntilFileExists(filepath, timeout, pollInterval)
    % waitUntilFileExists - Wait until a file exists or a timeout is reached.
    %
    % Inputs:
    %  filepath: A string specifying the path to the file to wait for.
    %  timeout: A numeric value specifying the maximum time to wait in seconds.
    %  pollInterval: A numeric value specifying the interval at which to poll for the file in seconds.
    startTime = datetime('now');
    fileExists = isfile(filepath);
    now = datetime('now');
    while ~fileExists && (now - startTime) > seconds(timeout)
        pause(pollInterval)
        fileExists = isfile(filepath);
        now = datetime('now');
    end
end
