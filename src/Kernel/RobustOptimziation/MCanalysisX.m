% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [mu,sigma,skew,s_hat] = MCanalysisX(designInput,srgtModel,DOEn,position)

% This function propagates the noise via surrogate model and returns the
% characteristics of output distribution using Monte carlo analysis

% Input: 
% designInput   the design DOE point
% srgtModel     surrogate model structure
% DOEn          noise DOE
% position      the position in which the surrogate model is evaluated

% OutPut: 
% mu            mean of the output
% sigma         standard deviation of the output
% skew          skewness of the output
% s_hat         uncertainty of the model

%Propagate the noise
DOEmc=[ones(size(DOEn,1),1)*designInput , DOEn ];
fSurrogatemodel = srgtModel(position);  % Select the surrogate smodel
[Y,s2_hat_Xopt] = predictor(DOEmc,fSurrogatemodel.dmodel);

% Evaluate the moments
mu=mean(Y);
sigma=std(Y);
if nargout>2
    skew=skewness(Y);
    s_hat=sqrt(mean(s2_hat_Xopt));
end
