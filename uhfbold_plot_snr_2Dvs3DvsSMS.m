% Script uhfbold_plot_snr_2Dvs3DvsSMS
% Plots comparison 2D / 3D / SMS SNR assuming same Ernst-angle excitation
% and same acquisition time per slice or 3D kz-plane
%
%  uhfbold_plot_snr_2Dvs3DvsSMS
%
%
%   See also
% [Poser2010]
% Poser, B.A., Koopmans, P.J., Witzel, T., Wald, L.L., Barth, M., 2010.
% Three dimensional echo-planar imaging at 7 Tesla. NeuroImage 51, 261–266.
% https://doi.org/10.1016/j.neuroimage.2010.01.108
%
% [Marques2018]
% Marques, J.P., Norris, D.G., 2018. How to choose the right MR sequence
% for your research question at 7T and above? NeuroImage, Neuroimaging with
% Ultra-high Field MRI: Present and Future 168, 119–140.
% https://doi.org/10.1016/j.neuroimage.2017.04.044
%
% [Stirnberg2020]
% Educational Talk on "State-of-the-Art Echo-Planar BOLD Acquisition",
% ISMRM 2020, Abstract E1090 ISMRM Syllabus:
% https://submissions2.mirasmart.com/ISMRM2020/ViewSubmission.aspx?sbmID=1090&validate=false
% Video: https://www.youtube.com/watch?v=wuAjYtqI4cY

% Author:   Lars Kasper
% Created:  2022-03-14
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define parameters and SNR functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% T1 Values from [Poser2010]
T1 = 1.4;

% TR between consecutive excitations (neighboring slices or re-excitation 3D volume)
% 50 ms is the favorable trajectory duration for 7T (see Fig. 24.4.1), and
% I added some buffer for slice excitation, longer TE and contrast cleanup
% (fat suppression, spoiling)
TR = 70e-3; % 65e-3; %70e-3; 

% maximum assumed undersampling factor in slice direction for SMS (MB factor) and 3D
% only affects the 2nd figure with the SMS comparison, Rz = 1 is fixed in
% Figure 1
RzFigure2 = 4; % 2;            
FOVz = 120; % 100; %120;


idSubject = 'FEINBERGATRON';
paths = uhfbold_get_paths(idSubject);

doPlotDirectRelativeSnr3DSMSStirnberg = false; %for comparison, should be the same
doSavePlots = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define SNR functions, see derivations in Word document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: all SNR is rescaled to the same volume TR, i.e., we acquire Rz
% averages for the SMS and 3D cases (equivalent to scaling with sqrt(TR))
% SNR_2D and SNR_2D_exp are equivalent, only differ in expression via exp
% or tanh, with tanh(x) = (exp(2x)-1)/(exp(2x)+1)
SNR_2D_exp = @(TRvol,T1) (sqrt((1-exp(-TRvol/T1))./(1+exp(-TRvol/T1))));
SNR_2D = @(TRvol,T1) (sqrt(tanh(TRvol/(2*T1)))); 

% Consistent with Stirnberg, TRvol is based on TR from undersampled experiment TR2D/Rz
SNR_3D = @(TRvol,T1,nSlices, Rz) (sqrt(nSlices.*tanh(TRvol.*Rz./(nSlices*2*T1))));
SNR_SMS = @(TRvol,T1,nSlices, Rz) (sqrt(Rz.*tanh(TRvol/(2*T1))));
% direct formula from Stirnberg ISMRM Educational 2020, for verification
rRSNR_3DvsSMS = @(TRvol,T1,nSlices, Rz) (sqrt(nSlices./Rz).*sqrt(tanh(TRvol./(2*T1)*Rz./nSlices)./tanh(TRvol./(2*T1))));


colors = [
     0 0 0
     0    0.4470    0.7410
     0.8500    0.3250    0.0980
     ];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot 2D vs 3D SNR, no undersampling in z (reproduces [Poser2010])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stringTitle = {'SNR 2D vs 3D Acquisition', ...
    sprintf('(T_1 = %4d ms, TR_{slice} = %2d ms, FOV_z = %3d mm)', ...
    T1*1e3, TR*1e3, FOVz)};
fh = figure('Name', stringTitle{1});
set(fh, 'DefaultAxesFontsize', 16);

nSlices = (40:12000)';
TRvol = nSlices*TR;

% comparison plots of formulas...exp and tanh equivalent!
% x = TRvol;
% y1 = SNR_2D_exp(TRvol, T1);
% y2 = SNR_2D(TRvol, T1);
% plot(x, [y1,y2]);
% legend('exp', 'tanh');  

