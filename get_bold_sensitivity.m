function BS = get_bold_sensitivity(TE, T2star, S0, idxDefinitionBS)
% Computes BOLD sensitivity for given ranges of TE and T2*
%
%   BS = get_bold_sensitivity(TE, T2star, S0, idxDefinitionBS)
%
% IN
%   TE              (array of) TE values
%   T2star          (array of) T2star values (note: use same unit as for TE)
%   S0              (array of) Baseline Magnetization (e.g., proportional to B0)
%                    same size as T2star
%   idxDefinitionBS     
%                   1 = dS/dT2* [Posse1999]
%                   2 = [Deichmann2002]
%                       derivative dS/dT2star is multiplied by
%                       T2star^2, as in , to keep BS scaling
%                       T2*-independent
%                   3 = BS: normalized by signal intensity, i.e., BS/S
%                   4 = dS/dR2*[Poser2006] 
%                   5 = [Deichmann2002], but scaled to individual max for
%                       each T2*
%
% [1] B.A. Poser, M.J. Versluis, J.M. Hoogduin, D.G. Norris, BOLD contrast
% sensitivity enhancement and artifact reduction with multiecho EPI:
% Parallel-acquired inhomogeneity-desensitized fMRI, Magn. Reson. Med. 55
% (2006) 1227–1235. https://doi.org/10.1002/mrm.20900. 
% [2] R. Deichmann, O.
% Josephs, C. Hutton, D.R. Corfield, R. Turner, Compensation of
% Susceptibility-Induced BOLD Sensitivity Losses in Echo-Planar fMRI
% Imaging, NeuroImage. 15 (2002) 120–135.
% https://doi.org/10.1006/nimg.2001.0985. 
% [3] S. Posse, S. Wiese, D.
% Gembris, K. Mathiak, C. Kessler, M.-L. Grosse-Ruyken, B. Elghahwagi, T.
% Richards, S.R. Dager, V.G. Kiselev, Enhancement of BOLD-contrast
% sensitivity by single-shot multi-echo functional MR imaging, Magnetic
% Resonance in Medicine. 42 (1999) 87–97.
% https://doi.org/10.1002/(SICI)1522-2594(199907)42:1<87::AID-MRM13>3.0.CO;2-O.


% OUT
%   BS  [nTE, nT2star] columns vectors of Bold sensitivities per T2*
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
    S0 = 1;
end

if nargin < 4
    idxDefinitionBS = 1;
end

if numel(S0) == 1
    S0 = repmat(S0, size(T2star));
end

[TEGrid, T2starGrid] = ndgrid(TE, T2star);
[TEGrid, S0Grid] = ndgrid(TE, S0); % same size of T2* and S0 assumed


switch idxDefinitionBS
    case 1
        BS = S0Grid.*TEGrid./(T2starGrid.^2).*exp(-TEGrid./T2starGrid);
    case 2 
        BS = S0Grid.*TEGrid.*exp(-TEGrid./T2starGrid);
    case 3 % normalized by signal intensity (% signal change)
        BS = TEGrid./(T2starGrid.^2);
    case 4
        R2starGrid = 1./T2starGrid;
        S = S0Grid.*exp(-TEGrid.*R2starGrid);
        BS = abs(-TEGrid.*S); % the abs is for consistency
    case 5
       BS = S0Grid.*TEGrid.*exp(-TEGrid./T2starGrid);
       if numel(TE) > 1 % normalize over all TEs, but not if a single one is calculated
           BS = BS./max(BS);
       end
 end