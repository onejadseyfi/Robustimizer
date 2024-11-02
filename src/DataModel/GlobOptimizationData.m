% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
classdef GlobOptimizationData < handle
    %This class is used to keep track of the variables that are not passed
    %by fmincon optimization function in matlab since fmincon only accepts
    %one scalar output as a function
    
    properties
        mu struct =[];
        sigma struct =[];
        gamma struct =[];
        Noisestruct struct =[];
        skew_x struct =[];
        Flag double =[];
        s_hat struct =[];
    end
    
    methods
        function funcVal = FuncObj(uncerState,designInput,Inp,optCnd,srgModel,FirstEval)
            funcVal = objectfX(designInput,Inp,optCnd,srgModel,FirstEval,uncerState);
        end
        function [constrVal,constrValEq] = FuncConstr(uncerState,designInput,Inp,optCnd,srgModel,FirstEval)
            [constrVal,constrValEq] = nonlinconX(designInput,Inp,optCnd,srgModel,FirstEval,uncerState);
        end
        function SeqJonesVal = FuncSeqJones(uncerState,designInput,Inp,OptCnd,srgModel,FirstEval,Fmin,omega)
            SeqJonesVal = objectfSeqXJones(designInput,Inp,OptCnd,srgModel,FirstEval,Fmin,omega,uncerState);
        end
        function SeqMaxSVal = FuncSeqMaxS(uncerState,designInput,Inp,optCnd,srgModel,FirstEval)
            SeqMaxSVal = objectfSeqXMaxS(designInput,Inp,optCnd,srgModel,FirstEval,uncerState);
        end
        function clearVariables(uncerState)
            uncerState.mu=[];
            uncerState.sigma=[];
            uncerState.gamma=[];
            uncerState.Noisestruct=[];
            uncerState.skew_x=[];
            uncerState.Flag=[];
            uncerState.s_hat=[];
        end
    end
end

