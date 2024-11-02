% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function resetNoiseDescriptionMethod(project)
    % Reset the noise description method in the project, e.g. when
    % changing back from a file-based noise description to a synthetic
    % noise description based on means and standard deviations.
    arguments
        project Project
    end

    nNoiseVars = height(project.varsDef.noiseVariables);
    project.noiseSource = NoiseDataSource(zeros(nNoiseVars, 1), ones(nNoiseVars, 1));
    project.clearDOE();
end