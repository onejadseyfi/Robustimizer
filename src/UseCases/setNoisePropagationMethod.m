% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function setNoisePropagationMethod(project, method)
    % Set the noise propagation method in the project
    arguments
        project Project
        method NoisePropagationMethod
    end

    project.optSettings.noiPropMthd = method;
    project.optSettings.noiDesOfExp = [];
    project.clearOptimizationResults();
end