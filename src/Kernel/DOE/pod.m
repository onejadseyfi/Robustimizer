% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [podbasis,Apod,lambda,Vpod] = pod(U)
neig = size(U,2);
podbasis = zeros(size(U,1),neig);

if size(U,1) < size(U,2)  % Thesis (O.nejadseyfi)
    C = U*U';
    [Vpod,lambda] = eig(C);
    podbasis = fliplr(Vpod);
else                        % Thesis (De Gooier)
    D = (U')*U;
    [Vpod,lambda] = eig(D);
    for n = 1:neig
        podbasis(:,n) = real(U*Vpod(:,end-n+1)*(lambda(end-n+1,end-n+1)^(-0.5)));
    end
end
Apod = (podbasis')*U; %amplitudes in POD-basis
lambda = flip(diag(lambda))';

N = rank(podbasis);
if N < size(podbasis,2)
    podbasis = podbasis(:,1:N);
    Apod = Apod(1:N,:);
    lambda = lambda(1:N);
else
end
% At the end we have between 0 and 1 (then we multiply in sigma (std to
% make unitless) and sum with mean)