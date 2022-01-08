function [fh, hs, data] = plot_k(k, varargin)
%plots 2D trajectory and 1D representations of k, gradient and slewrate
%
%    [fh, hs, data] = plot_k(k, [time, g, s, gmax])
%
%   NOTE: all input arguments except k are optional; if not given,
%   gradients and slewrate are computed assuming default gradient sampling
%   dwell time of 6.4e-6 seconds
%
% IN
%   k       [kx,ky,kz] nSamples x 3 matrix of k-space samples   [rad/m]
%
%   optional arguments as parameter name/value pairs
%   dt      (instead of time) dwell time [seconds]; (default: dt = 6.4 mus)
%   time    time vector for k or dwell time, default: use dt    [seconds]
%   g       [nSamples,3] gradient samples corresponding to k    [T/m]
%   s       [nSamples, 3] slew rate samples corresponding to k  [T/m/s]
%   gmax    maximum gradient or function handle (dependent on k)[Gauss/cm = T/m * 100]
%   smax    maximum slew rate (T/m/s) for plotting
%   zoomTime    [tstart, tend] times to zoomTime trajectory into
%   zoomFreq    [fStart, fEnd) frequency range for gradient spectrum to
%               zoom into (in kHz)
%   forbiddenFreq [nFreq, 2] display of forbidden frequencies 
%                  [fmin1 fmax1;
%                   fmin2 fmax2]
%   dispMode    'matlab' for plotting
%               'print' for saving data as plot
%   nPlotEvery
%           define how many data points shall be plotted for 2D-plot
%           default: 1;
%
%   lineStyle
%           defines how 2D trajectory shall be plotted
%           default: '.-'
%   name    string used as super title of plot
%
% OUT
%   fh      figure handle
%   hs      subplot handles
%   data    all computed data used for plotting
%           .k
%           .g        computed gradient (T/m)
%           .s        computed slew rate (T/m/s)
%           .time/timeGradient/timeSlew - time vector (ms) for all time
%                     courses
%           .FT_G     fourier Transform of (g);
%           .freq_kHz frequency vector corresponding to FT_G    
%        
% EXAMPLE
%   plot_k
%
%   See also
%
% Author:   Lars Kasper
% Created:  2020-11-17
% Copyright (C) 2020 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.

defaults.name       = 'Traj Grad Slew Plot';
defaults.dt         = 6.4e-6;
defaults.time       = [];
defaults.g          = [];
defaults.s          = [];
defaults.gmax       = 31e-3;
defaults.smax       = 200;
defaults.zoomTime   = [];
defaults.zoomFreq   = [0 5];
defaults.forbiddenFreq = [590 + [-50 50]; 1140 + [-50 50]]/1e3;
defaults.zoomK      = [];
defaults.dispMode   = 'matlab'; % 'matlab' or 'print'
defaults.nPlotEvery = 1;
defaults.lineStyle  = '.-';
defaults.positionLegend = 'NorthWest';
defaults.fh = []; %figure handle, if given, no new figure is created
defaults.hs = [];

args = propval(varargin, defaults);
strip_fields(args);

hasSubplotHandle = ~isempty(hs);
hasTime = ~isempty(time);
hasGradient = ~isempty(g);
hasSlewRate = ~isempty(s);
hasGmax = ~isempty(gmax);
hasSmax = ~isempty(smax);
hasZoomTime = ~isempty(zoomTime);
hasZoomFreq = ~isempty(zoomFreq);
hasZoomK = ~isempty(zoomK);


hasGmaxhandle = hasGmax && isa(gmax, 'function_handle');
hasSmaxhandle = hasSmax && isa(smax, 'function_handle');


gamma_1H = 2*pi*42.57e6;  % rad/Tesla/s
nSamples = size(k,1);
nDims = size(k,2);

if ~hasTime
    time = (0:(nSamples-1))*dt;
else
    dt = time(2)-time(1);
end


% TODO: Incorporate Johanna's dt/2-shift!
if ~hasGradient
    g = zeros(size(k));
    g(2:end,:) = diff(k)/gamma_1H/dt;
end


if ~hasSlewRate
    s = zeros(size(k));
    s(2:end,:) = diff(g)/dt;
end

