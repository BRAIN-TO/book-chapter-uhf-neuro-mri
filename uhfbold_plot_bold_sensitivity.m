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

idSubject = 'SYNAPTIVE';
paths = uhfbold_get_paths(idSubject);

doSavePlots = 1;

% selected T2stars for plot, from table above
idRowArray = [2 3 3];
idColArray = [1 1 4];
T2starArray = [T({'3 T', '7 T'},:).GM; T({'7 T'},:).Putamen]';

relMinBS = 0.8; % minimum acceptable BOLD sensitivity within extended readout, relative to maximum

TEArray = (0:1:150); % in ms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot BOLD Sensitivity with borders for min/max sensitivity ranges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stringTitle = 'BOLD Sensitivity for varying field strength and TE)';
fh = figure('Name', stringTitle);
set(fh, 'DefaultAxesFontsize', 16);
BS = get_bold_sensitivity(TEArray, T2starArray);
maxBS = max(BS);

% normalize max to 1
C = max(maxBS);
BS = BS/C;
maxBS = maxBS/C;

hp = plot(TEArray, BS); hold on;
xlabel('TE (ms)');
ylabel('Bold Sensitivity (a.u.)');

usedLineColors = get(hp, 'Color');

set(hp, 'LineWidth', 2);

for iT2star = 1:numel(T2starArray)
    T2star = T2starArray(iT2star);
    
    % vertical line indicating max
    hl(iT2star,1) = line(T2star*[1 1], [0 maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    
    
    % find TEs where relative thresholds of max BS is crossed, either left
    % or right of maximum (TE=T2*)
    TEmin(iT2star) = fmincon(@(x) (get_bold_sensitivity(x, T2star)/C - relMinBS*maxBS(iT2star)).^2, T2star*0.8, ...
        [], [], [],[], TEArray(1), T2star);
    TEmax(iT2star) = fmincon(@(x) (get_bold_sensitivity(x, T2star)/C - relMinBS*maxBS(iT2star)).^2, T2star*1.2, ...
        [], [], [],[], T2star, TEArray(end));
    legendArray{iT2star} = sprintf('%s (%s, T_2^* = %2.0f ms)',...
        rowLabels{idRowArray(iT2star)}, columnLabels{idColArray(iT2star)}, ...
        T2star);
    
    hl(iT2star,2) = line([TEmin(iT2star)  TEmax(iT2star)], relMinBS*maxBS(iT2star)*[1 1], 'Color', usedLineColors{iT2star});
    hl(iT2star,3) = line(TEmin(iT2star)*[1 1], [0 relMinBS*maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    hl(iT2star,4) = line(TEmax(iT2star)*[1 1], [0 relMinBS*maxBS(iT2star)], 'Color', usedLineColors{iT2star});
    
     
end

set(hl, 'LineStyle', '--', 'LineWidth', 2)
legend(legendArray)
title(stringTitle);


%% save Plots
fhArray = fh;
if doSavePlots
    save_plot_publication(fhArray, paths.figures, [1]);
end