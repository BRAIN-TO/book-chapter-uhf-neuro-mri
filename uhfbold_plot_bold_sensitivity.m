% Script uhfbold_plot_bold_sensitivity
% Plots BOLD sensitivity (Deichmann et al., 2002) for a range of TEs and
% T2* values
%
%  uhfbold_plot_bold_sensitivity
%
%
%   See also

% Author:   Lars Kasper
% Created:  2022-02-21
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T2star values from the literature
% Values from Table 1 in :
% Peters, A.M., Brookes, M.J., Hoogenraad, F.G., Gowland, P.A., Francis,
% S.T., Morris, P.G., Bowtell, R., 2007. T2* measurements in human brain at
% 1.5, 3 and 7 T. Magnetic Resonance Imaging, Proceedings of the
% International School on Magnetic Resonance and Brain Function 25,
% 748–753. https://doi.org/10.1016/j.mri.2007.02.014

B0s = [1.5 3 7];
rowLabels = {'1.5 T', '3 T', '7 T'};
columnLabels = {'GM', 'WM', 'Caudate', 'Putamen'};
T2starMeanTable = [
    84.0    66.2    58.8    55.5
    66.0    53.2    41.3    31.5
    33.2    26.8    19.9    16.1
    ]; % in ms

% SD over subjects
T2starSDTable = [
    0.8     1.9     2.4     2.3
    1.4     1.2     2.3     2.5
    1.3     1.2     2.0     1.6
]; % in ms


T = table(T2starMeanTable(:,1), T2starMeanTable(:,2), T2starMeanTable(:,3), ...
    T2starMeanTable(:,4), ...
    'rowNames', rowLabels, ...
    'variableNames', columnLabels);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User-defined plotting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idSubject = 'FEINBERGATRON';
paths = uhfbold_get_paths(idSubject);

%   idxDefinitionBS     
%                   1 = dS/dT2* [Posse1999]
%                   2 = [Deichmann2002]
%                       derivative dS/dT2star is multiplied by
%                       T2star^2, as in , to keep BS scaling
%                       T2*-independent
%                   3 = BS: normalized by signal intensity, i.e., BS/S
%                   4 = dS/dR2*[Poser2006]
%                   5 = as 2, but scaled by T2*-specific max (relative BOLD
%                       sensitivity)

labelDefinitionsBS = {'Posse', 'Deichmann', 'PercentChange', 'Poser', 'Relative to individual max'};
doScaleWithM0 = false; % scale Signal with baseline magnetization (scales with B0); 
idxDefinitionBS = 2;

% selected T2stars for plot, from table above
idRowArray = [2 3 3];
idColArray = [1 1 4];
T2starArray = [T({'3 T', '7 T'},:).GM; T({'7 T'},:).Putamen]';

relMinBS = 0.8; % minimum acceptable BOLD sensitivity within extended readout, relative to maximum

TEArray = (0:1:150); % in ms

% print options
scalingFactorPrint = 2; %1 is good for on-screen, 2 for publication
doSavePlots = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot BOLD Sensitivity with borders for min/max sensitivity ranges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: maybe make rectangle start at about 0.05 below upper line only and
% fill and put label "80 % BS ACQ window"


stringTitle = sprintf('BOLD Sensitivity (%s) for Varying T_2^* and TE', ...
    labelDefinitionsBS{idxDefinitionBS});
fh = figure('Name', stringTitle);
set(fh, 'DefaultAxesFontsize', scalingFactorPrint*16);
if doScaleWithM0
    S0Array = B0s(idRowArray);
else
    S0Array = ones(size(T2starArray));
end


BS = get_bold_sensitivity(TEArray, T2starArray, S0Array, idxDefinitionBS);
maxBS = max(BS);

% normalize max to 1
C = max(maxBS);
BS = BS/C;
maxBS = maxBS/C;

hp = plot(TEArray, BS); hold on;
xlabel('TE (ms)');
ylabel('BOLD Sensitivity (a.u.)');

usedLineColors = get(hp, 'Color');

set(hp, 'LineWidth', scalingFactorPrint*2);

