% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage, globX, globF, elapsedTime] = performRobustOptimization(project)
    % Perform robust optimization
    %
    % project: Project
    arguments
        project Project
    end

    globX = [];
    globF = [];
    elapsedTime = 0;
    project.clearOptimizationResults();

    % Validate inputs
    if isempty(project.srgModel)
        errorMessage = 'Surrogate model is not fitted, please fit a surrogate model first.';
        project.lastOptimizationError = errorMessage;
        success = false;
        return;
    end

    checkSampleSize = true;
    if project.optSettings.noiPropMthd == NoisePropagationMethod.Analytical
        project.optSettings.noiDesOfExp = [];
        checkSampleSize = false;
    end

    if checkSampleSize && size(project.optSettings.noiDesOfExp,1) == 0
        errorMessage = 'MC sample does not exist, First creat a sample in the previous tab';
        project.lastOptimizationError = errorMessage;
        success = false;
        return
    end

    [Inp, optCnd] = collectRobOptInputs(project);

    startTime = tic;
    [globX, globF, globOpData] = RobustOpt(optCnd, Inp);
    elapsedTime = toc(startTime);
    project.globX = globX;
    project.globF = globF;
    project.elapsedTime = elapsedTime;
    project.globOpData = globOpData;

    success = ~isempty(globX);
    if ~success
        project.lastOptimizationError = "Optimization failed";
    end
    errorMessage = project.lastOptimizationError;
end

