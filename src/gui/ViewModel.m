% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ViewModel < handle
    % ViewModel
    %   This class is used to define the view model for the Robustimizer
    %   application. The view model is used to store the data that is
    %   displayed in the GUI.
    %   The view model is normally updated/filled by a Presenter object
    %   using a Project object.
    %
    % Example:
    %   vm = ViewModel();
    %   presenter = Presenter();
    %   prj = Project();
    %   presenter.updateFromProject(prj, vm);

    properties
        % Used in multiple places
        responseNames (:,1) string

        % First tab page
        nDesignVars  int32 = AppConstants.MIN_DESIGN_VARIABLES
        nNoiseVars   int32 = AppConstants.MIN_NOISE_VARIABLES
        nConstraints int32 = AppConstants.MIN_CONSTRAINTS
        designTable  table
        noiseTable   table
        errorRowsDesignTable (:,1) int32
        errorRowsNoiseTable (:,1) int32
        errorTextDesignTable string = "";
        errorTextNoiseTable string = "";
        errorTextDesignVisible logical
        errorTextNoiseVisible logical
        noiseDescriptionMethod NoiseDescriptionMethod = NoiseDescriptionMethod.UserDefined
        nNoiseVarsEnabled logical = true
        noiseTableEnabled string = 'on'

        % Second tab page
        doeSize         double = 20
        doeIncFactorial logical = false
        doeMaxMinDist   logical = false
        doeTable        table
        canCreateDOE    logical = false
        canImportDOE    logical = false
        canSaveDOE      logical = false
        importResultsMethod ImportResultsMethod = ImportResultsMethod.FromFile
        scriptFile      string
        scriptFileBackgroundColor (1,3) double = [1 1 1]
        canReadResults  logical = false
        canChooseScript logical = false
        canRunScript    logical = false
        chosenScriptFieldEnabled logical = false
        outputTable     table

        % Third tab page
        srgModelType        string = "Gaussian Process"
        srgModelTypes (:,1) string = ["Gaussian Process"]
        srgModelFitIcon     string = "IconFailed.png"
        srgModelFitLabel    string  = "Surrogate model not fitted"
        canFitSrgModel      logical = false

        canPerformCV        logical = false
        currentCVResponse   string = "Main Response"
        cvResponseDropDownEnabled logical = false
        cvPlotTypesEnabled  logical = false
        cvPlotTypes = ["Cross Validation Plot", "Standardised residual plot"]
        currentCVPlotType   string = "Cross Validation Plot"
        cvResultsText       string = "No cross validation performed"
        cvPlotArea          matlab.ui.control.UIAxes
        
        currentSrgModelResponse int32 = 0
        currentSrgModelResponseName string;
        srgModelResponseDropDownEnabled logical = false
        sliderData              ParameterSliderState
        srgModelPlotArea        matlab.ui.control.UIAxes
        xVarIndex               int32 = 0
        yVarIndex               int32 = 0
        xVarName                string  = ""
        yVarName                string  = ""
        axesDropDownsEnabled    logical = false
        axisDropDownItems (:,1) string
        
        % Fourth tab page
        optMethod       OptimizationMethod = OptimizationMethod.SQP
        noiPropMthd     NoisePropagationMethod = NoisePropagationMethod.Analytical
        MCFieldsEnabled logical = false
        MCSampleSize    string
        canCreateMC     logical = false
        canSaveMC       logical = false
        canLoadMC       logical = false
        MCStatusIcon    string  = "IconFailed.png"
        MCStatusText    string  = "MC sample not created"
        MCStatusVisible logical = true
        objFuncType     ObjectiveFunctionType
        objFuncTarget   double  = 0
        objFuncTargetEnabled logical = false
        objFuncIncSkewness logical

        constraintsEnabled logical = false
        constraintNames (:,1) string = [""]
        currentConstraint int32 = 1
        currentConstraintName string = ""
        constraintType ConstraintType = ConstraintType.Equality
        constraintValue double = 0
        constraintSigma string
        constraintUBVisible logical = false;
        constraintLBVisible logical = false;
        constraintEqVisible logical = false;
        constraintIncludeSkewness logical = false;

        % Fifth tab page
        optResultsText string = "No optimization performed"
        optElapsedTime string = ""
        optStatusIcon  string = "IconFailed.png"
        optStatusText  string = "Optimization not performed"
        optStatusVisible logical = false
        canPerformMConOpt logical = false
        currentResponseForMCPlot string = "Main Response"
        respDistPlotArea matlab.ui.control.UIAxes
        mcPlotDropDownEnabled logical = false

        % Sixth tab page
        seqUpdateType SeqUpdateType = SeqUpdateType.JonesCriteria
        weightGlobLocEnabled logical = true
        canRecommendInfill logical = false
        manualInfillText string = ""
        canSaveInfillToDOE logical = false
        canPerformSeqImprovement logical = false
        numberOfImprovementSteps double = 10
        seqInfillText string = ""
        seqOptResultsText string = ""
    end
end
