% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [status, output] = runSubprocess(cmd, opt)
    % runSubprocess Run a subprocess with arguments and options
    %   This function is a wrapper around the Java ProcessBuilder class. It
    %   runs a subprocess with the given command and options, and returns the output
    %   and status of the subprocess. 
    %
    %   Inputs:
    %       cmd: A string array containing the command and arguments to run
    %
    %   Options:
    %       env: A struct containing environment variables to set for the subprocess
    %       cwd: The working directory for the subprocess
    %       timeout: The maximum time to wait for the subprocess to finish. If the
    %                subprocess does not finish within this time, it is killed.
    %       poll_interval: The interval at which to poll the subprocess for output (in seconds)
    %       on_output: A function handle that is called with the output of the subprocess
    %                  as it is generated
    %       cancel_requested: A function handle that is called to check if the subprocess
    %                         should be cancelled
    %
    %   Outputs:
    %       status: The status (exit code) of the subprocess
    %       output: The output of the subprocess. Standard output and standard
    %               error are combined.
    %
    %   Errors:
    %       runSubprocess:timeout: The execution time of the subprocess 
    %                              exceeded the timeout
    %       runSubprocess:cancelled: The subprocess was cancelled by the user
    %                                via the cancel_requested function
    %
    %   Example:
    %       [status, output] = RUNSUBPROCESS(["ls" "-l"]);
    %
    %   See also: JAVA.LANG.PROCESSBUILDER, JAVA.LANG.PROCESS
    arguments
        cmd (1,:) string
        opt.env struct {mustBeScalarOrEmpty} = struct.empty
        opt.cwd string {mustBeScalarOrEmpty} = string.empty
        opt.timeout double {mustBeScalarOrEmpty} = double.empty
        opt.poll_interval double {mustBeScalarOrEmpty} = 0.1
        opt.on_output function_handle {mustBeScalarOrEmpty} = function_handle.empty
        opt.cancel_requested function_handle {mustBeScalarOrEmpty} = function_handle.empty
    end

    proc = java.lang.ProcessBuilder("").redirectErrorStream(true);

    if ~isempty(opt.env)
        env = proc.environment();
        keys = fieldnames(opt.env);
        for key = keys
            env.put(key, opt.env.(key));
        end
    end

    if ~isempty(opt.cwd)
        if ~isfolder(opt.cwd)
            error("runSubprocess:invalid_cwd", "The specified working directory does not exist: %s", opt.cwd);
        end
        proc.directory(java.io.File(opt.cwd));
    end

    proc.command(cmd);
    h = proc.start();
    startTime = datetime('now');
    stream = h.getInputStream();
    scanner = java.util.Scanner(stream);
    output = "";   
    while(h.isAlive())
        [lines, didRead] = read_from_scanner(scanner, stream);
        if (didRead)
            output = output + lines;
            if ~isempty(opt.on_output)
                opt.on_output(lines);
            end
        else
            pause(opt.poll_interval);
        end
        now = datetime('now');
        if ~isempty(opt.timeout) && (now - startTime) > seconds(opt.timeout)
            h.destroy();
            error("runSubprocess:timeout", "Subprocess timed out after %d seconds", opt.timeout);
        end
        if ~isempty(opt.cancel_requested) && opt.cancel_requested()
            disp("cancelling subprocess");
            h.destroy();
            error("runSubprocess:cancelled", "Subprocess was cancelled")
        end
    end
    
    status = h.waitFor();
    scanner.close();
    h.destroy();
end

function [msg, didRead] = read_from_scanner(scanner, stream)
    msg = "";
    didRead = false;
    % Check if there is data available to read. This is not a 100% foolproof method
    % to prevent blocking, but it generally works and improves responsiveness when
    % canceling the subprocess was requested by the user and the subprocess has little
    % output.
    if stream.available() <= 0
        return;
    end
    if (scanner.hasNextLine())
        line = scanner.nextLine();
        if (~isempty(line))
            %disp(line);
            msg = append(msg, string(line));
            didRead = true;
        end
    end
end
