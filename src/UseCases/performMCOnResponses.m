% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function performMCOnResponses(project, sampleSize, srgModelNum)
    arguments
        project Project
        sampleSize = 1000;
        srgModelNum = 5;
    end

    % Store the sample size in the project for future reference
    project.optSettings.nMC = sampleSize;

    globX = project.globX;
    nResponses = project.nOutputs;
    noiseDistributions = project.noiseSource.distribution;
    sampleSize = project.optSettings.nMC;
    [project.DOEforMC, project.resMC] = calculateMC(sampleSize, globX, nResponses, noiseDistributions, project.srgModel, srgModelNum);

end

function [DOEforMC, result] = calculateMC(sampleSize, globX, nResponses, noiseDistributions, srgModel, srgModelNum)
    arguments
        sampleSize double
        globX double
        nResponses double
        noiseDistributions double
        srgModel
        srgModelNum double
    end

    %Settings for performing Monte Carlo on the optimum response value
    FinalMCsize = sampleSize; %Size of MC sampling
    nNoiseVars = height(noiseDistributions);
    noiseMean = noiseDistributions(:,1);
    noiseStdDev = noiseDistributions(:,2);

    % DOE in noise according their normal distribution
    DOEforMC = normrnd( ...
        ones(FinalMCsize,1) * (noiseMean'), ...
        ones(FinalMCsize,1) * (noiseStdDev'), ...
        [FinalMCsize, nNoiseVars]);

    result = [];
    for i = 1:nResponses
        %DOE for Monte Carlo analysis
        DOEmc = [ones(FinalMCsize,1)*globX , DOEforMC ]; 

        % Predict response in every point of DOEmc
        switch srgModelNum
            case{5}
                Y = predictor(DOEmc, srgModel(i).dmodel);
            case{8}    
                %Future development
        end
        result(i).YY = zeros(length(DOEmc(:,1)),1);
        result(i).YY = Y;
    end
end