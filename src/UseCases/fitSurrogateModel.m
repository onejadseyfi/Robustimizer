% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = fitSurrogateModel(project)
    arguments
        project Project
    end

    errorMessage = "";
    if size(project.DOE,1) ~= size(project.outputVal,1) || ...
        size(project.outputVal,2) ~= project.nOutputs || ...
        size(project.DOE,2) ~= project.varsDef.count
        errorMessage = "Surrogate model can not be fitted, please check the input";
        success = false;
    else
        [project.srgModel] = fitGP(project.DOE, ...
                                    project.varsDef.count, ...
                                    project.outputVal);
        success = (~isempty(project.srgModel));
        if ~success
            errorMessage = "Surrogate model could not be fitted";
        end

        project.clearCrossValidationResults();
        project.clearOptimizationResults();
    end
end