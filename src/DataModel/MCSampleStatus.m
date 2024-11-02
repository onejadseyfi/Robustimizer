% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef MCSampleStatus
    %MCSAMPLESTATUS Enumeration of the possible statuses of a Monte Carlo sample
    properties
        userMessage (1,1) string = "";
        isValid (1,1) logical = false;
    end
    enumeration
        % There is sample yet
        None ("No sample available", false)
        % The sample was created (generated)
        Created ("MC sample created", true)
        % The sample was loaded from a file
        Loaded ("MC sample loaded", true)
    end
    methods
        function obj = MCSampleStatus(userMessage, isValid)
            obj.userMessage = userMessage;
            obj.isValid = isValid;
        end
    end
end