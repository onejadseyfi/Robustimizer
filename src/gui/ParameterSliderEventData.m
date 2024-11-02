% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ParameterSliderEventData < event.EventData
    properties
        Index
        Id
        Value
    end
    methods
        function obj = ParameterSliderEventData(index, id, value)
            obj.Index = index;
            obj.Id = id;
            obj.Value = value;
        end
    end
end