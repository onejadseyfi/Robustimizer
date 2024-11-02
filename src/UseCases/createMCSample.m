% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = createMCSample(project)
    arguments
        project Project
    end
    success = true;
    errorMessage = '';
    % creating Monte Carlo sample to perform noise propagation 
    nMC = project.optSettings.nMC;
    noiDistr = project.noiseSource.distribution;
    switch project.optSettings.noiPropMthd
        case NoisePropagationMethod.Analytical
            errorMessage = 'Analytical noise propagation method does not require a Monte Carlo sample';
            success = false;
        case NoisePropagationMethod.MonteCarloRandom
            nNoiseVars = height(project.varsDef.noiseVariables);
            project.optSettings.noiDesOfExp = normrnd(ones(nMC,1)*(noiDistr(:,1)'),ones(nMC,1)*(noiDistr(:,2)'),[nMC,nNoiseVars]);
        case NoisePropagationMethod.MonteCarloLatinHypercube
            project.optSettings.noiDesOfExp=lhsnorm(noiDistr(:,1)',diag(noiDistr(:,2)'.^2),nMC);
        otherwise
            % Hard error here, we need to add a new case for the new noise propagation method
            % in the switch statement above
            error("Unsupported noise propagation method selected");
    end
end