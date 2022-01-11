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
 
paths = uhfbold_get_paths();

%save('acqDurationEPISpiral_msArray', ...
% 'acqDuration_msArray', 'maxGArray', 'maxSrArray', 'rPArray', 'dxMArray', 'iEpiTrajArray', 'iSpiralTrajArray')

load(fulllfile(paths.results, 'acqDurationEPISpiral_msArray.mat'));

% plot for EPIs
idxArray = iEpiTrajArray;
x = unique(dxMArray(idxArray));

for R = 1:4
    y(:,R) =
    plot(x,y)
end