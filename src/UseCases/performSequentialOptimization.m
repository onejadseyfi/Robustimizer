% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [success, errorMessage] = performSequentialOptimization(project, nSeq, omega,  opts)
    arguments
        project Project
        nSeq double
        omega double
        opts.reportInfillPoint function_handle {mustBeScalarOrEmpty} = function_handle.empty
        opts.reportOptimization function_handle {mustBeScalarOrEmpty} = function_handle.empty
        opts.updateTitle function_handle {mustBeScalarOrEmpty} = function_handle.empty
        opts.cancel_requested function_handle {mustBeScalarOrEmpty} = function_handle.empty
    end
    
    executable = project.scriptFileName;
    % This option only works when an script is present from Making DOE tab
    if ~isfile(executable)
        errorMessage = "Script file is not selected under DOE and blackbox evaluation tab, only manual infill strategy is possible";
        success = false;
        return
    end

    if nSeq < 1
        errorMessage = "Number of sequential optimizations must be at least 1";
        success = false;
        return
    end

    % Save the original input and output files as they will be overwritten
    filenameIn      = inSameDirAs(executable, 'in.txt');
    filenameInOrig  = inSameDirAs(executable, 'inOriginal.txt');
    filenameOut     = inSameDirAs(executable, 'out.txt');
    filenameOutOrig = inSameDirAs(executable, 'outOriginal.txt');
    copyfile(filenameIn, filenameInOrig);
    copyfile(filenameOut, filenameOutOrig);

    project.seqOptProgress.total = nSeq;
    for n=1:nSeq
        project.seqOptProgress.current = n;
        if ~isempty(opts.cancel_requested) && opts.cancel_requested()
            errorMessage = "Operation cancelled by user";
            success = false;
            return
        end

        if ~isempty(opts.updateTitle)
            opts.updateTitle("Sequential optimization: " + n + "/" + nSeq);
        end

        % Get recommendation & report it
        rec = recommendInfillPoint(project, project.globX, omega);
        text = generateRecommendationReport(project, rec);
        project.seqRecommendationTexts = [project.seqRecommendationTexts; text];
        if ~isempty(opts.reportInfillPoint)
            opts.reportInfillPoint(text);
        end
        
        % Add recommendation to the DOE
        project.addLastRecommendedInfillPoint();

        % Save just the recommended infill point
        saveAsTabSeparated(filenameIn, [rec.addedDes,rec.addedNoi]);

        % Run the selected script to get the outputs for the infill
        % point
        [success, err] = runSelectedScript(project.scriptFileName, ...
            'on_output', @disp, ...
            'cancel_requested', opts.cancel_requested);
        if ~success
            errorMessage = "Something went wrong:\n" + err;
            return;
        end

        % Wait until the file is really there (prevent potential
        % race condition)
        success = waitUntilFileExists(filenameOut, 3, 0.5);
        if ~success
            errorMessage = "no output file was generated!";
            return
        end

        % Load the results and append them
        [loadedResults, success, errorMessage] = loadTabSeparated(filenameOut);
        if ~success || isempty(loadedResults)
            success = false;
            errorMessage = "Failed to load results:\n" + errorMessage;
            return
        else
            project.outputVal = [project.outputVal; loadedResults];
        end
        
        % Refit 
        [success, errorMessage] = fitSurrogateModel(project);
        if ~success
            return
        end
        
        % Perform the robust optimization again
        % It would be better to call performRobustOptimization(project) here, but
        % we propbably need to refactor the code to avoid global variables before
        % we can do that.
        [Inp, optCnd] = collectRobOptInputs(project);
        startTime=tic;
        [project.globX, project.globF] = RobustOpt(optCnd, Inp);
        elapsedTime=toc(startTime);

        text = generateOptimizationReport(project, elapsedTime);
        project.seqOptResultTexts = [project.seqOptResultTexts; text];
        if ~isempty(opts.reportOptimization)
            opts.reportOptimization(text);
        end

        % Save extra information
        saveAsTabSeparated(inSameDirAs(executable, 'inSequentiallyUpdated.txt'), project.simulResDOE);
        saveAsTabSeparated(inSameDirAs(executable, 'outSequentiallyUpdated.txt'), project.outputVal);
        saveAsTabSeparated(inSameDirAs(executable, 'OutputSeqObj.txt'), [project.globX, project.globF]);
    end
end

function text = generateRecommendationReport(project, rec)
    text = sprintf(strcat('Current DOE size: %d \nRecommended infill point: \n', ...
        repmat('%8.4f ',[1,project.varsDef.count]), ...
        '\nMaximum expected improvement value:\n%f\nElapsed Time (s):\n%8.4f\n-----------------------\n'), ...
        project.nDOEPoints, ...
        [rec.mappedDes, rec.mappedNoi], ...
        rec.maxEI, ...
        rec.elapsedTime);
end

function text = generateOptimizationReport(project, elapsedTime)
    text = sprintf(strcat('Current DOE size: %d \nOptimum design: \n',repmat('%8.4f ',[1,project.varsDef.nDesignVars]),'\nObjective function value on optimum:\n%8.4f\nElapsed Time (s):\n%8.4f\n--------------------------------------\n'), ...
                   project.nDOEPoints, project.globX, project.globF, elapsedTime);
end