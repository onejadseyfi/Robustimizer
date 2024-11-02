% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
% saveAsTabSeparated - Save data as tab-separated values to a file.
%
% Syntax:
%   [didSave, errorMessage] = saveAsTabSeparated(filepath, dataToSave)
%
% Inputs:
%   - filepath: A string specifying the path to the file where the data will be saved.
%   - dataToSave: The data to be saved as tab-separated values. The data should be numeric.
%   - numberFormat (optional): The format to use when saving numeric values. Default is '%8.4f'.
%
% Outputs:
%   - didSave: A logical value indicating whether the data was successfully saved (true) or not (false).
%   - errorMessage: A string containing an error message when an error occurred during the saving process.
%
% Example:
%   filepath = 'data.txt';
%   data = [1 2 3; 4 5 6; 7 8 9];
%   [didSave, errorMessage] = saveAsTabSeparated(filepath, data);
%
%   if didSave
%       disp('Data saved successfully.');
%   else
%       disp(['Error saving data: ' errorMessage]);
%   end
%
% Notes:
%   - The function saves the data as tab-separated values (TSV) to the specified file.
%   - If the file already exists, it will be overwritten.
%   - The function returns true in the 'didSave' output argument if the data was successfully saved,
%     and false otherwise. If an error occurred during the saving process, the error message will be
%     returned in the 'errorMessage' output argument.
function [didSave, errorMessage] = saveAsTabSeparated(filepath, dataToSave, numberFormat)
    arguments
        filepath (1,1) string
        dataToSave (:,:) double
        numberFormat (1,1) string = "%8.4f"
    end
    [fileID, errorMessage] = fopen(filepath, "wt");
    openedOk = (fileID ~= -1);
    if openedOk
        formatWrite = join(repmat(numberFormat, [1,width(dataToSave)]), "\t") + "\n";
        % fprintf works with column-major order, so we need to transpose the data
        fprintf(fileID, formatWrite, dataToSave');
        fclose(fileID);
    end
    didSave = openedOk;
end
