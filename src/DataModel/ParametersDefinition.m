% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ParametersDefinition < handle
    %PARAMETERSDEFINITION Defines the design and noise parameters
    %


    properties(GetAccess = public, SetAccess = private)
        designVariables (:,1) string = [];
        designRanges(:,2) double = [];
        noiseVariables (:,1) string = [];
        noiseRanges(:,2) double = [];
    end

    properties(Dependent)
        count (1,1) integer
        names (:,1) string;
        ranges(:,2) double;
        nDesignVars (1,1) integer
        nNoiseVars (1,1) integer
    end

    methods(Access=private)
        function resize(obj, prefix, newSize)
            % Resize the number of variables of the given prefix.
            % The class invariant is maintained: the number of names and ranges must be equal.
            if newSize < 0
                error("ParametersDefinition:InvalidSizeError", "New number of %s variables must be >= 0: %d", prefix, newSize);
            end
            if ~ismember(prefix, ["design", "noise"])
                error("Invalid prefix: %s", prefix);
            end
            namesProperty = prefix + "Variables";
            rangesProperty = prefix + "Ranges";
            oldSize = height(obj.(namesProperty));
            delta = newSize - oldSize;
            if delta <= 0
                obj.(namesProperty)  = obj.(namesProperty)(1:newSize);
                obj.(rangesProperty) = obj.(rangesProperty)(1:newSize, :);
            else
                obj.(namesProperty)(oldSize+1:newSize) = obj.friendlyNameFor(prefix) + (oldSize+1:newSize).';
                obj.(rangesProperty)(oldSize+1:newSize, :) = repmat([ 0 1 ], delta, 1);
            end
        end
    end
    
    methods(Static, Access=private)
        function prefix = friendlyNameFor(propertyPrefix)
            switch propertyPrefix
                case "design"
                    prefix = "DesignVar";
                case "noise"
                    prefix = "NoiseVar";
                otherwise
                    error("Invalid prefix: %s", propertyPrefix);
            end
        end
    end

    methods
        function count = get.count(obj)
            % The total number of variables, design and noise combined
            count = height(obj.designVariables) + height(obj.noiseVariables);
        end

        function names = get.names(obj)
            % The names of all variables, design and noise combined (in that order)
            names = [obj.designVariables; obj.noiseVariables];
        end

        function ranges = get.ranges(obj)
            % The ranges of all variables, design and noise combined (in that order)
            ranges = [obj.designRanges; obj.noiseRanges];
        end

        function count = get.nDesignVars(obj)
            count = length(obj.designVariables);
        end
        
        function count = get.nNoiseVars(obj)
            count = length(obj.noiseVariables);
        end

        function resizeDesignVariables(obj, newSize)
            % Resize the number of design variables. When growing, 
            % new variables are assigned default names and ranges.
            % When shrinking, the last variables are removed.
            obj.resize('design', newSize);
        end

        function setDesignVariables(obj, names)
            arguments
                obj;
                names (:,1) string;
            end
            % Set the names of the design variables.
            % This resizes the number of variables if needed.
            obj.resize('design', height(names));
            obj.designVariables = names;
        end

        function setDesignRanges(obj, ranges)
            % Set the ranges for the design variables.
            % This resizes the number of variables if needed.
            obj.resize('design', height(ranges));
            obj.designRanges = ranges;
        end
        
        function resizeNoiseVariables(obj, newSize)
            % Resize the number of noise variables. When growing, 
            % new variables are assigned default names and ranges.
            % When shrinking, the last variables are removed.
            obj.resize('noise', newSize);
        end

        function setNoiseVariables(obj, names)
            arguments
                obj;
                names (:,1) string;
            end
            % Set the names of the noise variables.
            % This resizes the number of variables if needed.
            obj.resize('noise', height(names));
            obj.noiseVariables = names;
        end

        function setNoiseRanges(obj, ranges)
            % Set the ranges (mean, stddev) for the noise variables.
            % This resizes the number of variables if needed.
            obj.resize('noise', height(ranges));
            obj.noiseRanges = ranges;
        end

        function hasEmptyDesignRanges = hasEmptyDesignRanges(obj)
            % Returns true if any design range is empty
            hasEmptyDesignRanges = any(obj.designRanges(:,1) - obj.designRanges(:,2) == 0);
        end

        function hasEmptyNoiseRanges = hasEmptyNoiseRanges(obj)
            % Returns true if any noise range is empty
            hasEmptyNoiseRanges = any(obj.noiseRanges(:,1) - obj.noiseRanges(:,2) == 0);
        end

        function indices = designIndices(obj)
            % Returns the indices of the design variables in obj.names or obj.ranges
            indices = 1:height(obj.designVariables);
        end

        function indices = noiseIndices(obj)
            % Returns the indices of the noise variables in obj.names or obj.ranges
            indices = height(obj.designVariables)+1:height(obj.names);
        end

        function [isValid, errorMessage] = areValidParameterNames(obj, candidate)
            % Check for duplicate names
            [~, indices] = unique(candidate, 'stable');
            duplicateIndices = setdiff(1:numel(candidate), indices);
            if ~isempty(duplicateIndices)
                isValid = false;
                errorMessage = sprintf("The name '%s' is duplicated", candidate(duplicateIndices(1)));
                return
            end

            % Check if any entry in candidate exceeds the maximum length
            if any(strlength(candidate) > AppConstants.MAX_PARAM_NAME_LENGTH)
                isValid = false;
                errorMessage = sprintf("The entered name is too long (>%d)", AppConstants.MAX_PARAM_NAME_LENGTH);
                return
            end

            % Check if any entry in candidate is empty
            if any(strlength(candidate) < 1)
                isValid = false;
                errorMessage = sprintf("Names cannot be empty");
                return
            end
            isValid = true;
            errorMessage = "";
        end

        function [isValid, errorMessage] = areAllRangesValid(obj)
            [errorRows, messages] = obj.validateDesignVariableRanges(obj.designRanges, obj.designVariables);
            if ~isempty(errorRows)
                isValid = false;
                errorMessage = messages(1); % Only show the first error due to space constraints
                return
            end
            [errorRows, messages] = obj.validateNoiseVariableRanges(obj.noiseRanges, obj.noiseVariables);
            if ~isempty(errorRows)
                isValid = false;
                errorMessage = messages(1); % Only show the first error due to space constraints
                return
            end
            isValid = true;
            errorMessage = "";
        end
    end
       
    methods(Static)
        function states = designVarStates(designRanges)
            % Returns a vector with the state of each design variable range
            % as a string: valid, invalid or incomplete
            
            % A row is incomplete if it has any NaNs
            isIncomplete = any(isnan(designRanges), 2);
            
            % Map the logical to a state string
            options = ["complete", "incomplete"];
            states = options(isIncomplete+1)'; % +1 as matlab is 1-indexed
            
            % For the complete rows, check if the lower bound is greater than the upper bound
            completeRows = find(states == "complete");
            invalidRows = find(designRanges(:, 1) >= designRanges(:, 2));
            states(intersect(completeRows, invalidRows)) = "invalid";
        end

        function states = noiseVarStates(noiseRanges)
            % Returns a vector with the state of each noise variable range
            % as a string: complete, incomplete, or invalid
            
            % A row is incomplete if it has any NaNs
            isIncomplete = any(isnan(noiseRanges), 2);
            
            % Map the logical to a state string
            options = ["complete", "incomplete"];
            states = options(isIncomplete+1)'; % +1 as matlab is 1-indexed

            % For the complete rows, check if the standard deviation is zero or negative
            completeRows = find(states == "complete");
            invalidRows = find(noiseRanges(:, 2) - noiseRanges(:, 1) <= 0);
            states(intersect(completeRows, invalidRows)) = "invalid";
        end

        function valid = areAllDesignVarsValid(designRanges)
            % Returns true if all design variables are valid
            valid = all(designVarStates(designRanges) == "complete");
        end

        function valid = areAllNoiseVarsValid(noiseRanges)
            % Returns true if all noise variables are valid
            valid = all(noiseVarStates(noiseRanges) == "complete");
        end

        function [errorRows, messages] = validateDesignVariableRanges(ranges, varNames)
            % Validate the design variable ranges
            rowStates = ParametersDefinition.designVarStates(ranges);
            errorRows = find(rowStates ~= "complete");
            if isempty(errorRows)
                messages = [];
            else
                if length(errorRows) > 1
                    messages = strings(length(errorRows), 1);
                end
                for i = 1:length(errorRows)
                    if rowStates(errorRows(i)) == "incomplete"
                        messages(i) = varNames(errorRows(i)) + ": Lower or upper bound value is missing";
                    else
                        messages(i) = varNames(errorRows(i)) + ": Lower bound is greater than upper bound";
                    end
                end
            end
        end

        function [errorRows, messages] = validateNoiseVariableRanges(ranges, varNames)
            % Validate the noise variable ranges
            rowStates = ParametersDefinition.noiseVarStates(ranges);
            errorRows = find(rowStates ~= "complete");
            if isempty(errorRows)
                messages = [];
            else
                if length(errorRows) > 1
                    messages = strings(length(errorRows), 1);
                end
                for i = 1:length(errorRows)
                    if rowStates(errorRows(i)) == "incomplete"
                        messages(i) = varNames(errorRows(i)) + ": Mean or standard deviation value is missing";
                    else
                        messages(i) = varNames(errorRows(i)) + ": Standard deviation cannot be zero or negative";
                    end
                end
            end
        end
    end
end