Rz = 1;
x = FOVz./nSlices;
y1 = SNR_2D(TRvol, T1);
y2 = SNR_3D(TRvol, T1, nSlices, Rz);

% subplot vs resolution 
subplot(2,1,1);
hp = plot(x, [y1,y2]); hold all;
hp(1).Color = colors(1,:);
hp(2).Color = colors(3,:); % to match colors with plot below


hp2 = plot(x, y2./y1); hold all;
hp2(1).Color = hp(2).Color;
set(hp2, 'LineWidth', 2, 'LineStyle', '-.');

xlim([0, max(x)]);
ylim([0 3.5])
set(hp, 'LineWidth', 2);
legend('SNR 2D', 'SNR 3D', 'SNR 3D/2D'); 
xlabel('Resolution (mm)');
ylabel('Relative SNR');
title(stringTitle)
grid on

% subplot vs nSlices (as in [Poser2010]);
subplot(2,1,2)

nSlices = (1:150)';
TRvol = nSlices*TR;
x = nSlices;
y1 = SNR_2D(TRvol, T1);
y2 = SNR_3D(TRvol, T1, nSlices, Rz);

hp = plot(x, [y1,y2]); hold all;
hp(1).Color = colors(1,:);
hp(2).Color = colors(3,:); % to match colors with plot below

hp2 = plot(x, y2./y1); hold all;
hp2(1).Color = hp(2).Color;
set(hp2, 'LineWidth', 2, 'LineStyle', '-.');

xlim([0, max(x)]);
ylim([0 2])
set(hp, 'LineWidth', 2);
legend('SNR 2D', 'SNR 3D', 'SNR 3D/2D', 'Location', 'SouthEast'); 
xlabel('nSlices');
ylabel('Relative SNR');
title(stringTitle)
grid on


fh.Position = [680   50   866   1000];
fhArray(1) = fh;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot 2D vs 3D vs SMS SNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Rz = RzFigure2;
stringTitle = {'SNR 2D vs SMS vs 3D Acquisition', ...
    sprintf('(T_1 = %4d ms, TR_{slice} = %2d ms, FOV_z = %3d mm, R_z = %d)', ...
    T1*1e3, TR*1e3, FOVz, Rz)};
fh = figure('Name', stringTitle{1});
set(fh, 'DefaultAxesFontsize', 16);

nSlices = (40:12000)';
TRvol = nSlices*TR/Rz; % Volume TR of undersampled case!

% comparison plots of formulas...exp and tanh equivalent!
% x = TRvol;
% y1 = SNR_2D_exp(TRvol, T1);
% y2 = SNR_2D(TRvol, T1);
% plot(x, [y1,y2]);
% legend('exp', 'tanh');  

x = FOVz./nSlices;
y1 = SNR_2D(TRvol*Rz, T1); % volume TR in 2D longer
y2 = SNR_SMS(TRvol, T1, nSlices, Rz);
y3 = SNR_3D(TRvol, T1, nSlices, Rz);
y4 = rRSNR_3DvsSMS(TRvol, T1, nSlices, Rz);
hp = plot(x, [y1,y2,y3]); hold on
for iPlot=1:numel(hp), hp(iPlot).Color = colors(iPlot,:); end
 
set(hp, 'LineWidth', 2);

if doPlotDirectRelativeSnr3DSMSStirnberg
    hp2 = plot(x, [y2./y1, y3./y1, y3./y2, y4]);
else
    hp2 = plot(x, [y2./y1, y3./y1, y3./y2]);
end

xlim([0, max(x)]);
ylim([0.5 3.5])

% match colors of ratios to numerator color
set(hp2, 'LineWidth', 2, 'LineStyle', '-.');
hp2(1).Color = hp(2).Color;
hp2(2).Color = hp(3).Color;
hp2(3).Color = [0.9290    0.6940    0.1250];

if doPlotDirectRelativeSnr3DSMSStirnberg
    legend('SNR 2D', 'SNR SMS', 'SNR 3D', 'SNR SMS/2D', 'SNR 3D/2D', 'SNR 3D/SMS', 'direct rSNR 3D/SMS');
else
    legend('SNR 2D', 'SNR SMS', 'SNR 3D', 'SNR SMS/2D', 'SNR 3D/2D', 'SNR 3D/SMS');
end

xlabel('Resolution (mm)');
ylabel('Relative SNR');
grid on
title(stringTitle)

fh.Position = [680   508   866   590];
%fh.Children(1).Position = [ 0.5620    0.3969    0.3233    0.2017]; % legend


fhArray(2) = fh;

%% save Plots
if doSavePlots
    save_plot_publication(fhArray, paths.figures, [1]);
end