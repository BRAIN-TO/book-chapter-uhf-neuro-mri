% Script spidi_plot_nominal_trajectories
% Plots nominal trajectories created by gradient creation
%
%  spidi_plot_nominal_trajectories
%
%
%   See also

% Author:   Lars Kasper
% Created:  2020-11-14
% Copyright (C) 2020 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load trajectory from gradients*.txt file and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doSavePlot = true;
idTrajArray = idArray([iEpiTrajArray([[2:5:end] [3:5:end]]) iSpiralTrajArray([[2:5:end] [3:5:end]]) ])%37:192;

paths = uhfbold_get_paths();

[~,~] = mkdir(paths.figures);
for idTraj = idTrajArray
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
    
    [fh,hs, data] = plot_k(k, 'dt', dt, 'gmax', gmax, 'smax', smax);
    set(fh, 'Name', sprintf('Traj %04d', idTraj));
    if doSavePlot
        save_plot_publication(fh, paths.figures, [1]);
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