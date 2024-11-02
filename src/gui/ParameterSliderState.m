% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ParameterSliderState
    properties
        label       string  = "Parameter"
        range (2,1) double = [0 1]
        value       double = 0
        visible     logical = true
        enabled     logical = true
        parameterId int16   = 0
    end   

    methods(Static)
        function states = BuildNSliderStates(n, prefix)
            % Create n instances of ParameterSliderState with sane defaults
            states = repmat(ParameterSliderState, n, 1);
            if isempty(prefix)
                prefix = "Parameter";
            end
            for i = 1:n
                states(i) = ParameterSliderState();
                states(i).label = sprintf("%s %d", prefix, i);
                states(i).parameterId = i;
            end
        end
    end
end
