% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestWithTempFiles < matlab.unittest.TestCase
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
        % Helper methods

        function filename = tempFilename(obj)
            % Create a temporary file name that will be deleted at the end of the test
            [path, name, ext ] = fileparts(tempname());
            filename = fullfile(path, ['test_import_results_' name ext]);
            obj.filesToDelete = [obj.filesToDelete, filename];
        end

        function [fileName] = createTestFile(test, nrows, ncols)
            % Create a test file with the given data
            fileName = test.tempFilename();
            data = rand(nrows, ncols);
            [didSave, error] = saveAsTabSeparated(fileName, data);
            if ~didSave
                error("Could not save test file: %s", error);
            end
        end

        function [fileName] = createTestFileWithData(test, data)
            % Create a test file with the given data
            fileName = test.tempFilename();
            [didSave, error] = saveAsTabSeparated(fileName, data);
            if ~didSave
                error("Could not save test file: %s", error);
            end
        end
    end
end