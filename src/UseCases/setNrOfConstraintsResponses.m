% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = setNrOfConstraintsResponses(project, count)
    % Set the number of constraints responses (excluding the main response) in the project
    arguments
        project Project
        count (1,1) double
    end

    if count < AppConstants.MIN_CONSTRAINTS
        errorMessage = "The number of constraints responses cannot be less than " + AppConstants.MIN_CONSTRAINTS;
        success = false;
        return
    end
    if count > AppConstants.MAX_CONSTRAINTS
        errorMessage = "The number of constraints responses cannot exceed " + AppConstants.MAX_CONSTRAINTS;
        success = false;
        return
    end

    errorMessage = "";
    success = true;    
    
    currentCount = length(project.constraintSpec);
    delta = count - currentCount;
    if delta > 0
        % Add the new constraints
        for i = 1:delta
            project.constraintSpec(end+1) = ConstraintSpecification();
        end
    elseif delta < 0
        % Remove the last constraints
        project.constraintSpec = project.constraintSpec(1:count);
    end

    % Add one for the main response
    project.nOutputs = count + 1;

    % Clear the output values, as they are no longer valid
    project.clearOutputValues();
end
