% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
% AppConstants
%
% This file contains the (validation) constants used in the application.
% Note that some of these constant values are also specified in the 
% Robustimizer AppDesigner file. Unfortunately, the app designer does not
% support the use of constants, so be aware that if you change a constant
% value here, you should also change it in the app designer file (if it is present there).
%
classdef AppConstants
    properties(Constant)
        MAX_PARAM_NAME_LENGTH = 30;
        MIN_DESIGN_VARIABLES = 1;
        MAX_DESIGN_VARIABLES = 20;
        MIN_NOISE_VARIABLES = 1;
        MAX_NOISE_VARIABLES = 20;
        MIN_CONSTRAINTS = 0;
        MAX_CONSTRAINTS = 5;
        MIN_DOE_SIZE = 4;
        MAX_DOE_SIZE = 1000;
        MIN_MC_SIZE = 10;
        MAX_MC_SIZE = 1000000;
        MIN_IMPROVEMENT_STEPS = 1;
        MAX_IMPROVEMENT_STEPS = 100;
        APPLICATION_NAME = "Robustimizer";
        APPLICATION_VERSION = "2024.1";
        APPLICATION_URL = "https://www.robustimizer.com";
        % Note that you probably need to implement some kind of upgrade mechanism
        % if you change the file format version.
        % The place to do this is in the loadProject() function.
        FILEFORMAT_VERSION = 1;
        FILEFORMAT_MIN_SUPPORTED_VERSION = 1; % Backward compatibility
        FILEFORMAT_MAX_SUPPORTED_VERSION = 1; % Forward compatibility

    end
end

