% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestIntegration < matlab.unittest.TestCase
    properties
        presenter Presenter
        vm        ViewModel
        prj       Project
    end

    methods(TestMethodSetup)
        function setup(test)
            test.prj = Project();
        end

        function setupTestProject(test)
            design_ranges = [0 1; 0 2; 0 3; 0 4; 0 5];
            noise_means = 2;
            noise_stddevs = 1;
            setDesignVariableRanges(test.prj, design_ranges);
            renameDesignVariables(test.prj, ["design_var1"; "design_var2"; "design_var3"; "design_var4"; "design_var5"]);
            setNoiseVariableRanges(test.prj, noise_means, noise_stddevs);
        end

        function setupBraninTestProject(test)
            setDesignVariableRanges(test.prj, [-5 10]);
            setNoiseVariableRanges(test.prj, 7.5, 2.5);
            [testpath] = fileparts(mfilename('fullpath'));
            testScriptPath = fullfile(testpath, "\..\src\Branin.exe");
            if ~isfile(testScriptPath)
                error("Test script not found: %s, please update the path in this test.", testScriptPath);
            end
            setResultsGeneratorScript(test.prj, testScriptPath);
        end

        function setupAndRunBraninTestScript(test)
            test.setupBraninTestProject();
            [didSucceed, errorMsg] = createDOE(test.prj, 10);
            test.verifyTrue(didSucceed, errorMsg);

            [didSucceed, errorMsg] = runResultsGeneratorScript(test.prj);
            test.verifyTrue(didSucceed, errorMsg);

            [didSucceed, errorMsg] = fitSurrogateModel(test.prj);
            test.verifyTrue(didSucceed, errorMsg);

            [didSucceed, errorMsg, globX, globF, elapsedTime] = performRobustOptimization(test.prj);
            test.verifyTrue(didSucceed, errorMsg);

            omega = 0.5;
            nSeq = 2;
            [didSucceed, errorMsg] = performSequentialOptimization(test.prj, nSeq, omega);
            test.verifyTrue(didSucceed, errorMsg);

            [didSucceed, errorMsg] = performCrossValidation(test.prj);
            test.verifyTrue(didSucceed, errorMsg);

        end
    end
    
    methods(Test)
        function changingDesignVarRangesClearsTheDOE(test)
            % Given a Project with a DOE
            createDOE(test.prj, 20);
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);

            % When the design variables are changed
            setDesignVariableRanges(test.prj, [0 1]);

            % Then the DOE should be empty again
            test.verifyEmpty(test.prj.DOE);
            test.verifyEmpty(test.prj.simulResDOE);
        end

        function changingNoiseVarRangesClearsTheDOE(test)
            % Given a Project with a DOE
            createDOE(test.prj, 20);
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);

            % When the design variables are changed
            setDesignVariableRanges(test.prj, [0 1]);

            % Then the DOE should be empty again
            test.verifyEmpty(test.prj.DOE);
            test.verifyEmpty(test.prj.simulResDOE);
        end

        function changingNrOfDesignVarsClearsTheDOE(test)
            % Given a Project with a DOE
            createDOE(test.prj, 20);
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);

            % When the number of design variables is changed
            changeNrOfDesignVariables(test.prj, 2);

            % Then the DOE should be empty again
            test.verifyEmpty(test.prj.DOE);
            test.verifyEmpty(test.prj.simulResDOE);
        end

        function changingNrOfNoiseVarsClearsTheDOE(test)
            % Given a Project with a DOE
            createDOE(test.prj, 20);
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);

            % When the number of noise variables is changed
            changeNrOfNoiseVariables(test.prj, 2);

            % Then the DOE should be empty again
            test.verifyEmpty(test.prj.DOE);
            test.verifyEmpty(test.prj.simulResDOE);
        end

        function clearingTheDOEClearsDependentResults(test)
            % Given a Project with all results filled
            test.setupAndRunBraninTestScript();
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.globX);
            test.verifyNotEmpty(test.prj.globF);
            test.verifyNotEmpty(test.prj.seqRecommendationTexts);
            test.verifyNotEmpty(test.prj.seqOptResultTexts);
            
            % When the DOE is cleared
            test.prj.clearDOE();

            % Then all results should be cleared
            test.verifyEmpty(test.prj.DOE);
            test.verifyEmpty(test.prj.simulResDOE);
            test.verifyEmpty(test.prj.srgModel);
            test.verifyEmpty(test.prj.crossValidationResults);
            test.verifyEmpty(test.prj.outputVal);
            test.verifyEmpty(test.prj.globX);
            test.verifyEmpty(test.prj.globF);
            test.verifyEmpty(test.prj.seqRecommendationTexts);
            test.verifyEmpty(test.prj.seqOptResultTexts);
        end
        
        function fittingASurrogateModelClearsDependentResultsOnly(test)
            % Given a Project with all results filled
            test.setupAndRunBraninTestScript();
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.globX);
            test.verifyNotEmpty(test.prj.globF);
            test.verifyNotEmpty(test.prj.seqRecommendationTexts);
            test.verifyNotEmpty(test.prj.seqOptResultTexts);
            
            % When the surrogate model is refitted
            fitSurrogateModel(test.prj);

            % Then only the dependent results should be cleared
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyEmpty(test.prj.crossValidationResults);
            test.verifyEmpty(test.prj.globX);
            test.verifyEmpty(test.prj.globF);
            test.verifyEmpty(test.prj.seqRecommendationTexts);
            test.verifyEmpty(test.prj.seqOptResultTexts);
        end

        function runningRobustOptimizationClearsDependentResultsOnly(test)
            % Given a Project with all results filled
            test.setupAndRunBraninTestScript();
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.globX);
            test.verifyNotEmpty(test.prj.globF);
            test.verifyNotEmpty(test.prj.seqRecommendationTexts);
            test.verifyNotEmpty(test.prj.seqOptResultTexts);
            
            % When the optimization is run again
            [didSucceed, errorMessage] = performRobustOptimization(test.prj);
            test.verifyTrue(didSucceed, errorMessage);

            % Then only the dependent results should be cleared
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.globX);
            test.verifyNotEmpty(test.prj.globF);
            test.verifyEmpty(test.prj.seqRecommendationTexts);
            test.verifyEmpty(test.prj.seqOptResultTexts);
        end

        function changingOptimizationSettingsClearsDependentResultsOnly(test)
            % Given a Project with all results filled
            test.setupAndRunBraninTestScript();
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.globX);
            test.verifyNotEmpty(test.prj.globF);
            test.verifyNotEmpty(test.prj.seqRecommendationTexts);
            test.verifyNotEmpty(test.prj.seqOptResultTexts);
            
            % When the optimization settings are changed
            setNoisePropagationMethod(test.prj, NoisePropagationMethod.MonteCarloRandom);

            % Then only the dependent results should be cleared
            test.verifyNotEmpty(test.prj.DOE);
            test.verifyNotEmpty(test.prj.simulResDOE);
            test.verifyNotEmpty(test.prj.srgModel);
            test.verifyNotEmpty(test.prj.crossValidationResults);
            test.verifyNotEmpty(test.prj.outputVal);
            test.verifyEmpty(test.prj.globX);
            test.verifyEmpty(test.prj.globF);
            test.verifyEmpty(test.prj.seqRecommendationTexts);
            test.verifyEmpty(test.prj.seqOptResultTexts);
        end
    end
end