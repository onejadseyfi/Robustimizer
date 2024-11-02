% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef NoiseDataSource < handle
    %NOISEDATASOURCE Datasource for optimization problems with optional mapping between user input and internal representation.
    %   This class is either initialized with a given mean and standard deviation
    %   or with a set of data points from which the mean and standard deviation
    %   are calculated.
    %
    %   When the mean and standard deviation are given, the internal representation
    %   is the same as the 'user input' representation and no mapping occurs.
    %
    %   When a set of data points is given, a Principal Component Analysis is
    %   performed to find a suitable mean and standard deviation for the 
    %   internal representation, as well as a transformation matrix for 
    %   mapping back to the 'user input' representation.
    %
    %   The internal representation is used for optimization calculations,
    %   while the 'user input' representation is for reporting to the user.
    properties(GetAccess=public, SetAccess=private)
        mean (:,1) double = [];
        stdDev (:,1) double = [];
        inputData (:,:) double = [];
        inputMean (:,1) double = [];
        inputStdDev (:,1) double = [];
        transformationMatrix (:,:) double = [];
        descriptionMethod (1,1) NoiseDescriptionMethod = NoiseDescriptionMethod.UserDefined;
    end

    properties(Dependent)
        distribution (:,2) double;
        ranges (:,2) double;
    end

    properties(Constant)
        % The number of standard deviations to use for the ranges
        nStdDevs = 3;
    end

    methods
        function obj = NoiseDataSource(mean, stdDev)
            if nargin == 2
                obj.mean = mean;
                obj.stdDev = stdDev;
                % Assume no transformation/mapping is needed
                obj.inputMean = mean;
                obj.inputStdDev = stdDev;
                obj.transformationMatrix = eye(length(mean));
                obj.descriptionMethod = NoiseDescriptionMethod.UserDefined;
            end
        end

        function initializeFromInputData(obj, inputData)
            obj.inputData = inputData;
            obj.inputStdDev = std(obj.inputData);
            obj.inputMean = mean(obj.inputData);
            obj.descriptionMethod = NoiseDescriptionMethod.FromNoiseData;

            % Principal Component Analysis
            tempU = obj.inputData';
            nDataRows = size(obj.inputData, 1);
            U0 = (tempU - repmat(mean(obj.inputData, 1)', [1, nDataRows]));
            U = U0 ./ repmat(std(U0, 0, 2), [1, nDataRows]);
            [~, Apod, ~, Vpod] = pod(U);
                        
            obj.mean = mean(Apod, 2);
            obj.stdDev = std(Apod, 0, 2);
            obj.transformationMatrix = Vpod';
        end

        function resize(obj, newNrOfVariables)
            % Assumes no transformation/mapping is needed
            delta = newNrOfVariables - length(obj.mean);
            if delta <= 0
                obj.mean = obj.mean(1:newNrOfVariables);
                obj.stdDev = obj.stdDev(1:newNrOfVariables);
                obj.inputMean = obj.inputMean(1:newNrOfVariables);
                obj.inputStdDev = obj.inputStdDev(1:newNrOfVariables);
            else
                obj.mean = [obj.mean; zeros(delta, 1)];
                obj.stdDev = [obj.stdDev; ones(delta, 1)];
                obj.inputMean = [obj.inputMean; zeros(delta, 1)];
                obj.inputStdDev = [obj.inputStdDev; ones(delta, 1)];
            end
            obj.transformationMatrix = eye(newNrOfVariables);
        end

        function distribution = get.distribution(obj)
            distribution(:,1) = obj.mean;
            distribution(:,2) = obj.stdDev;
        end

        function ranges = get.ranges(obj)
            ranges(:,1) = obj.mean - obj.nStdDevs*obj.stdDev;
            ranges(:,2) = obj.mean + obj.nStdDevs*obj.stdDev;
        end

        function [internalRepr, inputRepr] = mapNormalizedPoints(obj, normalizedPoints)
            % Map a set of normalized points to the internal representation
            % and the 'user input' representation.
            nParams = height(obj.mean);
            internalRepr = obj.mapFromNormalized(normalizedPoints, obj.mean, obj.stdDev, eye(nParams));
            inputRepr = obj.mapFromNormalized(normalizedPoints, obj.inputMean, obj.inputStdDev, obj.transformationMatrix);
        end

        function mappedPoint = mapInternalToUser(obj, pointInInternalRepr)
            % Maps a point from internal representation to user input representation.

            % First bring back to normalized values so we can use mapFromNormalized()
            tmp1 = pointInInternalRepr - obj.mean';
            tmp2 = tmp1./ (obj.nStdDevs*obj.stdDev');
            tmp3 = tmp2 / 2 + 0.5;

            % Now map to the input domain
            mappedPoint = obj.mapFromNormalized(tmp3, obj.inputMean, obj.inputStdDev, obj.transformationMatrix);
        end
    end

    methods(Static)
        function [mappedData] = mapFromNormalized(normalizedData, mean, stdDev, transformationMatrix)
            % Maps normalized ([0,1]) data using the given mean, standard deviation and transformation matrix.
            %
            % normalizedData is a matrix with each row representing a point in the normalized domain,
            % so the nr of rows is the number of points and the number of columns is the number of parameters.
            nPoints = size(normalizedData, 1);
            s = repmat(stdDev', [nPoints, 1]);
            m = repmat(mean', [nPoints, 1]);
            mappedData = 2*(normalizedData-0.5);
            mappedData = mappedData * transformationMatrix;
            mappedData = mappedData .* (NoiseDataSource.nStdDevs*s) + m;
        end

        % For debugging purposes
        function plotNoiseDOE(DOE, simulatedResDOE, xColIdx, yColIdx, inputData)
            figure("Name","noise part of DOE (as used in optimization)");
            scatter(DOE(:,xColIdx), DOE(:,yColIdx));
            xlabel(sprintf("noise data column %d", xColIdx));
            ylabel(sprintf("noise data column %d", yColIdx));

            figure("Name","noise part of DOE (as seen by the user)");
            scatter(simulatedResDOE(:,xColIdx), simulatedResDOE(:,yColIdx));
            xlabel(sprintf("noise data column %d", xColIdx));
            ylabel(sprintf("noise data column %d", yColIdx));
            if ~isempty(inputData)
                 hold on
                 scatter(inputData(:,xColIdx), inputData(:,yColIdx));
            end
        end
    end
end
