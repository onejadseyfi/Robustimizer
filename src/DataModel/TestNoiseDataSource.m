% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef TestNoiseDataSource < matlab.unittest.TestCase
    properties
        src
    end
    
    methods(TestMethodSetup)
        function setup(test)
            test.src = NoiseDataSource();
        end
    end
    
    methods(Static)
        function data = generate2DData(nDataPoints, xRange, yRange, correlation)
            % Generate random data with the given mean and standard deviation
            u = copularnd('Gaussian', correlation, nDataPoints);
            data = [min(xRange) + u(:,1).*(max(xRange)-min(xRange)) ...
                    min(yRange) + u(:,2).*(max(yRange)-min(yRange))];
        end
    end

    methods(Test)

        function testThatNoiseDataSourceIsInitiallyEmpty(test)
            % Given the default NoiseDataSource object test.src
            % Then it should be empty
            test.verifyEmpty(test.src.mean);
            test.verifyEmpty(test.src.stdDev);
            test.verifyEmpty(test.src.inputData);
            test.verifyEmpty(test.src.inputMean);
            test.verifyEmpty(test.src.inputStdDev);
            test.verifyEmpty(test.src.transformationMatrix);
        end

        function testThatConstructingFromMeanAndStdDevGivesAnUnmappedDataSource(test)
            % Given the mean and standard deviation
            parameterMeans = [10; 20; 30];
            parameterStdDevs = [1; 2; 3];
            test.src = NoiseDataSource(parameterMeans, parameterStdDevs);

            % Then the properties should be set as expected
            test.verifyEqual(test.src.mean, parameterMeans);
            test.verifyEqual(test.src.stdDev, parameterStdDevs);
            test.verifyEqual(test.src.inputMean, test.src.mean);
            test.verifyEqual(test.src.inputStdDev, test.src.stdDev);
            test.verifyEqual(test.src.transformationMatrix, eye(3));
        end

        function testThatDistributionPropertyHasMeansAndStdDevColumns(test)
            parameterMeans = [1; 2; 3];
            parameterStdDevs = [4; 5; 6];
            expectedDistribution = [parameterMeans parameterStdDevs];

            test.src = NoiseDataSource(parameterMeans, parameterStdDevs);
            test.verifyEqual(test.src.distribution, expectedDistribution, 'AbsTol', 1e-10);
        end

        function testThatRangesPropertyValuesAreAsExpected(test)
            % Given the mean and standard deviation
            parameterMeans = [1; 2; 3];
            parameterStdDevs = [4; 5; 6];            
            test.src = NoiseDataSource(parameterMeans, parameterStdDevs);

            % When the ranges are calculated by accessing the property
            % Then they should range from -n standard deviations 
            % from the mean to +n standard deviations from the mean
            nStdDevs = NoiseDataSource.nStdDevs;
            test.verifyEqual(test.src.ranges, ...
            [1-nStdDevs*4 1+nStdDevs*4; ...
             2-nStdDevs*5 2+nStdDevs*5; ...
             3-nStdDevs*6 3+nStdDevs*6], 'AbsTol', 1e-10);
        end

        function testThatMappingFromNormalizedToInputWorksWhenUsingMeanAndStdDev(test)
            % Given the mean and standard deviation
            parameterMeans = [100; 200];
            parameterStdDevs = [ 10;  20];
            test.src = NoiseDataSource(parameterMeans, parameterStdDevs);

            % When the normalized data is mapped to input space
            normalizedData = [ 0.5 0.5; ... % corresponds to mean
                               0.0 0.0; ... % corresponds to lower bound
                               1.0 1.0; ];  % corresponds to upper bound
            [internalRepr, mappedData] = test.src.mapNormalizedPoints(normalizedData);

            % Then the result should be the normalized data transformed back
            % to the input space
            expectedMappedData = [100 200; ...  % mean
                                   70 140; ...  % lower bound: mean - 3*stdDev
                                  130 260];     % upper bound: mean + 3*stdDev
            test.verifyEqual(mappedData, expectedMappedData, 'AbsTol', 1e-10);

            % And then the internal representation should be the same as the
            % mapped data as they are defined to be the same when the source
            % is constructed from mean and standard deviation
            test.verifyEqual(mappedData, internalRepr, 'AbsTol', 1e-10);
        end

        function testThatUncorrelatedDataInternalRangeIsSixSigma(test)
            % Given the input data
            xRange = [0 100];
            yRange = [-10 10];
            corrcoef = 0.0001;
            inputData = TestNoiseDataSource.generate2DData(1000, xRange, yRange, corrcoef);
            test.src.initializeFromInputData(inputData);
            
            % When mapping the extremes of the normalized data
            normalizedData = [ 0 0; 1 1; ];
            [internalRepr, ~] = test.src.mapNormalizedPoints(normalizedData);

            % Then the range of the internal representation should be
            % NoiseDataSource.nStdDevs in each direction
            n = NoiseDataSource.nStdDevs;
            expected = [ -n -n; n n];
            test.verifyEqual(internalRepr, expected, 'AbsTol', 0.1);
        end

        function testCorrelatedDataUserRepresentation(test)
            % Given the input data
            xRange = [0 100];
            yRange = [-10 10];
            corrcoef = 0.9999;
            inputData = TestNoiseDataSource.generate2DData(1000, xRange, yRange, corrcoef);
            test.src.initializeFromInputData(inputData);
            
            % When mapping the extremes of the normalized data
            normalizedData = [ 0 0; 1 1; ];
            [~, userRepr] = test.src.mapNormalizedPoints(normalizedData);
            %NoiseDataSource.plotNoiseDOE(internalRepr, userRepr, 1, 2, inputData);

            % Then the user representation is correctly oriented
            % and appropriately scaled
            expected = [ 50 25; 50 -25];
            test.verifyEqual(userRepr, expected, 'RelTol', 10);
        end
    end
end