for iT2star = 1:numel(T2starArray)
    T2star = T2starArray(iT2star);
    S0 = S0Array(iT2star);
    % vertical line indicating max
    hl(iT2star,1) = line(T2star*[1 1], [0 maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    
    
    %% find TEs where relative thresholds of max BS is crossed, either left
    % or right of maximum (TE=T2*)
    
    funBSMinusScaledMaxSquare = ...
        @(x) (get_bold_sensitivity(x, T2star, S0, idxDefinitionBS)/C - relMinBS*maxBS(iT2star)).^2;
    TEmin(iT2star) = fmincon(funBSMinusScaledMaxSquare, T2star*0.8, ...
        [], [], [],[], TEArray(1), T2star);
    TEmax(iT2star) = fmincon(funBSMinusScaledMaxSquare, T2star*1.2, ...
        [], [], [],[], T2star, TEArray(end));
    legendArray{iT2star} = sprintf('%s (%s, T_2^* = %2.0f ms)',...
        rowLabels{idRowArray(iT2star)}, columnLabels{idColArray(iT2star)}, ...
        T2star);
    
    hl(iT2star,2) = line([TEmin(iT2star)  TEmax(iT2star)], relMinBS*maxBS(iT2star)*[1 1], 'Color', usedLineColors{iT2star});
    hl(iT2star,3) = line(TEmin(iT2star)*[1 1], [0 relMinBS*maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    hl(iT2star,4) = line(TEmax(iT2star)*[1 1], [0 relMinBS*maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    
     
end

grid on;
grid minor
set(hl, 'LineStyle', '-.', 'LineWidth', scalingFactorPrint*2)
legend(legendArray)
title(stringTitle);

% set previous attractive figure sizes
fh.Position = [10   10   scalingFactorPrint*866   scalingFactorPrint*590];
fh.Children(1).Position = [ 0.5620    0.3969    0.3233    0.2017]; % legend
fhArray(1) = fh;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BOLD Sensitivity as Difference in T2*,
% R2* values from  Table 2 in 
% van der Zwaag, W., Francis, S., Head, K., Peters, A.,
% Gowland, P., Morris, P., Bowtell, R., 2009. fMRI at 1.5, 3 and 7 T:
% Characterising BOLD signal changes. NeuroImage 47, 1425–1434.
% https://doi.org/10.1016/j.neuroimage.2009.05.015 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colLabels   =  {'1.5 T', '3 T', '7 T'};
R2star0     = [11.6 18.1 30.8];
deltaR2star = [0.51 0.98 2.55];

% Note: not much difference in absolute values deltaT2* 3T vs 7T, but
% percentage doubles:
% T2star0 = 1./(R2star0)*1e3;
% deltaT2star = (1./(R2star0)-1./(R2star0+deltaR2star))*1e3;
% => 3.6305    2.8377    2.4825 ms

if doScaleWithM0
    S0Array     = B0s;
else
    S0Array = ones(size(R2star0));
end


stringTitle = 'T_2^* Signal & Differences (BOLD Sensitivity) for varying TE';
fh = figure('Name', stringTitle);
set(fh, 'DefaultAxesFontsize', scalingFactorPrint*16);

% match colors to other plot, correspondence via field strength
matchingLineColors = usedLineColors([3 1 2]);
stringLegend = {};
iT2starArray = 2:3;
for iT2star = iT2starArray
    Sbase= S0Array(iT2star)*exp(-TEArray*1e-3*(R2star0(iT2star)+deltaR2star(iT2star)))';
    Sactive = S0Array(iT2star)*exp(-TEArray*1e-3*R2star0(iT2star))';
    BSasDiff = abs(Sactive - Sbase); % absolute value because here only T2* changes are considered, but flow/overcompensation
    
    % find BS optimum
    funBSDiffSquare = @(TEArray) -(S0Array(iT2star)*(exp(-TEArray*1e-3*R2star0(iT2star)) - ...
        exp(-TEArray*1e-3*(R2star0(iT2star)+deltaR2star(iT2star))))).^2;
    
    TEopt(iT2star) = fminunc(funBSDiffSquare, 1000/(R2star0(iT2star)+deltaR2star(iT2star)));
    
    % plot signal and Bold sensitivity, adjust line styles
    hp2(:,iT2star) = plot(TEArray, [Sbase, Sactive, 10*BSasDiff, BSasDiff./Sbase]); hold on;
    set(hp2(:,iT2star), 'Color', matchingLineColors{iT2star});
    set(hp2(:,iT2star), 'LineWidth', scalingFactorPrint*2);
    hp2(1,iT2star).LineStyle = '--';
    hp2(3,iT2star).LineStyle = '-.';
    hp2(4,iT2star).LineStyle = ':';
    hl(iT2star) = line(TEopt(iT2star)*[1, 1], [0 10*sqrt(abs(funBSDiffSquare(TEopt(iT2star))))]);
    set(hl(iT2star), 'LineStyle', '-.', 'LineWidth', scalingFactorPrint*2, 'Color', matchingLineColors{iT2star});
    
    if iT2star == iT2starArray(end) % first legend entries verbose
        stringLegend(:,iT2star) = strcat(colLabels{iT2star},  ...
            {
            '   Baseline T_2^* Signal'
            '   Activated T_2^* Signal'
            '   Difference x 10 (BOLD Sensitivity)'
            '   Relative Signal Change (\Delta S / S)'
            });
    else
        stringLegend(1:4,iT2star) = colLabels(iT2star);
    end
end
leg = legend(reshape(hp2(:, iT2starArray), 1, []), ...
    reshape(stringLegend(:,iT2starArray), 1, []), 'NumColumns', numel(iT2starArray));
leg.ItemTokenSize = scalingFactorPrint*[29 18];
grid on;
grid minor
title(stringTitle);
xlabel('TE (ms)');
ylabel('Signal (a.u.)');


% set previous attractive figure sizes
fh.Position = [10 10 scalingFactorPrint*793 scalingFactorPrint*564];
fh.Children(1).Position = [0.2982    0.6435    0.5938    0.2332]; % legend
fhArray(2) = fh;

%% save Plots
if doSavePlots
    save_plot_publication(fhArray, paths.figures, [3]);
end