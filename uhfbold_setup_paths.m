function paths = uhfbold_setup_paths(idSubject)
% sets up paths for book chapter analysis/visualization
%
%  paths = uhfbold_setup_paths
%
% IN
%
% OUT
%
% EXAMPLE
%   uhfbold_setup_paths
%
%   See also uhfbold_get_paths
 
% Author:   Lars Kasper
% Created:  2022-01-10
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.
%

if nargin < 1
    idSubject = 'UHFBOLD';
end
    

paths = uhfbold_get_paths(idSubject);
addpath(genpath(paths.code.utils));
addpath(genpath(paths.code.export_fig));
addpath(genpath(paths.code.uniqc));
addpath(paths.code.spm);
addpath(genpath(paths.code.analysis));

% add paths for traj creation
addpath(genpath(paths.code.traj_generation));
addpath(genpath(paths.code.traj_utils));