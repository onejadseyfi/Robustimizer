% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestConstraints < matlab.unittest.TestCase
    properties
        prj Project
    end
    
    methods(TestMethodSetup)
        function setup(test)
            test.prj = Project();
        end
    end
    
    methods(Test)
        
        function exceedingMaxConstraintsGivesError(test)
            % Given a project
            nBefore = length(test.prj.constraintSpec);

            % When the number of constraints is increased beyond the maximum
            [succeeded, message] = setNrOfConstraintsResponses(test.prj, AppConstants.MAX_CONSTRAINTS + 1);
            nAfter = length(test.prj.constraintSpec);

            % Then the operation should fail and the number of constraints should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(nAfter, nBefore);
        end
        
        function exceedingMinConstraintsGivesError(test)
            % Given a project
            nBefore = length(test.prj.constraintSpec);

            % When the number of constraints is decreased below the minimum
            [succeeded, message] = setNrOfConstraintsResponses(test.prj, AppConstants.MIN_CONSTRAINTS - 1);
            nAfter = length(test.prj.constraintSpec);

            % Then the operation should fail and the number of constraints should remain the same
            test.verifyFalse(succeeded);
            test.verifyNotEmpty(message);
            test.verifyEqual(nAfter, nBefore);
        end
        
        function reducingNrOfConstraintsResultsInFewerConstraints(test)
            % Given a project with constraints
            setNrOfConstraintsResponses(test.prj, 3);
            nBefore = length(test.prj.constraintSpec);
            test.verifyEqual(nBefore, 3);
            
            % When the number of constraints is reduced
            setNrOfConstraintsResponses(test.prj, 2);
            nAfter = length(test.prj.constraintSpec);
            
            % Then the number of constraints should be reduced
            test.verifyEqual(nAfter, 2);
        end

        function reducingNrOfConstraintsToZeroResultsInNoConstraints(test)
            % Given a project with constraints
            setNrOfConstraintsResponses(test.prj, 3);
            nBefore = length(test.prj.constraintSpec);
            test.verifyEqual(nBefore, 3);
            
            % When the number of constraints is reduced to zero
            setNrOfConstraintsResponses(test.prj, 0);
            nAfter = length(test.prj.constraintSpec);
            
            % Then the number of constraints should be zero
            test.verifyEqual(nAfter, 0);
            % and the constraintSpec should register as empty
            test.verifyTrue(isempty(test.prj.constraintSpec));
        end
    end
end