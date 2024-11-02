% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [C,Ceq] = nonlinconX(designInput,Inp,OptCnd,srgtModel,FirstEval,uncerState)  %Keep the unused variables since they are passed to the ObjectiveX

% This function returns the nonlinear constraints to be used in fmincon function based on the 
% given model and point

% Input: 

% Inp             structure containing the input required for optimization
% optCnd          structure containing the settings of optimziation
% designInput     the design DOE point
% srgtModel       surrogate model structure
% FirstEval       parameter accounting for the repeating of the evaluation to avoid repetitive calculations
% Passnoise_distr the noise distribution

% OutPut: 
% C and Ceq       Constraints for fmincon

mu=uncerState.mu; %(mu sigma gamma are used in eval func)
sigma=uncerState.sigma;
gamma=uncerState.gamma;
Noisestruct=uncerState.Noisestruct;
Flag=uncerState.Flag;

nDesVar=Inp.nDesVar;
Con=Inp.Con;
skewConIncl=Inp.skewConIncl;
nSigSkewCon=Inp.nSigSkewCon;
gExplicit=Inp.gExplicit;
hExplicit=Inp.hExplicit;

% Some settings

conName=[];
for i=1:length(Con)
    conName=[conName ; Con(i).name];
end
g = strmatch('g',conName); % Positions of the implicit inequality constraints
h = strmatch('h',conName); % Positions of the implicit equality constraints

% Inequality constraints

% Explicit constraints
if isempty(gExplicit) == 0 % Explicit inequality constraints
    for j = 1 : length(gExplicit(:,1)) 
        [~,Loc] = find(gExplicit(j,:)); 
        if max(Loc) > (1 + nDesVar) % This is a nonlinear constraint
            EC(j,1) = 1;
        else
            EC(j,1) = 0;
        end
    end
    gExplicit = gExplicit(logical(EC),:);
    if isempty(gExplicit) == 0 % There are nonlinear explicit constraints
        CExpl = RSmodel(designInput,gExplicit',nDesVar);
    else
        CExpl = [];
    end
else
    CExpl = [];
end

% Implicit constraints
if isempty(g) == 0 % Implicit inequality constraints 
    for mm = 1 : length(g) % for each constraint
        if skewConIncl(g(mm))==1  %For the case of zero skewness both following equation can be used. they lead to identical results
            response=1+mm; % 1 objective is always adds to the response
            [L,U]=skewCoeffs(nSigSkewCon(mm),uncerState,response);
        end
        CImpl(mm,1)=eval(Con(g(mm)).con);
    end
else
    CImpl = [];
end
%fprintf('g= %4.2f\n',Ci);
% Add them together
C = [CExpl;CImpl];

clear CExpl CImpl j mm EC

% Equality constraints

% Explicit constraints
if isempty(hExplicit) == 0 
    for j = 1 : length(hExplicit(:,1)) 
        [~,Loc] = find(hExplicit(j,:)); 
        if max(Loc) > (1 + nDesVar) 
            EC(j,1) = 1;
        else
            EC(j,1) = 0;
        end
    end
    hExplicit = hExplicit(logical(EC),:);
    if isempty(hExplicit) == 0 
        CExpl = RSmodel(designInput,hExplicit',nDesVar);
    else
        CExpl = [];
    end
else
    CExpl = [];
end

% Implicit constraints
if isempty(h) == 0 
    for mm = 1 : length(h)
        if skewConIncl(h(mm))==1  %For the case of zero skewness both following equation can be used. they lead to identical results
            response=1+length(g)+mm;  % 1 objective + numner of inequality constraints + mm
            [L,U]=skewCoeffs(nSigSkewCon(length(g)+mm),uncerState,response);
        end
        CImpl(mm,1)=eval(Con(h(mm)).con); %U and L are used in the evaluation of constraints (mu sigma gamma are used in eval func)
    end
else
    CImpl = [];
end
    Ceq = [CExpl;CImpl];
end