% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef OptimizationSettings < handle
    properties
        optMthd (1,1) OptimizationMethod;
        objectiveFuncSpec (1,1) ObjectiveFunctionSpec;
        noiPropMthd (1,1) NoisePropagationMethod;
        nMC (1,1) double;  % Number of Monte Carlo samples
        noiDesOfExp (:,:) double; % Design of experiments for noise variables
    end

    methods
        function obj = OptimizationSettings()
            obj.optMthd = OptimizationMethod.SQP;
            obj.objectiveFuncSpec = ObjectiveFunctionSpec();
            obj.noiPropMthd = NoisePropagationMethod.Analytical;
            obj.nMC = 1000;
            obj.noiDesOfExp = [];
        end
    end
end