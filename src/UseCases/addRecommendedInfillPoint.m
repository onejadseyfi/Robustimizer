% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = addRecommendedInfillPoint(project)    
    arguments
        project Project
    end

    success = project.addLastRecommendedInfillPoint();
    if ~success
        errorMessage = 'DOE point has been already added, Continue to DOE and Blackbox Evaluation tab';
    else
        errorMessage = '';
    end
end