% Script uhfbold_create_epi_spiral_trajectories
% Creates spiral & cartesian (FFE, EPI, multi-echo) trajectories from index file
%
%
% Author: Lars Kasper
% Created: 2022-01-07

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

idSubject = 'FEINBERGATRON'; % 'MAXTAQ50100INSERTR4';%'MAXTAQ50100INSERT';%'MAXTAQ50100'; % 'MAXTAQ50100'; 'SYNAPTIVE'; %'UHFBOLD';
vendor = 'SIEMENS'; % 'SIEMENS', 'PHILIPS' for gradient dwell;

iEpiTrajArray = [3];
iSpiralTrajArray = [4];

doUseGradientFile = false; % if false, take array population from arrays below


switch idSubject
    case 'MAXTAQ50100R4'
        RArray = [4];
        %50ms TAQ: for EPI 0.95 w/ 40, 0.85 w/ 80 mT/m; for spiral 0.85 w/ 40 mT/m
        %100 ms TAQ: for spiral 0.5@80mT/m, for EPI 0.55@80mT/m
        resArray = [0.8 0.85 0.9 0.95 0.45 0.5 0.55 0.6]*1e-3; 
        GmaxArray = [80]*1e-3;
        SRmaxArray = [200];
    case 'MAXTAQ50100'
        RArray = [1];
        resArray = [2.2 2.15 2.1 1.4 1.35 1.3 1.2]*1e-3;
        GmaxArray = [80]*1e-3;
        SRmaxArray = [200];
    case 'MAXTAQ50100INSERT'
        RArray = [1];
        resArray = [1.4 1.3 1.2 0.8 0.9]*1e-3;
        GmaxArray = [100]*1e-3;
        SRmaxArray = [1200];
    case 'MAXTAQ50100INSERTR4'
        %50ms TAQ: for EPI 0.575 mm, for spiral 0.525 mm
        RArray = [4];
        resArray = [0.5 0.525 0.55 0.575]*1e-3;
        GmaxArray = [100]*1e-3;
        SRmaxArray = [1200];
    case 'SYNAPTIVE'
        RArray = [1 2 3 4];
        resArray = [3 2.5 2 1.5 1 0.75 0.5 0.25]*1e-3;
        GmaxArray = [40 80 100 100 200]*1e-3;
        SRmaxArray = [200 200 400 1200 600];
    case 'UHFBOLD'
        RArray = [1 2 3 4];
        resArray = [3 2 1 0.75 0.5 0.25]*1e-3;
        GmaxArray = [40 80 100 200]*1e-3;
        SRmaxArray = [200 200 1200 600];
    case 'FEINBERGATRON' 
        % as SYNAPTIVE, but replace parallel mode (max Gmax) of 
        % Weiger et al., 2018 with Feinberg et al., 2021 specs, (higher SR)
        RArray = [1 2 3 4];
        resArray = [3 2.5 2 1.5 1 0.75 0.5 0.25]*1e-3;
        GmaxArray = [40 80 100 100 200]*1e-3;
        SRmaxArray = [200 200 400 1200 900];
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

for t = iSpiralTrajArray
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


for t = iEpiTrajArray
    
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