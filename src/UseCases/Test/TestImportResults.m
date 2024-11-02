% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestImportResults < TestWithTempFiles
    properties
        prj Project
    end
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
        function setup(test)
            % A default project with:
            %    3 design variables
            %    2 noise variables
            %    2 constraints
            %    20 DOE points
            test.prj = Project();
            setDesignVariableRanges(test.prj, [0 10; 0 20; 0 30]);
            setNoiseVariableRanges(test.prj, [5 10], [1 2]);
            setNrOfConstraintsResponses(test.prj, 2);
            createDOE(test.prj, 20);
        end
    end
    
    methods(Test)
        % Test methods
        
        function importing_empty_file_fails(test)
            % Given an empty file and a default test project
            resultsFile = test.tempFilename();
            fid = fopen(resultsFile, 'w');
            fclose(fid);

            % When we try to import the file
            [success, errorMessage] = importResults(test.prj, resultsFile);

            % Then the import should fail
            test.verifyFalse(success, "Importing empty file should fail");
            test.verifyNotEmpty(errorMessage, "Error message should not be empty");
        end

        function importing_file_with_wrong_number_of_rows_fails(test)
            % Given a file with wrong number of rows and a default test project
            resultsFile = test.createTestFile(test.prj.nDOEPoints + 1, test.prj.nOutputs);

            % When we try to import the file
            [success, errorMessage] = importResults(test.prj, resultsFile);

            % Then the import should fail
            test.verifyFalse(success, "Importing file with wrong number of rows should fail");
            test.verifyNotEmpty(errorMessage, "Error message should not be empty");
        end

        function importing_file_with_wrong_number_of_columns_fails(test)
            % Given a file with wrong number of columns and a default test project
            resultsFile = test.createTestFile(test.prj.nDOEPoints, test.prj.nOutputs + 1);

            % When we try to import the file
            [success, errorMessage] = importResults(test.prj, resultsFile);

            % Then the import should fail
            test.verifyFalse(success, "Importing file with wrong number of columns should fail");
            test.verifyNotEmpty(errorMessage, "Error message should not be empty");
        end

        function importing_non_existing_file_fails(test)
            % Given a non-existing file and a default test project
            resultsFile = "non_existing_file.txt";

            % When we try to import the file
            [success, errorMessage] = importResults(test.prj, resultsFile);

            % Then the import should fail
            test.verifyFalse(success, "Importing non-existing file should fail");
            test.verifyNotEmpty(errorMessage, "Error message should not be empty");
        end

        function importing_file_with_correct_dimensions_succeeds(test)
            % Given a file with correct dimensions and a default test project
            resultsFile = test.createTestFile(test.prj.nDOEPoints, test.prj.nOutputs);

            % When we try to import the file
            [success, errorMessage] = importResults(test.prj, resultsFile);

            % Then the import should succeed
            test.verifyTrue(success, "Importing file with correct dimensions should succeed");
            test.verifyEmpty(errorMessage, "Error message should be empty");
            test.verifyEqual(height(test.prj.outputVal), test.prj.nDOEPoints);
            test.verifyEqual(width(test.prj.outputVal), test.prj.nOutputs);
        end
    end
    
end