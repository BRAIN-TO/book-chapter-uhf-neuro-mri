% Script main_create_trajs
% Creates spiral & cartesian (FFE, EPI, multi-echo) trajectories from index file
%
% See also create_figure_trajectory_gradients
%
% Author: Lars Kasper
% Created: 2020-02-13

% exploring the following:
% resolution (cartesian): 3 2 1 0.75 0.5 0.25(?) mm
% trajetories: EPI, 2D Spiral
% gradient system: standard, high end clinical, 
% insert gradient (Weiger et al., 2018, MRM)
%   serial mode (higher voltage, higher SR)
%   parallel mode (higher current, higher Gmax)

% NOTE: adjust in main_create_smooth_readgrad_FFE
% HACK for strong max gradients to avoid freq undersampling limitation of
% gradient
%dknyquist_x = 2*pi/args.FOV(1);
%args.sc.dwell_acq = dknyquist_x/(args.sc.gamma_1H*args.maxG);

idSubject = 'SYNAPTIVE'; % 'SYNAPTIVE'; %'UHFBOLD';
vendor = 'SIEMENS'; % 'SIEMENS', 'PHILIPS' for gradient dwell;
iEpiTrajArray = [3];
iSpiralTrajArray = [4];

doUseGradientFile = false; % if false, take array population from arrays below

RArray = [1 2 3 4];

switch idSubject
    case 'UHFBOLD'
        resArray = [3 2 1 0.75 0.5 0.25]*1e-3;
        GmaxArray = [40 80 100 200]*1e-3;
        SRmaxArray = [200 200 1200 600];
    case 'SYNAPTIVE'
        resArray = [3 2.5 2 1.5 1 0.75 0.5 0.25]*1e-3;
        GmaxArray = [40 80 100 100 200]*1e-3;
        SRmaxArray = [200 200 400 1200 600];
end

paths = uhfbold_setup_paths(idSubject);

% where to write down the gradient files for easy access later on
[~,~] = mkdir(paths.export_single_folder);

if doUseGradientFile    
    fileNameIndex = fullfile(paths.code.analysis, ...
        sprintf('index_gradient_files_%s.m', idSubject));
    
    % Leave out dxSArray(t) & fovSArray for 2D trajectories OR set to zero.
    [idArray, fovMArray, fovPArray, fovSArray, dxMArray, dxPArray, dxSArray,...
        rPArray, rSArray, nIlArray, maxGArray, maxSrArray, tAcqArray, trajDirArray, ...
        trajTypeArray, scheme3DArray, nPlanesPerShotArray] = ...
        read_index_gradient_files(fileNameIndex);
else
    nGradSystems = numel(GmaxArray);
    [trajTypeGrid, idGradSystemGrid, RGrid, resGrid] = ndgrid(1:2, 1:nGradSystems, RArray, resArray);
    nTrajs = numel(resGrid);
    
    iEpiTrajArray = 1:2:nTrajs;
    iSpiralTrajArray = 2:2:nTrajs;

    FOV = 220e-3;
    
    fovMArray(1:nTrajs) = FOV;
    fovPArray(1:nTrajs) = FOV;
    fovSArray(1:nTrajs) = 0;
    % for spirals, adjust resolution by sqrt(pi/4)
    dxMArray(iEpiTrajArray) = resGrid(iEpiTrajArray);
    dxPArray(iEpiTrajArray) = resGrid(iEpiTrajArray);
    dxMArray(iSpiralTrajArray) = resGrid(iSpiralTrajArray)*sqrt(pi/4);
    dxPArray(iSpiralTrajArray) = resGrid(iSpiralTrajArray)*sqrt(pi/4);
    dxSArray(1:nTrajs) = 0;
    rPArray(1:nTrajs) = RGrid(:);
    rSArray(1:nTrajs) = 1;
    scheme3DArray(1:nTrajs) = {'stack'};
    nPlanesPerShotArray(1:nTrajs) = 1;
    nIlArray(1:nTrajs) = 1;
    idArray = 1:nTrajs;
    trajTypeArray(iEpiTrajArray) = {'EPI'};
    trajTypeArray(iSpiralTrajArray) = {'minTime'};
    maxGArray = GmaxArray(idGradSystemGrid);
    maxSrArray = SRmaxArray(idGradSystemGrid);
    tAcqArray(1:nTrajs) = 0;
    trajDirArray(iEpiTrajArray) = {'0'}; % is nExtraEchoes for EPI
    trajDirArray(iSpiralTrajArray) = {'out'}; % is spiral direction in/out for spiral
