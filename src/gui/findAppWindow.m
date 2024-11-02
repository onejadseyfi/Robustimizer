% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [appWindow] = findAppWindow()
    % Find the 'uifigure' handle of the currently running app
    appWindow = gcbf;
    if isempty(appWindow)
        % Fallback to the last figure that had focus
        h = findall(groot, 'Type', 'figure');
        if ~isempty(h)
            % The first entry is the one that had focus before
            appWindow = h(1);
        end
    end       
end
    