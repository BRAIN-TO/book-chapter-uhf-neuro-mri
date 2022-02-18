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

fhArray = [];

%% Plot EPI spiral durations for different gradient systems
for idGradSystem = [] %1:5
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

%% Plot Summary EPI/Spiral R=1 &4 for all gradient systems
gradSystemPlotArray = [2 4 5];%[1 2 4 5];
RPlotArray = [1 4];
trajPlotArray = [1 2];
trajPlotNames = {'EPI', 'Spiral'}
gradSystemNames = {'Standard Whole Body Gradient', ...
    'Performance Whole Body Gradient', 'Commercial (Synaptive) Head Gradient', ...
    'Performance Head Gradient (serial mode)', ...
    'Performance Head Gradient (parallel mode)'
    };


colorArray = [
    0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    ];

lineStyleArray = {
    '-'
    '--'
    };

markerArray = {
    'none'
    'd'
    '+'
    'x'
    'o'
    };


iPlot = 0;
% set up figure
fh = figure;
set(fh, 'DefaultAxesFontsize', 16);
for idGradSystem = gradSystemPlotArray
    for R = RPlotArray
        for idTraj = trajPlotArray
            
            
            iPlot = iPlot+1;
            
            Gmax = GmaxArray(idGradSystem);
            SRmax = SRmaxArray(idGradSystem);
            
            switch idTraj
                case 1
                    idxArrayTraj = iEpiTrajArray;
                case 2
                    idxArrayTraj = iSpiralTrajArray;
            end
            
            x(:,iPlot) = 1000*unique(dxMArray(idxArrayTraj));
            
            
            idxArray = intersect(find(rPArray(:)==R & maxGArray(:)==Gmax & maxSrArray(:)==SRmax), idxArrayTraj);
            y(:,iPlot) = fliplr(acqDuration_msArray(idxArray)); % highest resolution first
            stringLegend{iPlot} = sprintf('%s R = %d (G_{max} = %3.0f mT/m, SR_{max} = %4.0f T/m/s)', ...
                trajPlotNames{idTraj}, R, ...
                1000*Gmax, SRmax);
%             stringLegend{iPlot} = sprintf('%s R = %d (%s, G_{max} = %3.0f mT/m, SR_{max} = %4.0f T/m/s)', ...
%                 trajPlotNames{idTraj}, R, gradSystemNames{idGradSystem}, ...
%                 1000*Gmax, SRmax);
%             
            hp(iPlot) = plot(x(:,iPlot),y(:,iPlot));
            hp(iPlot).Marker = markerArray{R};
            hp(iPlot).MarkerSize = 12;
            hp(iPlot).Color = colorArray(idGradSystem,:);
            hp(iPlot).LineStyle = lineStyleArray{idTraj};
            
            hold on;
        end
    end
end
set(hp, 'LineWidth', 2);
ylim([0 200]);
xlabel('Resolution (mm)');
ylabel('Readout duration (ms)');
grid on
legend(stringLegend);
stringTitle = sprintf('EPI/Spiral fully/undersampled on different gradient systems');
title(stringTitle)
set(fh, 'Name', ['Readout Durations ' stringTitle]);
fhArray(end+1) = fh;

%% save Plots
if doSavePlots
    save_plot_publication(fhArray, paths.figures, [1]);
end