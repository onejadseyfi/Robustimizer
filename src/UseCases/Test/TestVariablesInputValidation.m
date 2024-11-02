% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestVariablesInputValidation < TestWithTempFiles
    properties
        prj Project
    end
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
        function setup(test)
            test.prj = Project();
        end
    end
    
    methods(Test)
        % Test methods
        
        function exceeding_max_design_vars_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nDesignVars;

            % When the number of design variables is increased beyond the maximum
            [succeeded, message] = changeNrOfDesignVariables(test.prj, AppConstants.MAX_DESIGN_VARIABLES + 1);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nDesignVars, nBefore);
        end

        function exceeding_min_design_vars_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nDesignVars;

            % When the number of design variables is decreased below the minimum
            [succeeded, message] = changeNrOfDesignVariables(test.prj, AppConstants.MIN_DESIGN_VARIABLES - 1);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nDesignVars, nBefore);
        end

        function exceeding_max_noise_vars_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of noise variables is increased beyond the maximum
            [succeeded, message] = changeNrOfNoiseVariables(test.prj, AppConstants.MAX_NOISE_VARIABLES + 1);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function exceeding_min_noise_vars_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of noise variables is decreased below the minimum
            [succeeded, message] = changeNrOfNoiseVariables(test.prj, AppConstants.MIN_NOISE_VARIABLES - 1);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function exceeding_max_design_vars_by_specifying_names_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nDesignVars;

            % When the number of design variables is increased beyond the maximum
            names = "Var " + (1:AppConstants.MAX_DESIGN_VARIABLES + 1);
            [succeeded, message] = renameDesignVariables(test.prj, names);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nDesignVars, nBefore);
        end

        function exceeding_max_noise_vars_by_specifying_names_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of noise variables is increased beyond the maximum
            names = "Var " + (1:AppConstants.MAX_NOISE_VARIABLES + 1);
            [succeeded, message] = renameNoiseVariables(test.prj, names);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function exceeding_max_design_vars_by_specifying_ranges_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nDesignVars;

            % When the number of design variables is increased beyond the maximum
            ranges = repmat([0 1], AppConstants.MAX_DESIGN_VARIABLES + 1, 1);
            [succeeded, message] = setDesignVariableRanges(test.prj, ranges);

            % Then the operation should fail and the number of design variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nDesignVars, nBefore);
        end

        function exceeding_max_noise_vars_by_specifying_ranges_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of design variables is increased beyond the maximum
            means = zeros(AppConstants.MAX_NOISE_VARIABLES + 1, 1);
            stdDevs = ones(AppConstants.MAX_NOISE_VARIABLES + 1, 1);
            [succeeded, message] = setNoiseVariableRanges(test.prj, means, stdDevs);

            % Then the operation should fail and the number of variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function resize_noisevars_with_unequal_sized_mean_and_stddev_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of noise variables is changed with different sized means and standard deviations
            means = zeros(AppConstants.MAX_NOISE_VARIABLES/2, 1);
            stdDevs = ones(length(means) + 1, 1);
            [succeeded, message] = setNoiseVariableRanges(test.prj, means, stdDevs);

            % Then the operation should fail and the number of variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function reading_noise_data_from_file_with_too_many_columns_gives_error(test)
            % Given a project
            nBefore = test.prj.varsDef.nNoiseVars;

            % When the number of noise variables is set from a file with too few columns
            fileName = test.createTestFile(10, AppConstants.MAX_NOISE_VARIABLES + 1);
            [succeeded, message] = setNoiseDescriptionFromFile(test.prj, fileName);

            % Then the operation should fail and the number of variables should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(test.prj.varsDef.nNoiseVars, nBefore);
        end

        function exceeding_max_constraints_gives_error(test)
            % Given a project
            nBefore = length(test.prj.constraintSpec);

            % When the number of constraints is increased beyond the maximum
            [succeeded, message] = setNrOfConstraintsResponses(test.prj, AppConstants.MAX_CONSTRAINTS + 1);

            % Then the operation should fail and the number of constraints should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(length(test.prj.constraintSpec), nBefore);
        end

        function exceeding_min_constraints_gives_error(test)
            % Given a project
            nBefore = length(test.prj.constraintSpec);

            % When the number of constraints is decreased below the minimum
            [succeeded, message] = setNrOfConstraintsResponses(test.prj, AppConstants.MIN_CONSTRAINTS - 1);

            % Then the operation should fail and the number of constraints should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(length(test.prj.constraintSpec), nBefore);
        end
    end
end