% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ObjectiveFunctionSpec < handle
    
    properties
        type (1,1) ObjectiveFunctionType = ObjectiveFunctionType.MinMeanPlus3Sigma
        includeSkewness (1,1) logical = false % Analyse skewness of objective function value
        targetValue (1,1) double = 0
    end
    
    methods
        function [f, sigma] = formula(obj)
            if obj.includeSkewness
                [f, sigma] = obj.formulaWithSkewness();
            else
                [f, sigma] = obj.formulaWithoutSkewness();
            end
        end

        function [f, sigma] = formulaWithoutSkewness(obj)
            sigma = [];
            switch obj.type
                case ObjectiveFunctionType.MinSigma
                    f = 'sigma(1).sigma';
                case ObjectiveFunctionType.MinMeanPlusSigma
                    f = 'mu(1).mu+sigma(1).sigma';
                case ObjectiveFunctionType.MinMeanPlus3Sigma
                    f = 'mu(1).mu+3*sigma(1).sigma';
                case ObjectiveFunctionType.MinMeanPlus6Sigma
                    f = 'mu(1).mu+6*sigma(1).sigma';
                case ObjectiveFunctionType.MinMeanMinT1Sigma
                    f = strcat('(mu(1).mu-', num2str(obj.targetValue),')^2+(sigma(1).sigma)^2');
                case ObjectiveFunctionType.MinMeanMinT3Sigma
                    f = strcat('(mu(1).mu-', num2str(obj.targetValue),')^2+3*(sigma(1).sigma)^2');
                case ObjectiveFunctionType.MinMeanMinT6Sigma
                    f = strcat('(mu(1).mu-', num2str(obj.targetValue),')^2+6*(sigma(1).sigma)^2');
                otherwise
                    error("Unsupported objective function type: %s", obj.type);
            end
        end

        function [f, sigma] = formulaWithSkewness(obj)
            switch obj.type
                case ObjectiveFunctionType.MinSigma
                    f = 'sigma(1).sigma';
                    sigma = 1;
                case ObjectiveFunctionType.MinMeanPlusSigma
                    f = '(mu(1).mu)+(U+L)*sigma(1).sigma/2+(U-L)*sigma(1).sigma/2';
                    sigma = 1;
                case ObjectiveFunctionType.MinMeanPlus3Sigma
                    f = '(mu(1).mu)+(U+L)*sigma(1).sigma/2+(U-L)*sigma(1).sigma/2';
                    sigma = 3;
                case ObjectiveFunctionType.MinMeanPlus6Sigma
                    f = '(mu(1).mu)+(U+L)*sigma(1).sigma/2+(U-L)*sigma(1).sigma/2';
                    sigma = 6;
                case ObjectiveFunctionType.MinMeanMinT1Sigma
                    f = strcat('(mu(1).mu-',num2str(obj.targetValue),'+(U+L)*sigma(1).sigma/2)^2+(U-L)/2*(sigma(1).sigma)^2');
                    sigma = 1;
                case ObjectiveFunctionType.MinMeanMinT3Sigma
                    f = strcat('(mu(1).mu-',num2str(obj.targetValue),'+(U+L)*sigma(1).sigma/2)^2+(U-L)/2*(sigma(1).sigma)^2');
                    sigma = 3;
                case ObjectiveFunctionType.MinMeanMinT6Sigma
                    f = strcat('(mu(1).mu-',num2str(obj.targetValue),'+(U+L)*sigma(1).sigma/2)^2+(U-L)/2*(sigma(1).sigma)^2');
                    sigma = 6;
                otherwise
                    error("Unsupported objective function type: %s", obj.type);
            end
        end
    end
end