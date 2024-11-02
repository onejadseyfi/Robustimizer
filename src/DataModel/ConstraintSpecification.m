% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef ConstraintSpecification < handle
    %CONSTRAINTSPECIFICATION Specification of a constraint for the optimization problem
    %   This class is used to define a constraint for the optimization problem.
    %   The constraint can be an upper bound, a lower bound, or an equality.
    %
    %   The constraint is defined as a function of the mean and standard deviation
    %   of a variable, plus an optional value. The constraint can also include
    %   the skewness of the variable.
    %
    %   The constraint is used to generate the formula for the optimization problem.
    properties
        type (1,1) ConstraintType = ConstraintType.UpperBound
        sigmaLevel (1,1) double = 1
        value (1,1) double = 0
        includeSkewness (1,1) logical = false
    end

    properties(Dependent)
        uiExpression string
        namePrefix string
    end

    methods
        function obj = ConstraintSpecification(type, sigmaLevel)
            arguments
                type (1,1) ConstraintType = ConstraintType.UpperBound;
                sigmaLevel (1,1) double = +3;
            end
            obj.type = type;
            obj.sigmaLevel = sigmaLevel;
        end

        function f = formula(obj, constraintIndex)
            if obj.type == ConstraintType.LowerBound
                factor = "-1";
            else
                factor = "+1";
            end
            level = sprintf("%+d", obj.sigmaLevel);
            if ~obj.includeSkewness
                template = "{factor}*(mu({index}).mu{level}*sigma({index}).sigma-{value})";    
            else
                if obj.sigmaLevel > 0
                    level = "+U";
                else
                    level = "+L";
                end
                template = "{factor}*(mu({index}).mu{level}*sigma({index}).sigma-{value})";
            end
            f = replace(template, ...
                ["{factor}" "{index}" "{level}" "{value}"], ...
                [factor 1+constraintIndex level num2str(obj.value)]); %constraint index starts from 1, however there is also always an objective therefore +1
        end

        function prefix = get.namePrefix(obj)
            switch obj.type
                case ConstraintType.Equality
                    prefix = "h";
                otherwise
                    prefix = "g";
            end
        end

        function expression = get.uiExpression(obj)
            switch obj.type
                case ConstraintType.UpperBound
                    op = "<";
                case ConstraintType.LowerBound
                    op = ">";
                case ConstraintType.Equality
                    op = "=";
                otherwise
                    error("Unsupported constraint type: %s", obj.type);
            end
            level = sprintf("%+d", obj.sigmaLevel);
            template = "Mean{level}Sigma{op}value";
            expression = replace(template, ["{level}" "{op}"], [level, op]);
        end
    end
end
