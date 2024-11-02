% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef Project < handle
    % Project class
    %   Contains the definition of a Robustmizer project.
    properties(GetAccess = public, SetAccess = public)
        name (1,1) string;

        % Design and noise variables
        varsDef (1,1) ParametersDefinition;

        % Number of outputs (constraints + main response)
        nOutputs (1,1) double;

        % Method for noise description
        noiseSource (1,1) NoiseDataSource;

        % Optimization settings
        optSettings (1,1) OptimizationSettings;
       
        % Constraints
        constraintSpec (:,1) ConstraintSpecification;

        % Design of experiments
        DOE (:,:) double;
        % Simulation results on DOE
        simulResDOE (:,:) double;

        % Results
        outputVal (:,:) double;

        % Script to retrieve the output values from the DOE
        scriptFileName (1,1) string;

        % Current fitted surrogate model
        srgModel;

        % Results of the last cross validation
        crossValidationResults struct;

        % Infill method for sequential optimization
        infillMethod (1,1) SeqUpdateType;

        % The last recommended infill point (if any)
        % Calling addLastRecommendedInfillPoint will add this point to the DOE
        lastRecommendation InfillPointRecommendation;

        % Sequential optimization recommendation texts
        seqRecommendationTexts (:,1) string;
        seqOptResultTexts (:,1) string;
        seqOptProgress (1,1) struct;
        
        % Last optimization results
        globX double;
        globF double;
        elapsedTime double;
        lastOptimizationError string;

        % Optimization data to carry over between sequential optimizations steps
        % (or incremental manual steps)
        globOpData GlobOptimizationData;

        % Design of experiment for Monte Carlo analysis
        DOEforMC (:,:) double; 
        % Results of Monte Carlo analysis of the robust optimum design
        resMC
    end

    properties(Dependent)
        outputNames (:,1) string;
        nDOEPoints (1,1) double;
    end

    methods
        function obj = Project()
            obj.name = "Untitled";
            obj.varsDef = ParametersDefinition();
            obj.noiseSource = NoiseDataSource(0, 1);
            obj.optSettings = OptimizationSettings();
            obj.nOutputs = 1;
            obj.constraintSpec = ConstraintSpecification.empty;
            obj.DOE = [];
            obj.simulResDOE = [];
            obj.outputVal = [];
            obj.scriptFileName = "";
            obj.srgModel = [];
            obj.crossValidationResults = struct.empty;
            obj.infillMethod = SeqUpdateType.JonesCriteria;
            obj.lastRecommendation = InfillPointRecommendation.empty;
            obj.globOpData = GlobOptimizationData();
            obj.seqRecommendationTexts = [];
            obj.seqOptResultTexts = [];
            obj.seqOptProgress = struct('current', 0, 'total', 0);
            obj.globX = [];
            obj.globF = [];
            obj.elapsedTime = 0;
            obj.DOEforMC = [];
            obj.resMC = [];
           
            obj.varsDef.setDesignVariables("DesignVar1");
            obj.varsDef.setNoiseVariables("NoiseVar1");
        end

        function names = get.outputNames(obj)
            names = ["Main Response", "Constraint Response " + string(1:obj.nOutputs-1)];
        end

        function nDOEPoints = get.nDOEPoints(obj)
            nDOEPoints = size(obj.DOE, 1);
        end

        function [didAdd] = addLastRecommendedInfillPoint(obj)
            % Add the last recommended infill point to the DOE
            % Returns true if the point was added, false otherwise
            if isempty(obj.lastRecommendation)
                didAdd = false;
                return;
            end

            % Add the recommended design point to the DOE
            obj.DOE = [obj.DOE; obj.lastRecommendation.addedDes, obj.lastRecommendation.addedNoi];
            obj.simulResDOE = [obj.simulResDOE; obj.lastRecommendation.mappedDes, obj.lastRecommendation.mappedNoi];

            obj.lastRecommendation = InfillPointRecommendation.empty;
            didAdd = true;
        end

        function clearDOE(obj)
            obj.DOE = [];
            obj.simulResDOE = [];
            obj.clearOutputValues();
        end

        function clearOutputValues(obj)
            obj.outputVal = [];
            obj.clearSurrogateModel();
        end

        function clearSurrogateModel(obj)
            obj.srgModel = [];
            obj.clearCrossValidationResults();
            obj.clearOptimizationResults();
        end

        function clearCrossValidationResults(obj)
            obj.crossValidationResults = struct.empty;
        end

        function clearOptimizationResults(obj)
            obj.globX = [];
            obj.globF = [];
            obj.elapsedTime = 0;
            obj.globOpData = GlobOptimizationData();
            obj.lastOptimizationError = "";
            obj.lastRecommendation = InfillPointRecommendation.empty;
            obj.DOEforMC = [];
            obj.resMC = [];
            if obj.seqOptProgress.current == 0
                % Not running a sequential optimization, clear any leftover texts
                obj.clearSequentialOptimizationResults();
            end
            if obj.seqOptProgress.current == obj.seqOptProgress.total && obj.seqOptProgress.total > 0
                % Sequential optimization is done, clear the progress.
                % This will ensure the next clear call will clear the texts.
                %disp("Sequential optimization is done, clearing progress");
                obj.seqOptProgress.current = 0;
                obj.seqOptProgress.total = 0;
            end
        end

        function clearSequentialOptimizationResults(obj)
            obj.seqRecommendationTexts = [];
            obj.seqOptResultTexts = [];
        end
    end
end