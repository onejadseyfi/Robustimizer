% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
% loadTabSeparated - Load data from a file saved as tab-separated values.
%
% Syntax:
%   [data, didLoad, errorMessage] = loadTabSeparated(filepath)
%
% Inputs:
%   - filepath: A string specifying the path to the file from where the data will be loaded.
%
% Outputs:
%   - data: The data loaded from the file.
%   - didLoad: A logical value indicating whether the data was successfully loaded (true) or not (false).
%   - errorMessage: A string containing an error message when an error occurred during the loading process.
%
% Example:
%   filepath = 'data.txt';
%   [data, didLoad, errorMessage] = loadTabSeparated(filepath);
%
%   if didLoad
%       disp('Data loaded successfully.');
%   else
%       disp(['Error loading data: ' errorMessage]);
%   end
%
% Notes:
%   - The function loads the data as tab-separated values (TSV) from the specified file.
%   - If the file does not exist or an error occurred during the loading process, the error message will be
%     returned in the 'errorMessage' output argument. 'data' will be empty in this case.
function [data, didLoad, errorMessage] = loadTabSeparated(filepath)
    arguments
        filepath (1,1) string
    end
    try
        data = readmatrix(filepath, 'FileType', 'text', 'Delimiter', '\t');
        didLoad = true;
        errorMessage = '';
    catch ME
        data = [];
        didLoad = false;
        errorMessage = ME.message;
    end
end