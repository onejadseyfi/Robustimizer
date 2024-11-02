% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function stochMthd = stochasticMethodNrFor(noiPropMthd)
    % Function to convert the noise propagation method to the corresponding
    % stochastic method number.
    arguments
        noiPropMthd (1,1) NoisePropagationMethod
    end
    switch noiPropMthd
        case NoisePropagationMethod.Analytical
            stochMthd = 3;
        case NoisePropagationMethod.MonteCarloRandom
            stochMthd = 1;
        case NoisePropagationMethod.MonteCarloLatinHypercube
            stochMthd = 2;
        otherwise
            error("Unsupported noise propagation method selected");
    end
end
