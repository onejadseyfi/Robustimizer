% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef OptimizationMethod
    enumeration
        SQP
        InteriorPoint
    end

    methods
        function str = algorithmName(index)
            %ALGORITHMNAME Corresponding string for use in MATLAB's optimoptions
            switch index
                case OptimizationMethod.SQP
                    str = 'SQP';
                case OptimizationMethod.InteriorPoint
                    str = 'InteriorPoint';
                otherwise
                    error('Unknown OptimizationMethod');
            end
        end
    end
end