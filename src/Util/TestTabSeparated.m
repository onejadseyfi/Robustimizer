% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestTabSeparated < matlab.unittest.TestCase

    properties(TestParameter)
        % Test data: a cell array of matrices of different interesting sizes
        referenceData = { ...
            [1 2 3; 4 5 6; 7 8 9], ...  % 3x3 matrix
            [1 2; 3 4; 5 6; 7 8],  ...  % 4x2 matrix
            [], ...                     % empty matrix
            42, ...                     % single value
            rand(1000, 10) ...          % large matrix
        };
    end

    properties
        filesToDelete = {};
    end
  
    methods(TestMethodTeardown)
        function deleteTemporaryFiles(obj)
            if ~isempty(obj.filesToDelete)
                delete(obj.filesToDelete{:});
                obj.filesToDelete = {};
            end
        end
    end

    methods
        function filename = tempFilename(obj)
            % Create a temporary file name that will be deleted at the end of the test
            [path, name, ext ] = fileparts(tempname());
            filename = fullfile(path, ['test_save_as_tabsep_' name ext]);
            obj.filesToDelete = [obj.filesToDelete, filename];
        end
    end

    methods(Test)
        function savingAndLoadingAgainGivesSame(testCase, referenceData)
            % Given a matrix of data and a temporary file name
            fn = testCase.tempFilename();
            referenceData = [1 2 3; 4 5 6; 7 8 9];

            % When we save the data to the file
            [didSave, errorMessage] = saveAsTabSeparated(fn, referenceData);
            
            % Then the data should be saved successfully
            testCase.verifyTrue(didSave, sprintf('data was not saved successfully: %s', errorMessage));

            % And when we load the data from the file, it should be the same as the original data
            [loadedData, didLoad, errorMessage] = loadTabSeparated(fn);
            testCase.verifyTrue(didLoad, sprintf('data was not loaded successfully: %s', errorMessage));
            testCase.verifyEqual(loadedData, referenceData, 'AbsTol', 1e-3);
        end

        function loadingNonExistentFileReturnsError(testCase)
            % Given a non-existent file name
            fn = 'non_existent_file.txt';

            % When we try to load the data from the file
            [loadedData, didLoad, errorMessage] = loadTabSeparated(fn);

            % Then the data should not be loaded successfully
            testCase.verifyFalse(didLoad, 'data was loaded successfully, but the file does not exist');
            testCase.verifyNotEmpty(errorMessage, 'no error message was returned where one was expected');
            testCase.verifyEmpty(loadedData, 'expected empty data to be returned when loading failed');
        end
    end
    
end
