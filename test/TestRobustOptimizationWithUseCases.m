% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestRobustOptimizationWithUseCases < matlab.unittest.TestCase
    
    properties
        prj Project
    end

    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
        function setup(test)
            % Start with a clean project for each test
            test.prj = Project();
        end
    end
    
    methods(Test)
        % Test methods
        
        function braninExampleWithGivenOutputsTest(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [-5 10]);
            setNoiseVariableRanges(test.prj, 7.5, 2.5);
            [ok, msg] = importDOE(test.prj, 'test_branin_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_branin_out.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanMinT1Sigma');
            setObjectiveFunctionTargetValue(test.prj, 0);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, 2.3544,   'AbsTol', 1e-3);
            test.verifyEqual(globF, 785.3001, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 10);
        end

        function basketBallExampleWithGivenOutputsTest(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [6 8; 70 80]);
            setNoiseVariableRanges(test.prj, [3 2.3], [1 0.1]);
            [ok, msg] = importDOE(test.prj, 'test_basketball_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_basketball_out.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanMinT1Sigma');
            setObjectiveFunctionTargetValue(test.prj, 0);


            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, [7.8339  70.0000], 'AbsTol', 1e-3);
            test.verifyEqual(globF, 2.2127, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 10);
        end
        
        function braninExampleWithSkewness(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [-5 10]);
            setNoiseVariableRanges(test.prj, 7.5, 2.5);
            [ok, msg] = importDOE(test.prj, 'test_branin_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_branin_out.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionIncludeSkewness(test.prj, true);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanMinT1Sigma');
            setObjectiveFunctionTargetValue(test.prj, 0);


            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, 1.1220,    'AbsTol', 1e-3);
            test.verifyEqual(globF, 1478.9476, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 10);
        end

        function BraninWith1Con(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [-5 10]);
            setNoiseVariableRanges(test.prj, 7.5, 2.5);
            setNrOfConstraintsResponses(test.prj,1)
            [ok, msg] = importDOE(test.prj, 'test_braninCon_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_braninCon_out.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanPlusSigma');
            setConstraintTargetValue(test.prj, 5, 1); %for constriant 1
            setConstraintType(test.prj, 'UpperBound', 1); %for constriant 1
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, -2.9650 , 'AbsTol' , 1e-3);
            test.verifyEqual(globF, 48.4869, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 1000);
        end
            
        function braninNoConstraintandSequential2Steps(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [-5 10]);
            setNoiseVariableRanges(test.prj, 7.5, 2.5);
            [ok, msg] = importDOE(test.prj, 'test_branin_in.txt');
            test.verifyTrue(ok, msg);
            setResultsGeneratorScript(test.prj,fullfile(pwd,'Branin.exe'))
            [ok, msg] = runResultsGeneratorScript(test.prj);
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanPlus3Sigma');
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

             % When the robust optimization is performed
            [ok, msg, globX, globF, elapsedTime] = performRobustOptimization(test.prj);
            test.verifyTrue(ok, msg);
            
            %Then 2 steps of sequential improvement
            [success, errorMessage] = performSequentialOptimization(...
                test.prj, 2, 0.5); %2 steps with omega=0.5
            
            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, 0.4558,    'AbsTol', 1e-3);
            test.verifyEqual(globF, 46.7438, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 100);
        end

        function Hartmann6D_NoCon_obj3(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_NoCon_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_NoCon_out.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanPlus3Sigma');
            setObjectiveFunctionTargetValue(test.prj, 0);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, [0.2939,0.9506,0,0.2156] , 'AbsTol' , 1e-4);
            test.verifyEqual(globF, -1.3817, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 40);
        end

        function Hartmann6D_NoCon_MC_obj5(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_NoCon_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_NoCon_out.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importMCSample(test.prj, 'MC500Rnd.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanMinT1Sigma');
            setObjectiveFunctionTargetValue(test.prj, 0);
            test.prj.optSettings.noiPropMthd=NoisePropagationMethod.MonteCarloRandom;

            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, [0.3870,0.0584,1,1] , 'AbsTol' , 1e-3);
            test.verifyEqual(globF, 1.5179, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 600);
        end

        function Hartmann6D_1Con_InEqT0_obj7(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            setNrOfConstraintsResponses(test.prj,1)
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_NoCon_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_1Con_InEqT0_out.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanPlusSigma');
            setConstraintTargetValue(test.prj, 0.1, 1); %for constriant 1 only
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, [0.1261,0.0719,0,0.1676] , 'AbsTol' , 1e-4);
            test.verifyEqual(globF, -1.8239, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 500);
        end
            
        function Hartmann6D_2Con_obj2(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            setNrOfConstraintsResponses(test.prj,2)
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_2Con_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_2Con_out.txt');
            test.verifyTrue(ok, msg);
            setObjectiveFunctionType(test.prj,'MinMeanPlusSigma');
            setConstraintIncludeSkewness(test.prj, 1, 2); %for constriant 2 only
            setConstraintSigmaLevel(test.prj, 3, 2); %for constriant 2 only
            setConstraintTargetValue(test.prj, 0.5, 2); %for constriant 2 only

            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);

            % When the robust optimization is performed
            [success, errorMessage, globX, globF, elapsedTime] = ...
                performRobustOptimization(test.prj);

            % Then the expected results are
            test.verifyTrue(success);
            test.verifyEqual(errorMessage, "");
            test.verifyEqual(globX, [0.2426,0.2996,0.5838,0.2554] , 'AbsTol' , 1e-3);
            test.verifyEqual(globF, -1.6177, 'AbsTol', 1e-3);
            test.verifyTrue(elapsedTime < 1000);
        end

        function compareAnalyticalAndMC1(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            setNrOfConstraintsResponses(test.prj,2)
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_2Con_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_2Con_out.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);
            [ok, msg] = importMCSample(test.prj, 'MC500LHS2D.txt');
            test.verifyTrue(ok, msg);

            % Compare analytical and MC
            position=1;
            designInput=rand(1,4);   %[0.1,0.2,0.3,0.4];
            [Inp, ~] = collectRobOptInputs(test.prj);
            srg=test.prj.srgModel;
            DOEn=test.prj.optSettings.noiDesOfExp;

            [~,mu_a,stdev_a,~,~,s_hat_a,skew_a]= ...
                AnalyticalKrigX(designInput,Inp,srg ...
                ,position,1,[],0);

            [mu_MC,stdev_MC,skew_MC,s_hat_MC] = MCanalysisX(designInput,srg,DOEn,position);
            
            % Then the expected results must match
            test.verifyEqual(mu_a, mu_MC , 'AbsTol' , 1e-1);
            test.verifyEqual(stdev_a, stdev_MC, 'AbsTol', 1e-1);
            test.verifyEqual(s_hat_a, s_hat_MC, 'AbsTol', 1e-1);
            test.verifyEqual(skew_a, skew_MC, 'AbsTol', 1e-1);
        end

        function compareAnalyticalAndMC2(test)
            % Given these inputs and outputs
            setDesignVariableRanges(test.prj, [0 1;0 1;0 1;0 1]);
            setNoiseVariableRanges(test.prj, [0.5, 0.5],[0.1666, 0.1666]);
            setNrOfConstraintsResponses(test.prj,2)
            [ok, msg] = importDOE(test.prj, 'test_Hartmann6D_2Con_in.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = importResults(test.prj, 'test_Hartmann6D_2Con_out.txt');
            test.verifyTrue(ok, msg);
            [ok, msg] = fitSurrogateModel(test.prj);
            test.verifyTrue(ok, msg);
            [ok, msg] = importMCSample(test.prj, 'MC5000rnd.txt');
            test.verifyTrue(ok, msg);

            % Compare analytical and MC
            position=2;
            designInput=rand(1,4);   %[0.1,0.2,0.3,0.4];
            [Inp, ~] = collectRobOptInputs(test.prj);
            srg=test.prj.srgModel;
            DOEn=test.prj.optSettings.noiDesOfExp;

            [~,mu_a,stdev_a,~,~,s_hat_a,skew_a]= ...
                AnalyticalKrigX(designInput,Inp,srg ...
                ,position,1,[],0);

            [mu_MC,stdev_MC,skew_MC,s_hat_MC] = MCanalysisX(designInput,srg,DOEn,position);
            
            % Then the expected results must match
            test.verifyEqual(mu_a, mu_MC , 'AbsTol' , 1e-1);
            test.verifyEqual(stdev_a, stdev_MC, 'AbsTol', 1e-1);
            test.verifyEqual(s_hat_a, s_hat_MC, 'AbsTol', 1e-1);
            test.verifyEqual(skew_a, skew_MC, 'AbsTol', 1e-1);
        end


    end
    
end