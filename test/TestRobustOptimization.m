% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestRobustOptimization < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function braninExampleWithGivenOutputsTest(testCase)
            % Given these inputs and outputs
            designRanges = [-5 10];
            noiseDistributions = [7.5 2.5];
            DOE = readmatrix('test_branin_in.txt');
            outputValues = readmatrix('test_branin_out.txt');

            % ... and these derived inputs and settings
            nInpVar = height(designRanges) + height(noiseDistributions);
            settings.optMthd = OptimizationMethod.SQP;
            settings.stochMthd = 3;
            settings.noiDesOfExp = [];
            inputs.DOE = DOE;
            inputs.outputVal = outputValues;
            inputs.srgModel = fitGP(DOE, nInpVar, outputValues);
            inputs.nDesVar = height(designRanges);
            inputs.desRng = designRanges;
            inputs.nNoiVar = height(noiseDistributions);
            inputs.noiDistr = noiseDistributions;
            inputs.gExplicit = [];
            inputs.hExplicit = [];
            inputs.outID = {'Main Response'};
            objFunSpec = ObjectiveFunctionSpec();
            objFunSpec.type = ObjectiveFunctionType.MinMeanMinT1Sigma;
            inputs.Obj = objFunSpec.formula();
            inputs.skewObjIncl = false;
            inputs.skewConIncl = [];
            inputs.nSigSkewObj = [];

            % When the robust optimization is performed
            [globX, globF]=RobustOpt(settings,inputs);

            % Then the expected results are
            verifyEqual(testCase, globX, 2.3544,   'AbsTol', 1e-3);
            verifyEqual(testCase, globF, 785.3001, 'AbsTol', 1e-3);
        end

        function B1ExampleWithGivenOutputsTest(testCase)
            % Given these inputs and outputs
            designRanges = [6 8; 70 80];
            noiseDistributions = [3 1; 2.3 0.1];
            DOE = readmatrix('test_B1_in.txt');
            outputValues = readmatrix('test_B1_out.txt');
            
            % ... and these derived inputs and settings
            nInpVar = height(designRanges) + height(noiseDistributions);
            settings.optMthd = OptimizationMethod.SQP;
            settings.stochMthd = 3;
            settings.noiDesOfExp = [];
            inputs.DOE = DOE;
            inputs.outputVal = outputValues;
            inputs.srgModel = fitGP(DOE, nInpVar, outputValues);
            inputs.nDesVar = height(designRanges);
            inputs.desRng = designRanges;
            inputs.nNoiVar = height(noiseDistributions);
            inputs.noiDistr = noiseDistributions;
            inputs.gExplicit = [];
            inputs.hExplicit = [];
            inputs.outID = {'Main Response'};
            objFunSpec = ObjectiveFunctionSpec();
            objFunSpec.type = ObjectiveFunctionType.MinMeanMinT1Sigma;
            inputs.Obj = objFunSpec.formula();            
            %inputs.Obj = '(mu(1).mu-0)^2+(sigma(1).sigma)^2';
            inputs.skewObjIncl = false;
            inputs.skewConIncl = false;
            inputs.nSigSkewObj = [];

            % When the robust optimization is performed
            [globX, globF]=RobustOpt(settings,inputs);

            % Then the expected results are
            verifyEqual(testCase, globX, [7.8339  70.0000], 'AbsTol', 1e-3);
            verifyEqual(testCase, globF, 2.2127, 'AbsTol', 1e-3);
        end
        
        function braninExampleWithSkewness(testCase)
            % Given these inputs and outputs
            designRanges = [-5 10];
            noiseDistributions = [7.5 2.5];
            DOE = readmatrix('test_branin_in.txt');
            outputValues = readmatrix('test_branin_out.txt');

            % ... and these derived inputs and settings
            nInpVar = height(designRanges) + height(noiseDistributions);
            settings.optMthd = OptimizationMethod.SQP;
            settings.stochMthd = 3;
            settings.noiDesOfExp = [];
            inputs.DOE = DOE;
            inputs.outputVal = outputValues;
            inputs.srgModel = fitGP(DOE, nInpVar, outputValues);
            inputs.nDesVar = height(designRanges);
            inputs.desRng = designRanges;
            inputs.nNoiVar = height(noiseDistributions);
            inputs.noiDistr = noiseDistributions;
            inputs.gExplicit = [];
            inputs.hExplicit = [];
            inputs.outID = {'Main Response'};
            objFunSpec = ObjectiveFunctionSpec();
            objFunSpec.includeSkewness = true;
            objFunSpec.type = ObjectiveFunctionType.MinMeanMinT1Sigma;
            inputs.Obj = objFunSpec.formula();
            inputs.skewObjIncl = true;
            inputs.skewConIncl = false;
            inputs.nSigSkewObj = 1;

            % When the robust optimization is performed
            [globX, globF]=RobustOpt(settings,inputs);

            % Then the expected results are
            verifyEqual(testCase, globX, 1.1220,   'AbsTol', 1e-3);
            verifyEqual(testCase, globF, 1478.9476, 'AbsTol', 1e-3);
        end
    end
    
end