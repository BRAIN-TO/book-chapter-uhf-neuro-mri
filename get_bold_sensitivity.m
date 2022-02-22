function BS = get_bold_sensitivity(TE, T2star, doNormalize)
% Computes BOLD sensitivity for given ranges of TE and T2*
%
%  BS = get_bold_sensitivity(TE, T2star, doNormalize)
%
% IN
%   TE              (array of) TE values
%   T2star          (array of) T2star values (note: use same unit as for TE)
%   doNormalize     true (default) or false
%                   if true, deriviate dS/dT2star is multiplied by
%                   T2star^2, as in original Deichmann-publication, to keep
%                   BS scaling T2*-independent
%
% Deichmann, R., Josephs, O., Hutton, C., Corfield, D.R., Turner, R., 2002.
% Compensation of Susceptibility-Induced BOLD Sensitivity Losses in
% Echo-Planar fMRI Imaging. NeuroImage 15, 120–135.
% https://doi.org/10.1006/nimg.2001.0985

% OUT
%
% EXAMPLE
%   get_bold_sensitivity
%
%   See also

% Author:   Lars Kasper
% Created:  2022-02-21
% Copyright (C) 2022 BRAIN-TO Lab, Techna Institute, UHN Toronto, Canada
%
% Please see LICENSE file for how to use items in this repository.
%

if nargin < 3
    doNormalize = true;
end

[TEGrid, T2starGrid] = ndgrid(TE, T2star);

switch doNormalize
    case 1 
        BS = TEGrid.*exp(-TEGrid./T2starGrid);
    case 0
        BS = TEGrid./(T2starGrid.^2).*exp(-TEGrid./T2starGrid);
    case 2 % normalized by signal intensity (% signal change)
        BS = TEGrid./(T2starGrid.^2);
end