end


switch upper(vendor)
    case 'SIEMENS'
        dtGradient = 10e-6;
    case 'PHILIPS'
        dtGradient = 6.4e-6;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Spirals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for t = []%iSpiralTrajArray
    id = idArray(t);
    create_matched_filter_spiral(...
        'dtGradient', dtGradient, ...
        'FOV', [fovMArray(t) fovPArray(t) fovSArray(t)], ...
        'dx', [dxMArray(t) dxPArray(t) dxSArray(t)], ... % leave out dxSArray(t) for 2D trajectories
        'Rp', rPArray(t), ...
        'Rz', rSArray(t), ...
        'scheme3D', scheme3DArray{t}, ...
        'nPlanesPerShot', nPlanesPerShotArray(t), ...
        'nInterleaves', nIlArray(t), ...
        'verbose', 0, ...
        'idSubject', idSubject, ...
        'idGradientFolder', idArray(t), ...
        'trajectoryType', trajTypeArray{t}, ...
        'allowGaussBelowGmin', 0, ...
        'maxG', maxGArray(t), 'maxSlewRate', maxSrArray(t), ...
        'tAcqMax', tAcqArray(t), ...
        'directionSpiral', trajDirArray{t}, ...
        'doFullSampling', false, ...
        'doDetermineParametersFromIdGradientFolder', false, ...
        'pathCode', paths.code.traj_generation, ...
        'pathData', paths.data, ...
        'interleafOrder', 'R1', ...
        'isBinary',0,...
        'nZeroFillEnd',0);
    % copy created gradient some to easily shareable location
    fileGradientIn = fullfile(paths.export, num2str(id), 'gradients.txt');
    fileGradientOut = fullfile(paths.export_single_folder, sprintf('gradients%d.txt',id));
    copyfile(fileGradientIn, fileGradientOut);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Cartesians (EPI/FFE, ME)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nExtraEchoes = trajDirArray;

% Why echo-shift as input parameter? Echo shift is not the right name, has
% a specific meaning for EPI, rather: delta_TE


for t = iEpiTrajArray(91:end)

    % echo-spacing different for different scans...
    switch idArray(t)
        case {999}
        otherwise
            delta_TE = 0;
    end
    main_create_smooth_readgrad_FFE(...
        'dtGradient', dtGradient, ...
        'mp_switch', false, ...
        'subj', idSubject, ...
        'id', idArray(t), ...
        'traj_type', trajTypeArray{t}, ...
        'resolution', [dxMArray(t) dxPArray(t) dxSArray(t)], ...
        'Rp', rPArray(t), ...
        'Rz', rSArray(t), ...
        'FOV', [fovMArray(t) fovPArray(t) fovSArray(t)], ...
        'nPlanesPerShot', nPlanesPerShotArray(t), ...
        'maxG', maxGArray(t), 'maxSlewRate', maxSrArray(t), ...
        'interleaves', nIlArray(t), ...
        'vis_verbose', 0, ...
        'savedir', paths.data, ...
        'n_zerofill_samples', 0, ...
        'n_extra_echoes_ffe', str2double(nExtraEchoes{t}), ...
        'delta_TE', repmat(delta_TE, 1, str2double(nExtraEchoes{t})));
end