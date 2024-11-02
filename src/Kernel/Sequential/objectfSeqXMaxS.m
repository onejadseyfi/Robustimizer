% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [F]= objectfSeqXMaxS(designInput,Inp,OptCnd,srgModel,FirstEval,uncerState)

% This function returns the objective function value for a given model and
% point to automatically evaluate the infill point at the location of
% maximum uncertainty of the objective function value

% Input:

% Inp             structure containing the input required for optimization
% optCnd          structure containing the settings of optimziation
% designInput     the design DOE point
% srgtModel       surrogate model structure
% FirstEval       parameter accounting for the repeating of the evaluation to avoid repetitive calculations

% OutPut: 
% F               objective value

% Assign function input
skewObjIncl=Inp.skewObjIncl;
stochMthd=OptCnd.stochMthd;
noiDesOfExp=OptCnd.noiDesOfExp;

% global mu sigma gamma s_hat Flag Noisestruct
% Calculate mean (mu) and st. deviation (sigma) for each response (y1,y2)
% at point in control space x
uncerState.Flag=0;
switch stochMthd
    case {1,2} % Monte Carlo Analysis (1.Random or 2.LHS)
        for position = 1:1 %Location response in MMID
            if skewObjIncl==1
                [mu_x,sigma_x,skew_x,s_hat] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                uncerState.mu(position).mu=mu_x;
                uncerState.sigma(position).sigma=sigma_x;
                uncerState.skew(position).skew=skew_x;
                uncerState.gamma(position).gamma=(0.99527*(skew_x))/(sqrt(1+(skew_x)^2));
                uncerState.s_hat(position)=s_hat;
            else
                [mu_x,sigma_x,~,s_hat] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                uncerState.mu(position).mu=mu_x;
                uncerState.sigma(position).sigma=sigma_x;
                uncerState.s_hat(position)=s_hat;
            end
        end
        
    case 3 % Analytical
        for position = 1:1  %Only on Objective function
            if skewObjIncl==1
                [Noisestruct,y_anal,std_anal,~,~,s_hatAnalytic,Skewness]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                uncerState.mu(position).mu=y_anal;
                uncerState.sigma(position).sigma=std_anal;
                uncerState.gamma(position).gamma=(0.99527*(Skewness))/(sqrt(1+(Skewness)^2));
                uncerState.s_hat(position)=s_hatAnalytic;
                uncerState.Noisestruct=Noisestruct;
            elseif skewObjIncl==0
                [Noisestruct,y_anal,std_anal,~,~,s_hatAnalytic]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                uncerState.mu(position).mu=y_anal;
                uncerState.sigma(position).sigma=std_anal;
                uncerState.s_hat(position)=s_hatAnalytic;
                uncerState.Noisestruct=Noisestruct;
            end
        end
        uncerState.Flag=1;
end

if skewObjIncl==1  %For the case of zero skewness both following equat.gobject.gammaion can be used. they lead to identical results
    response=1;
    [L,U]=skewCoeffs(nSigSkewObj,uncerState,response);
end

mu=uncerState.mu;
sigma=uncerState.sigma;
gamma=uncerState.gamma;
Noisestruct=uncerState.Noisestruct;
Flag=uncerState.Flag;
s_hat=uncerState.s_hat(1).s_hat;
F=-s_hat;  %To minimize S_hat
end