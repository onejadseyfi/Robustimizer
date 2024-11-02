% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [rec] = recommendInfillPoint(project, globX, omega)
    arguments
        project (1,1) Project
        globX double
        omega (1,1) double = 0.5; % Weightinh factor for exploraration versus exploitation
        
    end

    [Inp, optCnd] = collectRobOptInputs(project);

    %   clear global mu sigma gamma Noisestruct Flag % "mu" and "sigma" are calculated in objectf.m
    project.globOpData.clearVariables();

    FirstEval=1;
    FonDOE = zeros(1, project.nDOEPoints);
    for counter = 1:project.nDOEPoints
        desInputTemp = project.DOE(counter,project.varsDef.designIndices());
        FonDOE(counter) = objectfX(desInputTemp, Inp, optCnd, project.srgModel, FirstEval, project.globOpData);
    end
    fMin = min(FonDOE);

    StartTime = tic;
    rec = InfillPointRecommendation();
    [rec.addedDes, rec.addedNoi, rec.maxEI] = explorExploit(Inp, optCnd, fMin, omega, globX, project.globOpData);
    rec.elapsedTime = toc(StartTime);
    rec.mappedDes = rec.addedDes;
    rec.mappedNoi = project.noiseSource.mapInternalToUser(rec.addedNoi);
    
    % Store the recommendation for later use in manual infill and optimization
    project.lastRecommendation = rec;
end
