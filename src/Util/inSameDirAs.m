% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function filepath = inSameDirAs(referenceFilePath, givenFileName)
    % inSameDirAs - Get the full path to a file in the same directory as another file.
    %
    % Syntax:
    %   filepath = inSameDirAs(referenceFilePath, givenFileName)
    %
    % Inputs:
    %   - referenceFilePath: A string specifying the path to the reference file.
    %   - givenFileName: A string specifying the name of the file to be located in the same directory as the reference file.
    %
    % Outputs:
    %   - filepath: A string containing the full path to the file located in the same directory as the reference file.
    %
    % Example:
    %   referenceFilePath = 'C:\data\file.txt';
    %   givenFileName = 'data.csv';
    %   filepath = inSameDirAs(referenceFilePath, givenFileName);
    %
    %   disp(filepath) % Output: C:\data\data.csv
    %
    dir = fileparts(referenceFilePath);
    filepath = fullfile(dir, givenFileName);
end