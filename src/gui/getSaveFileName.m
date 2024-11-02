% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [file, path] = getSaveFileName(filter, title, defaultPath)
    % Ask the user for a file name to save (to).
    %
    % Simple wrapper around uiputfile that ensures the dialog is shown on top of the app window.
    % This is a workaround for a long standing issue in MATLAB where the dialog may appear behind the app window:
    % https://nl.mathworks.com/matlabcentral/answers/296305-appdesigner-window-ends-up-in-background-after-uigetfile
    arguments
        filter string 
        title string = ''
        defaultPath string = ''
    end
    [appWindow] = findAppWindow();
    [file, path] = uiputfile(filter, title, defaultPath);
    drawnow;
    figure(appWindow);
end
