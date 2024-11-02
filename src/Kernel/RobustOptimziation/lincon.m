% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [A,B,Aeq,Beq] = lincon(Gexpl,Hexpl,nDesVars)

% This function returns the linear constraints to be used in fmincon function based on the 
% given model and point

% Input: 

% nDesVars         design variables
% Gexpl           explicit inequality constraint
% Hexpl           explicit equality constraint

% OutPut: 
% A,B,Aeq,Beq     explicit constraints for fmincon

% Explicit inequality constraints
if isempty(Gexpl) ~= 1 
    for j = 1 : length(Gexpl(:,1))
        [~,Loc] = find(Gexpl(j,:)); 
        if max(Loc) <= (1 + nDesVars) 
            EIC(j,1) = 1;
        else
            EIC(j,1) = 0;
        end
    end
    Gexpl = Gexpl(logical(EIC),:);
    A = Gexpl(:,2:(nDesVars+1));
    B = -1*Gexpl(:,1);
else
    A = [];
    B = [];
end


% Explicit equality constraints
if isempty(Hexpl) ~= 1 
    for j = 1 : length(Hexpl(:,1)) 
        [~,Loc] = find(Hexpl(j,:));
        if max(Loc) <= (1 + nDesVars) 
            EEC(j,1) = 1;
        else
            EEC(j,1) = 0;
        end
    end
    Hexpl = Hexpl(logical(EEC),:) ;
    Aeq = Hexpl(:,2:(nDesVars+1));
    Beq = -1*Hexpl(:,1);
else
    Aeq = [];
    Beq = [];
end

