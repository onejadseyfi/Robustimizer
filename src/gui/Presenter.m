% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef Presenter

    properties(Constant)
        COLOR_ERROR = [1 0.6 0.6]
        COLOR_WHITE = [1 1 1]
    end

    methods
        function updateFromProject(obj, prj, vm)
            arguments
                obj
                prj Project
                vm  ViewModel
            end

            % General / multiple uses
            vm.responseNames = prj.outputNames;

            obj.updateFirstTabPage(prj, vm);
            obj.updateSecondTabPage(prj, vm);
            obj.updateThirdTabPage(prj, vm);
            obj.updateFourthTabPage(prj, vm);
            obj.updateFifthTabPage(prj, vm);
            obj.updateSixthTabPage(prj, vm);
        end

        function updateFirstTabPage(obj, prj, vm)
            % First tab page
            vm.nDesignVars  = prj.varsDef.nDesignVars;
            vm.nNoiseVars   = prj.varsDef.nNoiseVars;
            vm.nConstraints = length(prj.constraintSpec);
            vm.designTable = table(prj.varsDef.designVariables, ...
                                    prj.varsDef.designRanges(:,1), ...
                                    prj.varsDef.designRanges(:,2));
            vm.noiseTable = table(prj.varsDef.noiseVariables, ...
                                    prj.noiseSource.inputMean, ...
                                    prj.noiseSource.inputStdDev);
            vm.noiseDescriptionMethod = prj.noiseSource.descriptionMethod;
            switch vm.noiseDescriptionMethod
                case NoiseDescriptionMethod.UserDefined
                    vm.nNoiseVarsEnabled = true;
                    vm.noiseTableEnabled = 'on';
                    vm.canImportDOE = true;
                case NoiseDescriptionMethod.FromNoiseData
                    vm.nNoiseVarsEnabled = false;
                    vm.noiseTableEnabled = 'off';
                    vm.canImportDOE = false;
                otherwise
                    error('Unknown noise description method: %s', vm.noiseDescriptionMethod);
            end
        end

        function updateSecondTabPage(obj, prj, vm)
            % Second tab page
            vm.canCreateDOE = prj.varsDef.count > 0;
            vm.canSaveDOE = ~isempty(prj.simulResDOE);
            vm.doeTable = array2table(prj.simulResDOE);
            if ~isempty(vm.doeTable)
                vm.doeTable.Properties.RowNames = compose("DOE#%d", 1:height(vm.doeTable));
                vm.doeTable.Properties.VariableNames = prj.varsDef.names;
            end
            vm.outputTable = array2table(prj.outputVal);
            if ~isempty(vm.outputTable)
                vm.outputTable.Properties.VariableNames = prj.outputNames;
                vm.outputTable.Properties.RowNames = compose("DOE#%d", 1:height(vm.outputTable));
            end

            if prj.scriptFileName ~= ""
                vm.importResultsMethod = ImportResultsMethod.GenerateWithExecutable;
            end
            vm.scriptFile = prj.scriptFileName;
            scriptFileExists = isfile(vm.scriptFile);
            switch vm.importResultsMethod
                case ImportResultsMethod.FromFile
                    vm.canReadResults = true;
                    vm.canChooseScript = false;
                    vm.canRunScript = false;
                    vm.chosenScriptFieldEnabled = false;
                    vm.scriptFile = "";
                case ImportResultsMethod.GenerateWithExecutable
                    vm.canReadResults = false;
                    vm.canChooseScript = true;
                    vm.canRunScript = true;
                    vm.chosenScriptFieldEnabled = true;
                    vm.scriptFile = prj.scriptFileName;
                otherwise
                    error('Unknown import results method: %s', vm.importResultsMethod);
            end
            if ~scriptFileExists
                vm.scriptFileBackgroundColor = Presenter.COLOR_ERROR;
            else
                vm.scriptFileBackgroundColor = Presenter.COLOR_WHITE;
            end
            if isempty(vm.scriptFile) || ~scriptFileExists || isempty(vm.doeTable)
                vm.canRunScript = false;
            end
        end

        function updateThirdTabPage(obj, prj, vm)
            % Third tab page
            vm.canFitSrgModel = ~isempty(prj.DOE) && ~isempty(prj.outputVal);
            vm.srgModelType   = 'Gaussian Process';
            if isempty(prj.srgModel)
                vm.srgModelFitIcon  = 'IconFailed.png';
                vm.srgModelFitLabel = 'Surrogate model not fitted';
            else
                vm.srgModelFitIcon  = 'IconSuccess.png';
                vm.srgModelFitLabel = 'Surrogate model fitted';
            end
            vm.canPerformCV = ~isempty(prj.srgModel);
            cvResponseIndex = find(vm.responseNames == vm.currentCVResponse);
            if isempty(cvResponseIndex)
                % Current response is no longer in the list of responses, switch to the main response.
                cvResponseIndex = 1;
                vm.currentCVResponse = vm.responseNames(cvResponseIndex);
            end
            vm.cvResponseDropDownEnabled = ~isempty(prj.crossValidationResults);
            vm.cvPlotTypesEnabled = ~isempty(prj.crossValidationResults);
            vm.cvResultsText  = obj.crossValidationResultsText(cvResponseIndex, prj.crossValidationResults);
            if ~isempty(prj.crossValidationResults)
                results = prj.crossValidationResults;
                obj.updateCrossValidationPlot(vm.cvPlotArea, vm.currentCVPlotType, cvResponseIndex, vm.currentCVResponse, prj.outputVal, results);
            else
                cla(vm.cvPlotArea);
            end

            % Select sensible default x and y variables for the surrogate model plot if the current ones are invalid
            if (prj.varsDef.count > 1) && (vm.xVarIndex < 1) || (vm.xVarIndex > prj.varsDef.count)
                vm.xVarIndex = 1;
            end
            if (vm.yVarIndex < 1) || (vm.yVarIndex > prj.varsDef.count)
                if prj.varsDef.count > 0
                    vm.yVarIndex = 1;

                end
                if prj.varsDef.count > 1
                    vm.yVarIndex = 2;
                end
            end
            vm.xVarName = prj.varsDef.names(vm.xVarIndex);
            vm.yVarName = prj.varsDef.names(vm.yVarIndex);
            vm.axesDropDownsEnabled = prj.varsDef.count > 1 && ~isempty(prj.srgModel);
            vm.axisDropDownItems = prj.varsDef.names;
            vm.srgModelResponseDropDownEnabled = ~isempty(prj.srgModel);

            % Select sensible surrogate model response if the current one is invalid
            if (vm.currentSrgModelResponse < 1) || (vm.currentSrgModelResponse > prj.nOutputs)
                vm.currentSrgModelResponse = 1;
                vm.currentSrgModelResponseName = vm.responseNames(vm.currentSrgModelResponse);
            end

            % Set default slider data if it is not set or if the number of variables has changed
            slidersInitialized = ~isempty(vm.sliderData);
            nrOfSlidersNeedChange = length(vm.sliderData) ~= prj.varsDef.count;
            if ~slidersInitialized || nrOfSlidersNeedChange
                vm.sliderData = obj.resetSliderStates(prj, vm.xVarIndex, vm.yVarIndex);
            end
            sliderRangesNeedChange = any([vm.sliderData.range]' ~= prj.varsDef.ranges, 'all');
            if sliderRangesNeedChange
                % When the ranges have changed, reset the slider values to the middle of the new ranges.
                % This prevents the old slider values from being out of range and causing errors.
                vm.sliderData = obj.resetSliderStates(prj, vm.xVarIndex, vm.yVarIndex);
            end
            % Disable the sliders corresponding to the current x & y vars
            vm.sliderData = obj.disableSliders(vm.sliderData, [vm.xVarIndex, vm.yVarIndex]);
            
            if ~isempty(prj.srgModel)
                if (vm.xVarIndex < 1) || (vm.xVarIndex > prj.varsDef.count) || ...
                    (vm.yVarIndex < 1) || (vm.yVarIndex > prj.varsDef.count) || ...
                        (vm.currentSrgModelResponse < 1) || (vm.currentSrgModelResponse > prj.nOutputs)
                    cla(vm.srgModelPlotArea);
                else
                    obj.updateSurrogatePlot(vm.srgModelPlotArea, prj, vm.xVarIndex, vm.yVarIndex, vm.currentSrgModelResponse, vm.sliderData);
                end
            else
                cla(vm.srgModelPlotArea);
            end            
        end

        function updateFourthTabPage(obj, prj, vm)
            % Fourth tab page
            vm.optMethod    = prj.optSettings.optMthd;
            vm.noiPropMthd  = prj.optSettings.noiPropMthd;
            vm.MCSampleSize = prj.optSettings.nMC;
            vm.MCFieldsEnabled = prj.optSettings.noiPropMthd ~= NoisePropagationMethod.Analytical;
            vm.canCreateMC  = vm.MCFieldsEnabled;
            vm.canSaveMC    = ~isempty(prj.optSettings.noiDesOfExp);
            vm.canLoadMC    = vm.canCreateMC;
            vm.MCSampleSize = sprintf('%d', prj.optSettings.nMC);
            requestedSampleSize = prj.optSettings.nMC;
            generatedSampleSize = size(prj.optSettings.noiDesOfExp, 1);
            if generatedSampleSize > 0
                if (requestedSampleSize == generatedSampleSize) 
                    vm.MCStatusIcon = 'IconSuccess.png';
                    vm.MCStatusText = 'MC sample created';
                else
                    vm.MCStatusIcon = 'IconFailed.png';
                    vm.MCStatusText = 'MC sample out of date';
                end
            else
                vm.MCStatusIcon = 'IconFailed.png';
                vm.MCStatusText = 'MC sample not created';
            end

            vm.objFuncType        = prj.optSettings.objectiveFuncSpec.type;
            vm.objFuncTarget      = prj.optSettings.objectiveFuncSpec.targetValue;
            vm.objFuncTargetEnabled = obj.objFuncTypeNeedsTarget(vm.objFuncType);
            vm.objFuncIncSkewness = prj.optSettings.objectiveFuncSpec.includeSkewness;

            vm.constraintsEnabled = ~isempty(prj.constraintSpec);
            nConstraints = length(prj.constraintSpec);
            if nConstraints > 0
                vm.constraintNames = compose("Constraint%d", 1:nConstraints);
                if vm.currentConstraint < 1 || vm.currentConstraint > nConstraints
                    vm.currentConstraint = 1;
                end
            else
                vm.constraintNames = "";
                vm.currentConstraint = 1;
                vm.currentConstraintName = "";
            end
            if nConstraints == 0 || vm.currentConstraint < 1 || vm.currentConstraint > nConstraints
                vm.constraintType = "Equality";
                vm.constraintValue = 0;
                vm.constraintSigma = "+3";
                vm.constraintIncludeSkewness = false;
                vm.constraintUBVisible = false;
                vm.constraintLBVisible = false;
                vm.constraintEqVisible = false;
            else
                c = prj.constraintSpec(vm.currentConstraint);
                vm.currentConstraintName = vm.constraintNames(vm.currentConstraint);
                vm.constraintUBVisible = c.type == ConstraintType.UpperBound;
                vm.constraintLBVisible = c.type == ConstraintType.LowerBound;
                vm.constraintEqVisible = c.type == ConstraintType.Equality;
                vm.constraintType  = c.type;
                vm.constraintValue = c.value;
                vm.constraintSigma = sprintf("%+d", c.sigmaLevel);
                vm.constraintIncludeSkewness = c.includeSkewness;
            end
        end

        function updateFifthTabPage(obj, prj, vm)
            % Fifth tab page
            if isempty(prj.globX)
                vm.optStatusIcon = 'IconFailed.png';
                vm.optStatusText = 'Optimization not performed';
                vm.optStatusVisible = false;
                vm.optResultsText = 'No optimization performed';
            else
                if ~isempty(prj.lastOptimizationError) && (prj.lastOptimizationError ~= "")
                    vm.optStatusIcon = 'IconFailed.png';
                    vm.optStatusText = 'Error during optimization';
                    vm.optStatusVisible = true;
                    vm.optResultsText = 'Error during optimization';
                else
                    vm.optStatusIcon = 'IconSuccess.png';
                    vm.optStatusText = 'Optimization Successful!';
                    vm.optStatusVisible = true;
                    vm.optResultsText = obj.optimizationResultsText(prj.varsDef.nDesignVars, prj.globX, prj.globF, prj.elapsedTime);
                end
            end
            vm.canPerformMConOpt = ~isempty(prj.globX);
            vm.mcPlotDropDownEnabled = ~isempty(prj.resMC);
            index = find(vm.responseNames == vm.currentResponseForMCPlot);
            if ~isempty(vm.respDistPlotArea)
                if isempty(prj.resMC) || (index < 1) || (index > length(prj.resMC))
                    cla(vm.respDistPlotArea);
                else
                    obj.updateResponseDistributionPlot(vm.respDistPlotArea, vm.currentResponseForMCPlot, prj.resMC(index).YY);
                end
            end
        end

        function updateSixthTabPage(obj, prj, vm)
            % Sixth tab page
            vm.seqUpdateType = prj.infillMethod;
            vm.weightGlobLocEnabled = prj.infillMethod == SeqUpdateType.JonesCriteria;
            vm.canRecommendInfill = ~isempty(prj.globX);
            vm.manualInfillText = obj.manualInfillText(prj.lastRecommendation, prj.varsDef.count);
            vm.canSaveInfillToDOE = ~isempty(prj.lastRecommendation);
            vm.canPerformSeqImprovement = ~isempty(prj.globX) && vm.numberOfImprovementSteps > 0;
            vm.seqInfillText = join(prj.seqRecommendationTexts, newline);
            vm.seqOptResultsText = join(prj.seqOptResultTexts, newline);
        end

        function text = crossValidationResultsText(obj, responseIndex, results)
            arguments
                obj
                responseIndex int32
                results struct
            end

            if isempty(results)
                text = 'No cross-validation results available';
                return;
            end
            if (responseIndex < 1) || (responseIndex > length(results.RMSE))
                text = 'Select a response to view cross-validation results';
                return;
            end
                
            text = sprintf('RMSEcv = %2.4g\n R^2_prediction = %2.4g\n R^2_prediction adjusted = %2.4g', ...
                            results.RMSE(responseIndex), ...
                            results.R2pred(responseIndex), ...
                            results.R2predadj(responseIndex));
        end

        function updateCrossValidationPlot(obj, plotArea, plotType, responseIndex, responseName, outputValues, results)
            arguments
                obj
                plotArea matlab.ui.control.UIAxes
                plotType string
                responseIndex int32
                responseName string
                outputValues (:,:) double
                results struct
            end
            out = outputValues;

            if isempty(results)
                cla(plotArea);
                return;
            end

            switch plotType
                case "Cross Validation Plot"
                    plot(plotArea, ...
                        out(:,responseIndex), results.Ypred(:,responseIndex),'o', ...
                        out(:,responseIndex), out(:,responseIndex),'r');
                    title(plotArea,'Cross Validation plot');
                    xlabel(plotArea,sprintf('Actual: %s', responseName));
                    ylabel(plotArea,sprintf('Predicted: %s', responseName));
                case "Standardised residual plot"
                    scatter(plotArea, ...
                        out(:,responseIndex), results.residuals(:,responseIndex), ...
                        20, [1 0.9 0.75], 'b');
                    hold(plotArea, 'on');
                    plot(plotArea, ...
                        out(:,responseIndex),  2*ones(size(out(:,responseIndex))), 'r--', ...
                        out(:,responseIndex), -2*ones(size(out(:,responseIndex))), 'r--', ...
                        out(:,responseIndex),  3*ones(size(out(:,responseIndex))), 'r:', ...
                        out(:,responseIndex), -3*ones(size(out(:,responseIndex))), 'r:')
                    title(plotArea, 'Standardised CV error plot')
                    xlabel(plotArea, sprintf('Actual: %s', responseName));
                    ylabel(plotArea, 'Standardised CV errors: e')
                    hold(plotArea, 'off');
                otherwise
                    error('Unknown cross validation plot type requested: %s', plotType);
            end
        end

        
        function sliderData = makeSliderData(~, names, ranges, values, disabledSliders)
            count = length(names);
            roundedRanges = round(ranges, 3);
            sliderData = ParameterSliderState.BuildNSliderStates(count, "param");
            for i=1:count
                range = roundedRanges(i,:);
                if range(1) > range(2) % Swap the range if it is not in the correct order
                    range = [range(2), range(1)];
                end
                if range(1) == range(2) % If the range is a single value, expand it to prevent errors
                    range(2) = range(2) + 1;
                end
                % Clip the value to be in the range (note that R2024 has a clip function, but it is not available in R2022b)
                value = min(max(values(i),range(1)),range(2));

                sliderData(i).label = names(i);
                sliderData(i).range = range;
                sliderData(i).value = value;
                sliderData(i).enabled = ~any(disabledSliders == i);
            end
        end
        
        function sliderStates = resetSliderStates(obj, prj, xVarIndex, yVarIndex)
            varRanges = prj.varsDef.ranges;
            varNames  = prj.varsDef.names;

            % initialize slider values to the middle of the range
            sliderValues = (varRanges(:,1) + varRanges(:,2)) / 2;
            % Disable the sliders corresponding to the current x & y vars
            disabledSliders = [xVarIndex, yVarIndex];

            sliderStates = obj.makeSliderData(varNames, varRanges, sliderValues, disabledSliders);
        end

        function sliderStates = disableSliders(obj, sliderStates, indices)
            % Disables the sliders at the given indices and enables the
            % other slides.
            nSliders = length(sliderStates);
            for i = 1:nSliders
                sliderStates(i).enabled = ~any(indices==i);
            end
        end

        function updateSurrogatePlot(~, plotArea, prj, indexX, indexY, responseIndex, sliderStates)
            if isempty(prj.srgModel)
                cla(plotArea);
            else
                varValues = [sliderStates.value];
                plotSurrogateModel(plotArea, prj, indexX, indexY, responseIndex, varValues);
            end
        end

        function setDesignTableErrors(~, vm, errorRows, errorMessage)
            vm.errorTextDesignTable = errorMessage;
            vm.errorRowsDesignTable = errorRows;
            vm.errorTextDesignVisible = ~isempty(errorMessage);
        end

        function setNoiseTableErrors(~, vm, errorRows, errorMessage)
            vm.errorTextNoiseTable = errorMessage;
            vm.errorRowsNoiseTable = errorRows;
            vm.errorTextNoiseVisible = ~isempty(errorMessage);
        end

        function result = objFuncTypeNeedsTarget(~, objFuncType)
            result = (objFuncType == ObjectiveFunctionType.MinMeanMinT1Sigma) || ...
                     (objFuncType == ObjectiveFunctionType.MinMeanMinT3Sigma) || ...
                     (objFuncType == ObjectiveFunctionType.MinMeanMinT6Sigma);
        end

        function text = optimizationResultsText(~, nDesignVars, globX, globF, elapsedTime)
            if isempty(globX)
                text = 'No optimization results available';
                return;
            end
            text = sprintf(strcat('Optimum design is : \n',repmat('%8.4f ',[1,nDesignVars]),'\n The optimum objective function value is:\n%8.4f\nElapsed Time (s):\n%8.4f'),globX,globF,elapsedTime);
        end

        function updateResponseDistributionPlot(~, plotArea, responseName, data)
            if isempty(data)
                cla(plotArea);
            else
                Fsize = 12; % Fontsize for figures
                histogram(plotArea, data, 'FaceColor', [1 0.9 0.75]);
                xlabel(plotArea, responseName, 'FontSize', Fsize);
                ylabel(plotArea, 'density', 'FontSize', Fsize);
            end
        end

        function text = manualInfillText(~, lastRecommendation, nVars)
            if isempty(lastRecommendation)
                text = '';
            else
                rec = lastRecommendation;
                text = sprintf(strcat('The recommended infill point is : \n', ...
                    repmat('%8.4f ',[1,nVars]), ...
                    '\nThe maximum expected improvement value is:\n%f\nElapsed Time (s):\n%8.4f'), ...
                    [rec.mappedDes, rec.mappedNoi], rec.maxEI, rec.elapsedTime);
            end
        end
    end
end