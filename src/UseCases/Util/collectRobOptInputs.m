% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [Inp, optCnd] = collectRobOptInputs(project)
    % Construct the input and condition structures for robust optimization from the project
    %
    % project: Project
    arguments
        project Project
    end

    Inp.nDesVar = height(project.varsDef.designVariables);
    Inp.nNoiVar = height(project.varsDef.noiseVariables);
    Inp.DOE = project.DOE;
    Inp.outputVal = project.outputVal;
    Inp.outID = project.outputNames;
    [Inp.Con, Inp.skewConIncl, Inp.nSigSkewCon] = convertConstraintSpecs(project.constraintSpec);
    [Inp.Obj, Inp.nSigSkewObj] = project.optSettings.objectiveFuncSpec.formula();
    Inp.skewObjIncl = project.optSettings.objectiveFuncSpec.includeSkewness;
    Inp.srgModel = project.srgModel;
    Inp.varsRng = project.varsDef.ranges;
    Inp.noiDistr = project.noiseSource.distribution;
    Inp.desVars = project.varsDef.names;
    Inp.desRng = project.varsDef.designRanges;
    Inp.noiRng = project.varsDef.noiseRanges;
    %Inp.srgModelNum = app.srgModelNum; % Appears to be unused at the
    %moment? correct, this is for future development

    % Put all settings in one setting structure
    optCnd.noiDesOfExp = project.optSettings.noiDesOfExp;
    optCnd.noiPropMthd = project.optSettings.noiPropMthd;
    optCnd.optMthd = project.optSettings.optMthd.algorithmName();
    optCnd.seqMthdNum = seqMethodNrFor(project.infillMethod);
    optCnd.nMC = project.optSettings.nMC;
    optCnd.stochMthd = stochasticMethodNrFor(project.optSettings.noiPropMthd);
    
    % explicit equality constraints for future developments, currently empty
    if exist('gExplicit')==0
        Inp.gExplicit=[];
    else
        Inp.gExplicit=1; %Future development
    end
    if exist('hExplicit')==0
        Inp.hExplicit=[];
    else
        Inp.hExplicit=1; %Future development
    end
end