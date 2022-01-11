function paths = uhfbold_get_paths()
% Define all paths for code related to UHF Neuro BOLD Acq/Phys book chapter
%
%   paths = uhfbold_get_paths()
%
% IN
%
% OUT
%   paths   structured variable, includeds project/data/results/code paths
% EXAMPLE
%   uhfbold_get_paths
%
%   See also

% Author:   Lars Kasper
% Created:  2022-01-10
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.
%

idSubject = 'UHFBOLD'; 'SYNAPTIVE'; %'UHFBOLD'

paths.project = 'C:\Users\kasperla\UHN\Brain-TO - BookChapterUltraHighFieldNeuroMRI - BookChapterUltraHighFieldNeuroMRI';
paths.data = fullfile(paths.project, 'data');
paths.results = fullfile(paths.project, 'results');
paths.figures = fullfile(paths.results, 'figures');
paths.code.root = fullfile(paths.project, 'code');
paths.code.analysis = fullfile(paths.code.root, 'book-chapter-uhf-neuro-mri');
paths.code.utils = 'C:\Users\kasperla\Documents\Code\BRAIN-To\matlab-utils';
paths.code.spm = 'C:\Users\kasperla\Documents\Code\spm12';
paths.code.uniqc = 'C:\Users\kasperla\Documents\Code\uniqc-code';
paths.code.traj_generation = 'C:\Users\kasperla\Documents\Code\Recon\utils\nominalTrajectory';
paths.code.recon = 'C:\Users\kasperla\Documents\Code\Recon';

paths.export = fullfile(paths.data, idSubject);
% put all gradient files in single folder for easier access

paths.export_single_folder = fullfile(paths.export, 'exportGradientsSiemens');
