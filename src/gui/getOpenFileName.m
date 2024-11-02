% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [file, path] = getOpenFileName(filter, title, defaultPath)
    % Ask the user for a file name to open.
    %
    % Simple wrapper around uigetfile that ensures the dialog is shown on top of the app window.
    % This is a workaround for a long standing issue in MATLAB where the dialog may appear behind the app window:
    % https://nl.mathworks.com/matlabcentral/answers/296305-appdesigner-window-ends-up-in-background-after-uigetfile
    arguments
        filter string 
        title string = ''
        defaultPath string = ''
    end
    [appWindow] = findAppWindow();
    [file, path] = uigetfile(filter, title, defaultPath);
    drawnow;
    figure(appWindow);
end