%% find zoom window for 1D plots

if ~hasZoomTime
    tStart  = time(1);
    tEnd    = time(end);
else
    tStart  = zoomTime(1);
    tEnd    = zoomTime(2);
end


[~,iStart]  = min(abs(time-tStart));
[~,iEnd]    = min(abs(time-tEnd));
iSamples    = iStart:iEnd;


%% Compute different time samples for trajectory, gradient and slew rate
time            = time*1000;
tStart          = tStart*1000;
tEnd            = tEnd*1000;
timeGradient    = time - dt/2;
timeSlew        = time - dt;

%% Prepare

if isempty(fh)
    if exist('tapas_physio_get_default_fig_params') && ...
            strcmpi(dispMode', 'print')
        fh = tapas_physio_get_default_fig_params();
    else
        fh = figure('Name', name);
        set(fh, 'WindowStyle', 'docked');
    end
else
    figure(fh);
end

is3D = nDims == 3;

if hasSubplotHandle
    % replace data instead of replot for faster performance
    hs(4).Children(1).XData = k(1:nPlotEvery:end,1);
    hs(4).Children(1).YData = k(1:nPlotEvery:end,2);
    if is3D
        hs(4).Children(1).ZData = k(1:nPlotEvery:end,3);
    end
else
    hs = gobjects(5,1); % to preinitialize array of axes correctly
    hs(4) = subplot(3,6,[1:3 7:9]); % for some reason, initializing array straight away does not work, assemble later
    plot(k(1:nPlotEvery:end,1),k(1:nPlotEvery:end,2), lineStyle, 'LineWidth', 0.5);
    
    title('k-Space Trajectory');
    xlabel('k_x (rad/m)'); ylabel('k_y (rad/m)');
    axis image;
    
    if hasZoomK
        axis(zoomK);
    end
end

% crop all samples to actual display for 1D plots
k = k(iSamples,:);
g = g(iSamples,:);
s = s(iSamples,:);
time = time(iSamples);
timeGradient = timeGradient(iSamples);
timeSlew = timeSlew(iSamples);


%% plot k vs time

if hasSubplotHandle
    for iLine = 1:2
        hs(1).Children(iLine).XData = time;
        hs(1).Children(iLine).YData = k(:,iLine);
    end
else
    %% first plot into axis
    hs(1) = subplot(3,6, 13:15);
    plot(time, k); xlabel('t (ms)'); title('Trajectory: k (rad/m)');
    if hasZoomK
        ylim(zoomK(3:4));
    end
    
    stringLegendK = {'k_x', 'k_y', 'k_z'};
    
    legend(stringLegendK{1:nDims}, 'Location', positionLegend);
end

%% Plot FT(G) vs f
 freq_kHz = time2freq(timeGradient/1e3)/1e3;
 FT_G = fftshift(fft(ifftshift(g*1e3)));
if hasSubplotHandle % just replace plotData in axes handle, w/o recreating objects, e.g. legends
% TODO: CHECK if works
    for iLine = 1:2
        hs(5).Children(iLine).XData = freq_kHz;
        hs(5).Children(iLine).YData = abs(FT_G(:,iLine));
    end
else
    hs(5) = subplot(3,6, 4:6);
   
    plot(freq_kHz, abs(FT_G)); hold all;
    xlabel('f [kHz]');
    title('Spectrum: |FFT(G)|');
    
    if hasZoomFreq
        xlim([zoomFreq(1) zoomFreq(2)]); % show positive frequencies only
    else
        xlim([0 freq_kHz(end)]); % show positive frequencies only
    end
    
    for iForbidden = 1:size(forbiddenFreq,1)
        vline(forbiddenFreq(iForbidden,1));
        vline(forbiddenFreq(iForbidden,2));
    end
    
    [maxAmp, idxMaxFreq] = max(abs(FT_G));
    maxFreq = abs(freq_kHz(idxMaxFreq));
    for iDim = 1:size(FT_G,2);
        vline(maxFreq(iDim), 'r-');
        text(maxFreq(iDim), maxAmp(iDim), sprintf('%4.2f kHz', maxFreq(iDim)));
    end
    
    stringLegendFT_G = {'|FT(G_x)|','|FT(G_y)|', '|FT(G_z)|'};
    
    legend(stringLegendFT_G{1:nDims}, 'Location', 'NorthEast');

end


%% plot G vs t

% create data to be combined for plotting
if hasGmax
    hold all;
    if hasGmaxhandle
        plotG = [g*1e3, gmax(k)*1e3, -gmax(k)*1e3]; % gmax given in Gauss/cm here
        
        % in case gmax-function created a plot, remove it
        if gcf~=fh
            close(gcf);
            figure(fh);
        end
    else
        plotG = [g*1e3, gmax*1e3*ones(size(g,1),1), -gmax*1e3*ones(size(g,1),1)];
    end
    stringLegendG = { 'G_x', 'G_y', 'G_z', 'G_{max}'};
else
    plotG = g*1e3;
    stringLegendG = { 'G_x', 'G_y', 'G_z' };
end

if ~is3D % remove extra legend for 3rd direction
    stringLegendG(3) = [];
end

if hasSubplotHandle % just replace plotData in axes handle, w/o recreating objects, e.g. legends
    nLines = nDims + 2*hasGmax;
    for iLine = 1:nLines
        hs(2).Children(iLine).XData = timeGradient;
    end
    
    % add y data in same reverse order as when created first
    for iDim = 1:nDims
        hs(2).Children(nLines - nDims + iDim).YData = plotG(:,iDim);
    end
    
    if hasGmax % extra lines to be plotted for grad limits and changed data
        hs(2).Children(2).YData = plotG(:,end-1);
        hs(2).Children(1).YData = plotG(:,end);
    end
    
else % create new axes and fresh legends etc.
    
    hs(2) = subplot(3,6, 6 + (4:6));
    ph = plot(timeGradient, plotG); xlabel('t (ms)'); title('Speed: G (mT/m)');
    
    if hasGmax
        set(ph(end-1:end), 'Color', 'r', 'LineStyle', '--');
    end
    
    
    legend(stringLegendG, 'Location', positionLegend);
end

%% plot SR vs t

% create data to be combined for plotting
if hasSmax
    hold all;
    if hasSmaxhandle
        plotS = [s, smax(k), -smax(k)]; % gmax given in Gauss/cm here
        
        % in case gmax-function created a plot, remove it
        if gcf~=fh
            close(gcf);
            figure(fh);
        end
    else
        plotS = [s, smax*ones(size(s,1),1), -smax*ones(size(s,1),1)];
    end
    stringLegendS = { 'SR_x', 'SR_y', 'SR_z', 'SR_{max}'};
else
    plotS = s;
    stringLegendS = { 'SR_y', 'SR_y', 'SR_z' };
end

if ~is3D
    stringLegendS(3) = [];
end

if hasSubplotHandle % just replace plotData in axes handle, w/o recreating objects, e.g. legends
    nLines = nDims + 2*hasSmax;
    for iLine = 1:nLines
        hs(3).Children(iLine).XData = timeGradient;
    end
    
    % add y data in same reverse order as when created first
    for iDim = 1:nDims
        hs(3).Children(nLines - nDims + iDim).YData = plotS(:,iDim);
    end
    
    if hasGmax % extra lines to be plotted for slew limits and changed data
        hs(3).Children(2).YData = plotS(:,end-1);
        hs(3).Children(1).YData = plotS(:,end);
    end
    
else % create new axes and fresh legends etc.
    
    hs(3) = subplot(3,6, 12+ (4:6));
    slewplot = plot(timeSlew, plotS); xlabel('t (ms)');
    title('Acceleration: Slew rate (T/m/s)');
    
    legend(stringLegendS{:}, 'Location', 'SouthEast');
    
    if hasSmax
        set(slewplot(end-1:end), 'Color', 'r', 'LineStyle', '--');
    end
    
    legend(stringLegendS, 'Location', positionLegend);
    
    
    linkaxes(hs(1:3), 'x');
    axis tight
    xlim([tStart, tEnd]);
    
end

if nargout >=3
    data.k = k;
    data.g = g;
    data.s = s;
    data.time = time;
    data.timeGradient = timeGradient;
    data.timeSlew = timeSlew;
    data.freq_kHz = freq_kHz;
    data.FT_G = FT_G;
end

