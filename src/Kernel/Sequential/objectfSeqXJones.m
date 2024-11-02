% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [F]= objectfSeqXJones(designInput,Inp,OptCnd,srgModel,FirstEval,Fmin,omega,uncerState)

% This function returns the objective function value for a given model and
% point to automatically evaluate the infill point using Jones criteria od
% maximum expected improvement

% Input: 

% Inp             structure containing the input required for optimization
% omega           weighting factor to balance exploration (global search) and exploitation (Local search)
% optCnd          structure containing the settings of optimziation
% designInput     the design DOE point
% srgtModel       surrogate model structure
% FirstEval       parameter accounting for the repeating of the evaluation to avoid repetitive calculations

% OutPut: 
% F               objective value

% Assign function input
Obj=Inp.Obj;
skewObjIncl=Inp.skewObjIncl;
nSigSkewObj=Inp.nSigSkewObj;
stochMthd=OptCnd.stochMthd;
noiDesOfExp=OptCnd.noiDesOfExp;
uncerState.Flag=0;

switch stochMthd
    case {1,2} % Monte Carlo Analysis (1.Random or 2.LHS)
        for position = 1:1 %Location response in MMID
            if skewObjIncl==1
                [mu_x,sigma_x,skew_x,s_hat] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                uncerState.mu(position).mu=mu_x;
                uncerState.sigma(position).sigma=sigma_x;
                uncerState.skew(position).skew=skew_x;
                uncerState.gamma(position).g=(0.99527*(skew_x))/(sqrt(1+(skew_x)^2));
                uncerState.s_hat(position).s_hat=s_hat;
            else
                [mu_x,sigma_x,~,s_hat] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                uncerState.mu(position).mu=mu_x;
                uncerState.sigma(position).sigma=sigma_x;
                uncerState.s_hat(position).s_hat=s_hat;
            end
        end
        
    case 3 % Analytical
        for position = 1:1  %Only on Objective function
            if skewObjIncl==1
                [Noisestruct,y_anal,std_anal,~,~,s_hat,Skewness]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                uncerState.mu(position).mu=y_anal;
                uncerState.sigma(position).sigma=std_anal;
                uncerState.gamma(position).g=(0.99527*(Skewness))/(sqrt(1+(Skewness)^2));
                uncerState.s_hat(position).s_hat=s_hat;
                uncerState.Noisestruct=Noisestruct;
            elseif skewObjIncl==0
                [Noisestruct,y_anal,std_anal,~,~,s_hat]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                uncerState.mu(position).mu=y_anal;
                uncerState.sigma(position).sigma=std_anal;
                uncerState.s_hat(position).s_hat=s_hat;
                uncerState.Noisestruct=Noisestruct;
            end
        end
        uncerState.Flag=1;
end
if skewObjIncl==1  %For the case of zero skewness both following equat.gobject.gammaion can be used. they lead to identical results
    response=1;
    [L,U]=skewCoeffs(nSigSkewObj,uncerState,response);
end   

% Objective function value
mu=uncerState.mu; %The following values assigned are used in Eval
sigma=uncerState.sigma;
gamma=uncerState.gamma;
Noisestruct=uncerState.Noisestruct;
Flag=uncerState.Flag;
s_hat=uncerState.s_hat;
F_hat=eval(Obj);
S_hat=s_hat(1).s_hat;
if isreal(S_hat)==0
    S_hat=0;
    warning ('S_hat was complex due to singularity of R, s_hat set to zero')
end
phi = normpdf((Fmin - F_hat)./S_hat,0,1);     % Standard Normal probability density function
Phi = normcdf((Fmin - F_hat)./S_hat,0,1);     % Standard Normal cumulative distribution function
F=-1*(omega*(Fmin - F_hat).*Phi+(1-omega)*S_hat.*phi);  %To minimize F
end