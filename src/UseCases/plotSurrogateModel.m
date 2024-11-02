% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function plotSurrogateModel(plt, prj, selectedXVar, selectedYVar, selectedResponse, varValues)
    % Plots the surrogate model for the selected response on the selected X and Y axis variables
    %
    % plt               The plot to use (UIAxes)
    % prj               The project to use
    % selectedXVar      The selected X axis variable (index)
    % selectedYVar      The selected Y axis variable (index)
    % selectedResponse  The selected response (index)
    % varValues         The current values of (all) the variables
    arguments
        plt (1,1) matlab.ui.control.UIAxes
        prj (1,1) Project
        selectedXVar (1,1) {mustBeInteger, mustBePositive}
        selectedYVar (1,1) {mustBeInteger, mustBePositive}
        selectedResponse (1,1) {mustBeInteger, mustBePositive}
        varValues (:,1) double
    end

    varRanges = prj.varsDef.ranges;
    varNames  = prj.varsDef.names;
    outputVal = prj.outputVal;

    plt.XLim = varRanges(selectedXVar,:);
    plt.YLim = varRanges(selectedYVar,:);
    Range = ceil(max(outputVal(:,selectedResponse))) - floor(min(outputVal(:,selectedResponse)));
    plt.ZLim = [floor(min(outputVal(:,selectedResponse))) - (0.1*Range), ...
                 ceil(max(outputVal(:,selectedResponse))) + (0.1*Range)];
    plt.XLabel.String = varNames(selectedXVar);
    plt.YLabel.String = varNames(selectedYVar);

    dmodel = prj.srgModel(1,selectedResponse).dmodel;
    [x1, x2, yplot] = surrogatePlotData(varRanges, varValues, selectedXVar, selectedYVar, dmodel);
    surf(plt, x1, x2, yplot)
end

function [x1, x2, yplot] = surrogatePlotData(varRanges, varValues, selectedX, selectedY, dmodel)
    % Returns the data needed for a surrogate model (surface) plot
    %
    % varRanges     The (design and noise) variable ranges
    % varValues     The current values of the variables
    % selectedX     The selected X axis variable
    % selectedY     The selected Y axis variable
    % dmodel        The DACE model to use

    nVars = length(varRanges);
    indices = 1:nVars;
    indices([selectedX, selectedY]) = [];
    point2eval(indices) = varValues(indices);
    
    n_boxes = 30;
    x1 = 0:(1/n_boxes):1;
    x2 = 0:(1/n_boxes):1;

    normalisation = [varRanges(:,1), varRanges(:,2) - varRanges(:,1)]';
    x1 = x1*normalisation(2,selectedX) + normalisation(1,selectedX);
    x2 = x2*normalisation(2,selectedY) + normalisation(1,selectedY);
    [x1,x2] = meshgrid(x1,x2);

    point2eval = repmat(point2eval, (n_boxes+1)^2, 1);
    point2eval(:,selectedX) = reshape(x1, (n_boxes+1)^2, 1);
    point2eval(:,selectedY) = reshape(x2, (n_boxes+1)^2, 1);
    yplot = predictor(point2eval, dmodel);
    yplot = reshape(yplot, (n_boxes+1), (n_boxes+1));
    x1 = 0:(1/n_boxes):1;
    x2 = 0:(1/n_boxes):1;
    x1 = x1*normalisation(2,selectedX) + normalisation(1,selectedX);
    x2 = x2*normalisation(2,selectedY) + normalisation(1,selectedY);
end
