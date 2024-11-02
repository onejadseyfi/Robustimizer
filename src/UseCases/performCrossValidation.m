% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = performCrossValidation(project, opt)
    % Perform cross validation
    %
    % project: Project
    % opt: Options
    arguments
        project Project
        opt.progress_dlg matlab.ui.dialog.ProgressDialog {mustBeScalarOrEmpty} = matlab.ui.dialog.ProgressDialog.empty;
    end

    % Check if the surrogate model is fitted
    if isempty(project.srgModel)
        errorMessage = 'Surrogate model is not fitted';
        success = false;
        return;
    end

    % Perform cross validation
    [project.crossValidationResults] = crossValidate(project.DOE, ...
                                                             project.outputVal, ...
                                                             project.srgModel, ... 
                                                            'progress_dlg', opt.progress_dlg);
    if isempty(project.crossValidationResults)
        errorMessage = 'Cross validation could not be performed';
        success = false;
        return;
    else
        errorMessage = '';
        success = true;
    end
end