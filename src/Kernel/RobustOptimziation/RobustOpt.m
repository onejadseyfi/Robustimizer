% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [xGlob,fGlob,GlobOpData]=RobustOpt(optCnd,Inp)

% This function performs robust optimization based on given settings and
% outputs the optimum design value and objective function value at the
% optimum

% Input: 
% Inp        structure containing the input required for optimization
% optCnd     structure containing the settings of optimziation

% OutPut: 
% xGlob      Global optimum design
% fGlob      Global objective function value

GlobOpData=GlobOptimizationData();

outputVal=Inp.outputVal;
DOE=Inp.DOE;
srgModel=Inp.srgModel;
nDesVar=Inp.nDesVar;
noiDistr=Inp.noiDistr;
desRng=Inp.desRng;
DOEopt=DOE(:,1:nDesVar);
gExplicit=Inp.gExplicit;
hExplicit=Inp.hExplicit;
lowerBnd = desRng(:,1); 
upperBnd = desRng(:,2); 
optMthd=optCnd.optMthd;

[A,B,Aeq,Beq] = lincon(gExplicit,hExplicit,nDesVar); % Construct linear explicit constraints

message = waitbar(0,'Please wait, optimization in progress');
firstEval=1;

clear glbstruct.Flag glbstruct.Noisestruct

for counter1 = 1 : length(DOEopt(:,1)) 
    X0 = DOEopt(counter1,:); 
    waitbar(counter1/(length(DOEopt(:,1))),message);
    if optMthd == OptimizationMethod.InteriorPoint
        OPTIONS = optimoptions(@fmincon,'MaxFunEvals',5000,'MaxIterations',5000,'Algorithm','interior-point','TolCon', 1e-12,'TolFun',1e-12,'TolX',1e-12);
    elseif optMthd == OptimizationMethod.SQP
        OPTIONS = optimset('MaxFunEvals',5000,'Algorithm','SQP','TolCon', 1e-12,'TolFun',1e-12,'TolX',1e-12);
    else
        error("Unknown optimization method");
    end
    OPTIONS.Display = 'off';
    warning off

    if size(outputVal,2)==1
        [X,fVal,exitflag,output,lambda] = fmincon(@(designInput)GlobOpData.FuncObj(designInput,Inp,optCnd,srgModel,firstEval),X0,A,B,Aeq,Beq,lowerBnd,upperBnd,[],OPTIONS);
        firstEval=0;
    else    
        [X,fVal,exitflag,output,lambda] = fmincon(@(designInput)GlobOpData.FuncObj(designInput,Inp,optCnd,srgModel,firstEval),X0,A,B,Aeq,Beq,lowerBnd,upperBnd,@(designInput)GlobOpData.FuncConstr(designInput,Inp,optCnd,srgModel,firstEval),OPTIONS);
        firstEval=0;
    end
    
%     if size(outputVal,2)==1
%         firstEval=0;
%         contrFun=[];
%     else    
%         firstEval=0;
%         contrFun=@(designInput)GlobOpData.FuncConstr(designInput,Inp,optCnd,srgModel,firstEval);
%     end
%         objFun=@(designInput)GlobOpData.FuncObj(designInput,Inp,optCnd,srgModel,firstEval);
%         [X,fVal,exitflag,output,lambda] = fmincon(objFun,X0,A,B,Aeq,Beq,lowerBnd,upperBnd,contrFun,OPTIONS);
        
    warning off % Turn warning system on again for future warnings

    eFlag(counter1,1) = exitflag;
    xOpt(counter1,:) = X;
    fOpt(counter1,1) = fVal;
end

close(message);

[xGlob,fGlob] = chkSortMultistart(eFlag,xOpt,fOpt,desRng,nDesVar);