% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = createDOE(project, nDOEPoints, opts)
    % Create a design of experiments (DOE) in the project
    %
    % project: Project
    % nDOEPoints: number of points in the DOE
    % opts: options
    %   inclFactorial: include a factorial design
    %   inclMaxMin: including maximization of miniumum distance in making the DOE
    arguments
        project Project
        nDOEPoints (1,1) double {mustBeInteger, mustBePositive}
        opts.inclFactorial (1,1) logical = false
        opts.inclMaxMin (1,1) logical = false
    end

    % To make things more readable below (note that varsDef is a handle)
    vars = project.varsDef;

    % Validate
    errorMessage = string.empty;
    if isempty(vars.designRanges)
        errorMessage = 'Design parameters are not defined in the previous tab';
    elseif isempty(vars.noiseRanges)
        errorMessage = 'Noise parameters are not defined in the previous tab';
    elseif vars.hasEmptyDesignRanges()
        errorMessage = 'Lower bound and upper bound can not be equal. Re-enter the values in the previous tab';
    elseif vars.hasEmptyNoiseRanges()
        errorMessage = 'Standard deviation cannot be zero. Re-enter the values in the previous tab';
    end
    if ~isempty(errorMessage)
        success = false;
        return;
    end

    [success, errorMessage] = project.varsDef.areAllRangesValid();
    if ~success
        errorMessage = "Can't create DOE, invalid ranges in the previous tab:" + newline + errorMessage;
        return;
    end

    normalizedDOE = MakeDOE(vars.count, nDOEPoints, opts.inclFactorial, opts.inclMaxMin);
    DOENormalizedtemp = (normalizedDOE-0.5)*2;
    lowerBnd = vars.designRanges(:,1)';
    upperBnd = vars.designRanges(:,2)';
    DOEdesign = repmat(((lowerBnd+upperBnd)./2),[nDOEPoints,1])+repmat(((upperBnd-lowerBnd)./2),[nDOEPoints,1]).*DOENormalizedtemp(:, vars.designIndices());
    simulResDOEDesign = DOEdesign;
    [DOEnoise, simulResDOENoise] = project.noiseSource.mapNormalizedPoints(normalizedDOE(:,vars.noiseIndices()));

    project.DOE = [DOEdesign DOEnoise];
    project.simulResDOE = [simulResDOEDesign simulResDOENoise];
    vars.setNoiseRanges(project.noiseSource.ranges);

    project.clearOutputValues();
    success = true;
end