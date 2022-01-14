% Script uhfbold_plot_acq_duration_epi_spiral
% plots acquisition time dependence on trajectory, gradient system and
% undersampling for different resolutions
%
%  uhfbold_plot_acq_duration_epi_spiral
%
%
%   See also

% Author:   Lars Kasper
% Created:  2022-01-10
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION_FIRST_SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
doSavePlots = true;


idSubject = 'SYNAPTIVE';
paths = uhfbold_get_paths(idSubject);

%from:
%save('acqDurationEPISpiral_msArray', 'acqDuration_msArray', 'maxGArray', 'maxSrArray', 'rPArray', 'dxMArray', 'iEpiTrajArray', 'iSpiralTrajArray', 'GmaxArray', 'SRmaxArray', 'resArray')

load(fullfile(paths.results, 'acqDurationEPISpiral_msArray.mat'));

if ~exist('GmaxArray', 'var')
    GmaxArray = [40 80 100 200]*1e-3;
    SRmaxArray = [200 200 1200 600];
end

set(0, 'DefaultFigureWindowStyle', 'docked')

for idGradSystem = 1:5
    Gmax = GmaxArray(idGradSystem);
    SRmax = SRmaxArray(idGradSystem);
    
    %% plot for EPIs
    idxArrayTraj = iEpiTrajArray;
    x = 1000*unique(dxMArray(idxArrayTraj));
    
    for R = 1:4
        idxArray = intersect(find(rPArray(:)==R & maxGArray(:)==Gmax & maxSrArray(:)==SRmax), idxArrayTraj);
        y(:,R) = acqDuration_msArray(idxArray);
        stringLegend{R} = sprintf('EPI R = %d', R);
    end
    
    y = y(end:-1:1,:); % highest resolution first
    
    % set up figure
    fh = figure;
    set(fh, 'DefaultAxesFontsize', 16);
    hp = plot(x,y);
    set(hp, 'LineWidth', 2);
    ylim([0 200]);
    xlabel('Resolution (mm)');
    ylabel('Readout duration (ms)');
    grid on
    
    %% Spiral
    
    idxArrayTraj = iSpiralTrajArray;
    x2 = 1000*unique(dxMArray(idxArrayTraj));
    
    for R = 1:4
        idxArray = intersect(find(rPArray(:)==R & maxGArray(:)==Gmax & maxSrArray(:)==SRmax), idxArrayTraj);
        y2(:,R) = acqDuration_msArray(idxArray); % highest resolution first
        stringLegend{R+4} = sprintf('Spiral R = %d', R);
    end
    y2 = y2(end:-1:1,:); % highest resolution first
    
    hold on;
    hp2 = plot(x,y2);
    set(hp2, 'LineWidth', 2, 'LineStyle', '--');
    for R = 1:4
        hp2(R).Color = hp(R).Color;
    end
    legend(stringLegend);
    stringTitle = sprintf('G_{max} = %2.0f mT/m, SR_{max} = %4.0f mT/m/ms', Gmax*1000, SRmax);
    title(stringTitle)
    set(fh, 'Name', ['Readout Durations Gradient ' stringTitle]);
    fhArray(idGradSystem) = fh;
end

%% save 
if doSavePlots
    save_plot_publication(fhArray, paths.figures, [1]);
end