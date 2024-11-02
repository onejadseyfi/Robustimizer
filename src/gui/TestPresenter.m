% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestPresenter < TestWithTempFiles
    properties
        presenter Presenter
        vm        ViewModel
        prj       Project
    end

    methods(TestMethodSetup)
        function setup(test)
            test.presenter = Presenter();
            test.vm = ViewModel();
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
    end

    methods(Test)

        % -----  First tab tests

        function presenterCorrectlyRendersDesignAndNoiseVariables(test)
            % Given a Project with 5 design variables and 1 noise variable
            setDesignVariableRanges(test.prj, [0 1; 0 2; 0 3; 0 4; 0 5]);
            renameDesignVariables(test.prj, ["foo"; "bar"; "baz"; "qux"; "quux"]);
            setNoiseVariableRanges(test.prj, 2, 1);
            renameNoiseVariables(test.prj, "noise_var1");

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct number of design and noise variables
            test.verifyEqual(test.vm.nDesignVars, int32(5));
            test.verifyEqual(test.vm.nNoiseVars, int32(1));
            % And the ViewModel should have the correct variable names
            test.verifyEqual(test.vm.designTable{:,1}, ["foo"; "bar"; "baz"; "qux"; "quux"]);
            test.verifyEqual(test.vm.noiseTable{:,1}, "noise_var1");
            % And the ViewModel should have the correct variable ranges
            test.verifyEqual(test.vm.designTable{:,2}, [0; 0; 0; 0; 0]);
            test.verifyEqual(test.vm.designTable{:,3}, [1; 2; 3; 4; 5]);
            test.verifyEqual(test.vm.noiseTable{:,2}, 2);
            test.verifyEqual(test.vm.noiseTable{:,3}, 1);
            % And the noise description method should be set to "UserDefined"
            test.verifyEqual(test.vm.noiseDescriptionMethod, NoiseDescriptionMethod.UserDefined);
        end

        function presenterDisablesNoiseTableWhenNoiseDataIsImported(test)
            % Given a Project with noise data imported from a file
            fileName = test.createTestFileWithData([0; 1; 2; 3; 4; 5]);
            setNoiseDescriptionFromFile(test.prj, fileName);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the noise table should be disabled
            test.verifyEqual(test.vm.noiseTableEnabled, "off");
        end

        function presenterReenablesNoiseTableWhenSwitchingFromImportedToUserDef(test)
            % Given a Project with noise data imported from a file
            fileName = test.createTestFileWithData([0; 1; 2; 3; 4; 5]);
            setNoiseDescriptionFromFile(test.prj, fileName);
            test.presenter.updateFromProject(test.prj, test.vm);

            % When the noise description method is reset to UserDefined
            resetNoiseDescriptionMethod(test.prj);

            % Then the noise table should be enabled again
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.noiseTableEnabled, "on");
        end

        function presenterRendersNrOfConstraintsCorrectly(test)
            % Given a Project with 3 constraints
            setNrOfConstraintsResponses(test.prj, 3);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct number of constraints
            test.verifyEqual(test.vm.nConstraints, int32(3));
        end

        % -----  Second tab tests

        function presenterCorrectlyRendersDOE(test)
            % Given a Project with a certain DOE size
            test.setupTestProject()
            nDOEPoints = 10;
            nVars = test.prj.varsDef.count;
            createDOE(test.prj, 10);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct DOE size
            test.verifyEqual(size(test.vm.doeTable), [nDOEPoints, nVars]);
            % And the DOE column names should be the variable names
            test.verifyEqual(test.vm.doeTable.Properties.VariableNames, cellstr(test.prj.varsDef.names)');
        end

        function presenterUpdatesScriptRelatedFieldsAsExpectedWhenImporting(test)
            % Given a project that imports results from a file
            test.setupTestProject()
            [didCreate, msg] = createDOE(test.prj, 10);
            test.verifyTrue(didCreate, msg);
            fileName = test.createTestFileWithData((1:10)');
            [didImport, msg] = importResults(test.prj, fileName);
            test.verifyTrue(didImport, msg);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct script related fields
            test.verifyEqual(test.vm.importResultsMethod, ImportResultsMethod.FromFile);
            test.verifyTrue(test.vm.canReadResults);
            test.verifyFalse(test.vm.canChooseScript);
            test.verifyFalse(test.vm.canRunScript);
            test.verifyFalse(test.vm.chosenScriptFieldEnabled);
            test.verifyEqual(test.vm.scriptFile, "");
        end

        function presenterUpdatesScriptRelatedFieldsAsExpectedWhenExecuting(test)
            % Given a project that executes a script
            test.setupTestProject()
            test.vm.importResultsMethod = ImportResultsMethod.GenerateWithExecutable;
            test.vm.scriptFile = "dummy.exe";
            setResultsGeneratorScript(test.prj, "dummy.exe");

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct script related fields
            test.verifyEqual(test.vm.importResultsMethod, ImportResultsMethod.GenerateWithExecutable);
            test.verifyFalse(test.vm.canReadResults);
            test.verifyTrue(test.vm.canChooseScript);
            test.verifyTrue(test.vm.chosenScriptFieldEnabled);
            test.verifyEqual(test.vm.scriptFile, "dummy.exe");
            % And as the executeable does not exist, the script should not be runnable
            test.verifyFalse(test.vm.canRunScript);
            % And the background color should be set to error
            test.verifyEqual(test.vm.scriptFileBackgroundColor, Presenter.COLOR_ERROR);
        end

        % -----  Third tab tests

        function presenterDisablesFitSurrogateButtonWhenDOEIsNotAvailable(test)
            % Given a project without a DOE
            test.setupTestProject()

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable the fit surrogate button
            test.verifyFalse(test.vm.canFitSrgModel);
        end

        function presenterDisablesFitSurrogateButtonWhenResultsAreNotAvailable(test)
            % Given a project with a DOE
            test.setupTestProject()
            [didCreate, msg] = createDOE(test.prj, 10);
            test.verifyTrue(didCreate, msg);
            
            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should still disable the fit surrogate button
            test.verifyFalse(test.vm.canFitSrgModel);
        end
        
        function presenterEnablesFitSurrogateButtonWhenDOEAndResultsAreAvailable(test)
            % Given a project with a DOE and results
            test.setupTestProject()
            [didCreate, msg] = createDOE(test.prj, 10);
            test.verifyTrue(didCreate, msg);
            fileName = test.createTestFileWithData((1:10)');
            [didImport, msg] = importResults(test.prj, fileName);
            test.verifyTrue(didImport, msg);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the fit surrogate button
            test.verifyTrue(test.vm.canFitSrgModel);
        end

        function presenterUpdatesSliderRangesWhenVariableRangesChanged(test)
            % Given a project with design and noise variables
            test.setupTestProject()
            setDesignVariableRanges(test.prj, [0 1; 0 2]);
            setNoiseVariableRanges(test.prj, 0, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct slider ranges
            test.verifyEqual(length(test.vm.sliderData), 3);
            test.verifyEqual(test.vm.sliderData(1).range, [0; 1]);
            test.verifyEqual(test.vm.sliderData(2).range, [0; 2]);
            test.verifyEqual(test.vm.sliderData(3).range, [-3; 3]);
        end

        function presenterCanUpdateInvalidSliderRanges(test)
            % Given a project with invalid design variables
            test.setupTestProject()
            setDesignVariableRanges(test.prj, [1 0; 0 0]); % Lower bound > Upper bound and empty range

            % When the Presenter updates the ViewModel with invalid ranges
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should not error out but "fix" the ranges
            test.verifyEqual(length(test.vm.sliderData), 3);
            test.verifyEqual(test.vm.sliderData(1).range, [0; 1]);
            test.verifyEqual(test.vm.sliderData(2).range, [0; 1]);
        end

        function presenterResetsSliderValuesWhenRangesChange(test)
            % Given a project with design variables
            test.setupTestProject()
            setDesignVariableRanges(test.prj, [-1 1; 0 2]);
            % and the sliders are set to a min and max value
            test.presenter.updateFromProject(test.prj, test.vm);
            test.vm.sliderData(1).value = -2;
            test.vm.sliderData(2).value = 2;
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.sliderData(1).value, -2);
            test.verifyEqual(test.vm.sliderData(2).value, 2);

            % When the ranges are changed in the project
            setDesignVariableRanges(test.prj, [0 1; 0 1]);
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should reset the slider values to the middle of the new range
            test.verifyEqual(test.vm.sliderData(1).value, 0.5);
            test.verifyEqual(test.vm.sliderData(2).value, 0.5);
        end

        % ----- Fourth tab tests
    
        function presenterDisablesMCInputsWhenNoisePropIsAnalytical(test)
            % Given a project with noise propagation method set to Analytical
            test.setupTestProject()
            setNoisePropagationMethod(test.prj, NoisePropagationMethod.Analytical);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable the MC inputs
            test.verifyFalse(test.vm.MCFieldsEnabled);
            test.verifyFalse(test.vm.canCreateMC);
            test.verifyFalse(test.vm.canSaveMC);
            test.verifyFalse(test.vm.canLoadMC);
        end

        function presenterEnablesMCInputsWhenNoisePropIsMC(test)
            % Given a project with noise propagation method set to Monte Carlo
            test.setupTestProject()
            setNoisePropagationMethod(test.prj, NoisePropagationMethod.MonteCarloRandom);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the MC inputs
            test.verifyTrue(test.vm.MCFieldsEnabled);
            test.verifyTrue(test.vm.canCreateMC);
            test.verifyTrue(test.vm.canLoadMC);
        end

        function presenterEnablesSaveMCWhenSampleIsAvailable(test)
            % Given a project with a Monte Carlo sample
            test.setupTestProject()
            setNoisePropagationMethod(test.prj, NoisePropagationMethod.MonteCarloRandom);
            createMCSample(test.prj);
            test.verifyTrue(test.prj.optSettings.nMC > 0);
            test.verifyTrue(height(test.prj.optSettings.noiDesOfExp) > 0);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the save MC button
            test.verifyTrue(test.vm.canSaveMC);
        end

        function presenterDisablesSaveMCWhenSampleIsNotAvailable(test)
            % Given a project without a Monte Carlo sample
            test.setupTestProject()
            setNoisePropagationMethod(test.prj, NoisePropagationMethod.MonteCarloRandom);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable the save MC button
            test.verifyFalse(test.vm.canSaveMC);
        end

        function presenterDisablesConstraintInputsWhenNoConstraints(test)
            % Given a project without constraints
            test.setupTestProject()

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable the constraint inputs
            test.verifyFalse(test.vm.constraintsEnabled);
            test.verifyFalse(test.vm.constraintUBVisible);
            test.verifyFalse(test.vm.constraintLBVisible);
            test.verifyFalse(test.vm.constraintEqVisible);
        end

        function presenterEnablesInputsForEQConstraint(test)
            % Given a project with an equality constraint
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.Equality, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the correct constraint inputs
            test.verifyTrue(test.vm.constraintsEnabled);
            test.verifyFalse(test.vm.constraintUBVisible);
            test.verifyFalse(test.vm.constraintLBVisible);
            test.verifyTrue(test.vm.constraintEqVisible);
        end

        function presenterEnablesInputsForLBConstraint(test)
            % Given a project with a lowerbound constraint
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.LowerBound, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the correct constraint inputs
            test.verifyTrue(test.vm.constraintsEnabled);
            test.verifyFalse(test.vm.constraintUBVisible);
            test.verifyTrue(test.vm.constraintLBVisible);
            test.verifyFalse(test.vm.constraintEqVisible);
        end

        function presenterEnablesInputsForUBConstraint(test)
            % Given a project with an upperbound constraint
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.UpperBound, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable the correct constraint inputs
            test.verifyTrue(test.vm.constraintsEnabled);
            test.verifyTrue(test.vm.constraintUBVisible);
            test.verifyFalse(test.vm.constraintLBVisible);
            test.verifyFalse(test.vm.constraintEqVisible);
        end

        function presenterHidesInputsWhenReducingConstraintsToZero(test)
            % Given a project with a constraint
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.UpperBound, 1);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyTrue(test.vm.constraintsEnabled);
            test.verifyTrue(test.vm.constraintsEnabled);
            test.verifyTrue(test.vm.constraintUBVisible);
            test.verifyFalse(test.vm.constraintLBVisible);
            test.verifyFalse(test.vm.constraintEqVisible);

            % When the number of constraints is reduced to zero
            setNrOfConstraintsResponses(test.prj, 0);

            % Then the ViewModel should disable the constraint inputs
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyFalse(test.vm.constraintsEnabled);
            test.verifyFalse(test.vm.constraintUBVisible);
            test.verifyFalse(test.vm.constraintLBVisible);
            test.verifyFalse(test.vm.constraintEqVisible);
        end

        function presenterSetsCorrectConstraintSigma(test)
            % Given a project with a mix of constraint types and sigma values
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 3);
            setConstraintType(test.prj, ConstraintType.UpperBound, 1);
            setConstraintType(test.prj, ConstraintType.LowerBound, 2);
            setConstraintType(test.prj, ConstraintType.Equality, 3);

            % Select the first constraint (UB) and check sigma +3 and +6
            test.vm.currentConstraint = 1;
            setConstraintSigmaLevel(test.prj, +3, 1);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "+3");
            setConstraintSigmaLevel(test.prj, +6, 1);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "+6");

            % Select the second constraint (LB) and check sigma -3 and -6
            test.vm.currentConstraint = 2;
            setConstraintSigmaLevel(test.prj, -3, 2);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "-3");
            setConstraintSigmaLevel(test.prj, -6, 2);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "-6");

            % Select the third constraint (EQ) and check sigma -3, +3, -6, +6
            test.vm.currentConstraint = 3;
            setConstraintSigmaLevel(test.prj, -3, 3);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "-3");
            setConstraintSigmaLevel(test.prj, +3, 3);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "+3");
            setConstraintSigmaLevel(test.prj, -6, 3);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "-6");
            setConstraintSigmaLevel(test.prj, +6, 3);
            test.presenter.updateFromProject(test.prj, test.vm);
            test.verifyEqual(test.vm.constraintSigma, "+6");
        end

        function presenterSetsConstraintTargetValue(test)
            % Given a project with a constraint with target value
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.UpperBound, 1);
            setConstraintTargetValue(test.prj, 42, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have the correct target value
            test.verifyEqual(test.vm.constraintValue, 42);
        end

        function presenterSetsConstraintSkewnessFlag(test)
            % Given a project with a constraint with a skewness flag
            test.setupTestProject()
            setNrOfConstraintsResponses(test.prj, 1);
            setConstraintType(test.prj, ConstraintType.UpperBound, 1);
            setConstraintIncludeSkewness(test.prj, true, 1);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);
            % Then the ViewModel should have the correct value
            test.verifyTrue(test.vm.constraintIncludeSkewness);

            % When the flag is set to false
            setConstraintIncludeSkewness(test.prj, false, 1);
            % And the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);
            % Then the ViewModel should have the correct value
            test.verifyFalse(test.vm.constraintIncludeSkewness);
        end

        % ----- Fifth tab tests
        
        function presenterHidesOptimizationStatusWhenNotPerformed(test)
            % Given a project with no optimization results
            test.setupTestProject()

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should hide the optimization status
            test.verifyFalse(test.vm.optStatusVisible);
        end

        function presenterShowsSuccessOptimizationStatusWhenNoError(test)
            % Given a project with successful optimization results
            test.setupTestProject()
            test.prj.globX = 1;
            test.prj.globF = 2;
            test.prj.elapsedTime = 3;
            test.prj.lastOptimizationError = "";

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should show the success status
            test.verifyTrue(test.vm.optStatusVisible);
            test.verifyEqual(test.vm.optStatusIcon, "IconSuccess.png");
            test.verifyTrue(test.vm.optStatusText.contains("uccess"));
        end

        function presenterShowsErrorOptimizationStatusWhenError(test)
            % Given a project with error optimization results
            test.setupTestProject()
            test.prj.globX = 1;
            test.prj.globF = 2;
            test.prj.elapsedTime = 3;
            test.prj.lastOptimizationError = "Failed";

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should show the error status
            test.verifyTrue(test.vm.optStatusVisible);
            test.verifyEqual(test.vm.optStatusIcon, "IconFailed.png");
            test.verifyTrue(test.vm.optStatusText.contains("rror"));
        end

        function presenterEnablesMCScatterPlottingAfterOptimization(test)
            % Given a project with successful optimization results
            test.setupTestProject()
            test.prj.globX = 1;
            test.prj.globF = 2;
            test.prj.elapsedTime = 3;
            test.prj.lastOptimizationError = "";
            test.prj.resMC(1).YY = [1 2; 3 4; 5 6];

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should enable MC scatter plotting
            test.verifyTrue(test.vm.canPerformMConOpt);
            test.verifyTrue(test.vm.mcPlotDropDownEnabled);
        end

        % ----- Sixth tab tests

        function presenterDisablesSeqImprovementWhenNoOptResults(test)
            % Given a project with no optimization results
            test.setupTestProject()

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable sequential improvement
            test.verifyFalse(test.vm.canPerformSeqImprovement);
        end

        function presenterDisablesManualInfillWhenNoOptResults(test)
            % Given a project with no optimization results
            test.setupTestProject()

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should disable manual infill
            test.verifyFalse(test.vm.canRecommendInfill);
        end

        % ----- Other

        function settingTheNrOfDesignVarsUpdatesTheDesignTable(test)
            % Given a Project with 5 design variables
            changeNrOfDesignVariables(test.prj, 5);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have a design table with 5 rows
            test.verifyEqual(height(test.vm.designTable), 5);
            % And the design table should contain the design variables
            test.verifyEqual(test.vm.designTable{:,1}, test.prj.varsDef.designVariables);
            % And the design table should contain the design ranges
            test.verifyEqual(test.vm.designTable{:,2}, test.prj.varsDef.designRanges(:,1));
            test.verifyEqual(test.vm.designTable{:,3}, test.prj.varsDef.designRanges(:,2));
            % And the ViewModel should have the correct number of design variables
            test.verifyEqual(test.vm.nDesignVars, int32(5));
        end

        function settingTheNrOfNoiseVarsUpdatesTheNoiseTable(test)
            % Given a Project with 5 noise variables
            changeNrOfNoiseVariables(test.prj, 5);

            % When the Presenter updates the ViewModel
            test.presenter.updateFromProject(test.prj, test.vm);

            % Then the ViewModel should have a noise table with 5 rows
            test.verifyEqual(height(test.vm.noiseTable), 5);
            % And the noise table should contain the noise variables
            test.verifyEqual(test.vm.noiseTable{:,1}, test.prj.varsDef.noiseVariables);
            % And the noise table should contain the noise means
            test.verifyEqual(test.vm.noiseTable{:,2}, test.prj.noiseSource.inputMean);
            % And the noise table should contain the noise standard deviations
            test.verifyEqual(test.vm.noiseTable{:,3}, test.prj.noiseSource.inputStdDev);
            % And the ViewModel should have the correct number of noise variables
            test.verifyEqual(test.vm.nNoiseVars, int32(5));
        end
    end
end
    
    