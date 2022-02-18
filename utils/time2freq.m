function [f, df, f_max] = time2freq(t)
% Function to compute frequency vector corresponding to a time-vector 
% (assuming fftshift)
%
% USE
% [f, df, f_max] = time2freq(t)
%
% IN
% t         [n_samples x 1] time vector [s]
% 
% OUT
% f         [n_samples x 1] frequency vector [Hz]
% df        frequency resolution [Hz]
% f_max     bandwidth [Hz]
%
% vannesjo/ibt_2014/university and eth zurich, switzerland
% $Id: time2freq.m 2399 2016-12-15 12:26:48Z weiger $

nrs = length(t);
dt = t(2)-t(1);
f_max = 1/dt;
df = f_max/nrs;
f = ([0:nrs-1]'-floor(nrs/2))*df;

