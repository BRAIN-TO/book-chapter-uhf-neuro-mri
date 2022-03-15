% Script uhfbold_plot_epi_spiral_sequence
% Plots nominal trajectories for sequence diagram in chapter
%
%  uhfbold_plot_created_trajectories
%
%
%   See also

% Author:   Lars Kasper
% Created:  2022-01-07
% Copyright (C) 2020 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load trajectory from gradients*.txt file and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% For Gradient figure/sequence plot
clear all
idTrajArray = [1001 1002];
idSubject = 'UHFBOLD'; % see uhfbold_create_epi_spiral_trajectories for other options


doSavePlots = true;


%% Loop to create and save all trajectory plots
paths = uhfbold_get_paths(idSubject);

[~,~] = mkdir(paths.figures);
iTraj = 0;
fhArray  = [];
dataArray = {};

for idTraj = idTrajArray
    iTraj = iTraj + 1;
    [k, gradobj] = read_k(idTraj, paths.export);
    % take only 1st interleaf
    if ndims(k) > 2
        k = k(:,1,:);
    end
    dt = gradobj.gs.GRADIENT_DWELL;
    
    % set max gradient display, if var available
    if exist('maxGArray', 'var')
        gmax = maxGArray(idTraj);
        smax = maxSrArray(idTraj);
    else
        gmax = 50e-3;
        smax = 250;
    end
    
    [fh ,hs, data] = plot_k(k, 'dt', dt, 'gmax', gmax, 'smax', smax);
    set(fh, 'Name', sprintf('Traj %04d', idTraj));
    fhArray(iTraj) = fh;
    dataArray{iTraj} = data;
    if doSavePlots
        save_plot_publication(fh, paths.figures, [1]);
        %  save_plot_publication(fh, paths.figures, [2]);
        pause(1);
        close(fh);
    end
    
    %% Compute maximum spectral bandwidth that object spans while max gradients
    % are active (i.e., sum of abs of all gradients
    
    FOV = max(gradobj.gwi.fov);
    gamma1H_kHz = gradobj.gs.GAMMA_1H/1e3;
    maxSumAbsGradient = max(sum(abs(data.g),2));
    maxObjectBandwidth_kHz = maxSumAbsGradient*FOV*gamma1H_kHz;
    maxDwellTime_mus = 1e3/maxObjectBandwidth_kHz;
    acqDuration_ms = size(k,1)*dt*1000;
    fprintf(['\n\nThe maximum object bandwidth during trajectory %d is: %3.0f kHz\n' ...
        '\tnecessitating an ADC dwell time of less than     : %2.1f mus\n' ...
        '\tTrajectory Duration :%5.1f ms\n\n'], ...
        idTraj, maxObjectBandwidth_kHz, maxDwellTime_mus, acqDuration_ms);
    acqDuration_msArray(idTraj) = acqDuration_ms;
    
end

%% Recreate new figure with sequence elements;

labelArray = {'EPI', 'Spiral'}

fhArray2 = [];
lineWidth = 4;
for iTraj = 1:numel(dataArray)
    data  = dataArray{iTraj};
    
    % Trajectory 2D plot
    stringTitle = sprintf('%s Trajectory 2D', labelArray{iTraj});
    fh = figure('Name', stringTitle);
    hp = plot(data.k(:,1), data.k(:,2), 'LineWidth', lineWidth, 'Color', [0 0 0]);
    axis square
    axis tight
    axis off
    
    fhArray2(3*(iTraj-1)+1) = fh;
    
    % Gx plot
    stringTitle = sprintf('%s Gradient X', labelArray{iTraj});
    fh = figure('Name', stringTitle);
    hp = plot(data.time, data.g(:,1), 'LineWidth', lineWidth, 'Color', [0 0 0]);
    axis tight
    axis off
    
    fhArray2(3*(iTraj-1)+2) = fh;
    
       % Gx plot
    stringTitle = sprintf('%s Gradient Y', labelArray{iTraj});
    fh = figure('Name', stringTitle);
    hp = plot(data.time, data.g(:,2), 'LineWidth', lineWidth, 'Color', [0 0 0]);
    axis tight
    axis off
    
    fhArray2(3*(iTraj-1)+3) = fh;
  
end

%% Save additional plots
if doSavePlots
    save_plot_publication(fhArray2, paths.figures, [1]);
end