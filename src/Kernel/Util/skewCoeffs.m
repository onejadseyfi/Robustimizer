% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [L,U]=skewCoeffs(nSigSkewObj,uncerState,response)

Coeff=[1.31,-1.06,1.29,-3;0.29,-0.85,1.55,3;4.05,-3.94,4.08,-6;2.31,-5.08,5.64,6];
switch nSigSkewObj
   case 1 %1Sigma reliability level
        if uncerState.gamma(response).g>0
            U=Coeff(2,1)*(uncerState.gamma(response).g)^3+Coeff(2,2)*(uncerState.gamma(response).g)^2+Coeff(2,3)*(uncerState.gamma(response).g)+Coeff(2,4);
            L=Coeff(1,1)*(uncerState.gamma(response).g)^3+Coeff(1,2)*(uncerState.gamma(response).g)^2+Coeff(1,3)*(uncerState.gamma(response).g)+Coeff(1,4);
        else
            U=-(Coeff(1,1)*(uncerState.gamma(response).g)^3+Coeff(1,2)*(uncerState.gamma(response).g)^2+Coeff(1,3)*(uncerState.gamma(response).g)+Coeff(1,4));
            L=-(Coeff(2,1)*(uncerState.gamma(response).g)^3+Coeff(2,2)*(uncerState.gamma(response).g)^2+Coeff(2,3)*(uncerState.gamma(response).g)+Coeff(2,4));
        end
   case 3 %3Sigma reliability level
        if uncerState.gamma(response).g>0
            U=Coeff(2,1)*(uncerState.gamma(response).g)^3+Coeff(2,2)*(uncerState.gamma(response).g)^2+Coeff(2,3)*(uncerState.gamma(response).g)+Coeff(2,4);
            L=Coeff(1,1)*(uncerState.gamma(response).g)^3+Coeff(1,2)*(uncerState.gamma(response).g)^2+Coeff(1,3)*(uncerState.gamma(response).g)+Coeff(1,4);
        else
            U=-(Coeff(1,1)*(uncerState.gamma(response).g)^3+Coeff(1,2)*(uncerState.gamma(response).g)^2+Coeff(1,3)*(uncerState.gamma(response).g)+Coeff(1,4));
            L=-(Coeff(2,1)*(uncerState.gamma(response).g)^3+Coeff(2,2)*(uncerState.gamma(response).g)^2+Coeff(2,3)*(uncerState.gamma(response).g)+Coeff(2,4));
        end
   case 6 %6Sigma reliability level
        if uncerState.gamma(response).g>0
            U=Coeff(4,1)*(uncerState.gamma(response).g)^3+Coeff(4,2)*(uncerState.gamma(response).g)^2+Coeff(4,3)*(uncerState.gamma(response).g)+Coeff(4,4);
            L=Coeff(3,1)*(uncerState.gamma(response).g)^3+Coeff(3,2)*(uncerState.gamma(response).g)^2+Coeff(3,3)*(uncerState.gamma(response).g)+Coeff(3,4);
        else
            U=-(Coeff(3,1)*(uncerState.gamma(response).g)^3+Coeff(3,2)*(uncerState.gamma(response).g)^2+Coeff(3,3)*(uncerState.gamma(response).g)+Coeff(3,4));
            L=-(Coeff(4,1)*(uncerState.gamma(response).g)^3+Coeff(4,2)*(uncerState.gamma(response).g)^2+Coeff(4,3)*(uncerState.gamma(response).g)+Coeff(4,4));
        end
end