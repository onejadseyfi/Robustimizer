% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [F]= objectfX(designInput,Inp,optCnd,srgModel,FirstEval,uncerState)

% This function returns the objective function value for a given model and point

% Input: 

% Inp             structure containing the input required for optimization
% optCnd          structure containing the settings of optimziation
% designInput     the design DOE point
% srgtModel       surrogate model structure
% FirstEval       parameter accounting for the repeating of the evaluation to avoid repetitive calculations

% OutPut: 
% F               objective value

outID=Inp.outID;
Obj=Inp.Obj;
skewObjIncl=Inp.skewObjIncl;
skewConIncl=Inp.skewConIncl;
skewObjCon=[skewObjIncl,skewConIncl];
nSigSkewObj=Inp.nSigSkewObj;
stochMthd=optCnd.stochMthd;
noiDesOfExp=optCnd.noiDesOfExp;

    % "mu" and "sigma" are calculated in objectf.m
    % Calculate mean (mu) and st. deviation (sigma) for each response (y1,y2)
    % at point in design space x
   
    if isempty(uncerState.Flag)==1
        uncerState.Flag=0;
    end
    switch stochMthd
        case {1,2} % Monte Carlo Analysis (1.Random or 2.LHS)
            for position = 1:size(outID,2)
                if skewObjCon(position)==1
                    [mu_x,sigma_x,skew_x,~] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                    uncerState.mu(position).mu=mu_x;
                    uncerState.sigma(position).sigma=sigma_x;
                    uncerState.skew_x(position).skew=skew_x;
                    uncerState.gamma(position).g=(0.99527*(skew_x))/(sqrt(1+(skew_x)^2));
                    %s_hat(position).s_hat=s_hat
                elseif skewObjCon(position)==0
                    [mu_x,sigma_x] = MCanalysisX(designInput,srgModel,noiDesOfExp,position); % mean and standard deviation response
                    uncerState.mu(position).mu=mu_x;
                    uncerState.sigma(position).sigma=sigma_x;
                end
            end

        case 3 % Analytical evaluation
            for position = 1:size(outID,2)
                if skewObjCon(position)==1
                    [Noisestruct,y_analytic,stdev_analytic,~,~,~,skewness]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                    uncerState.mu(position).mu=y_analytic;
                    uncerState.sigma(position).sigma=stdev_analytic;
                    uncerState.gamma(position).g=(0.99527*(skewness))/(sqrt(1+(skewness)^2));
                    uncerState.Noisestruct=Noisestruct;
                elseif skewObjCon(position)==0
                    [Noisestruct,y_analytic,stdev_analytic]=AnalyticalKrigX(designInput,Inp,srgModel,position,FirstEval,uncerState.Noisestruct,uncerState.Flag);
                    uncerState.mu(position).mu=y_analytic;
                    uncerState.sigma(position).sigma=stdev_analytic;
                    uncerState.Noisestruct=Noisestruct;
                end
            end
            uncerState.Flag=1;
            FirstEval=0;
    end

    if skewObjIncl==1  %For the case of zero skewness both following equat.gobject.gammaion can be used. they lead to identical results
        response=1;
        [L,U]=skewCoeffs(nSigSkewObj,uncerState,response);
    end  

    % Objective function value
    mu=uncerState.mu;
    sigma=uncerState.sigma;
    gamma=uncerState.gamma;
    Noisestruct=uncerState.Noisestruct;
    Flag=uncerState.Flag;
    s_hat=uncerState.s_hat;
    F = eval(Obj); %L and U are inside Obj and will be used
end
