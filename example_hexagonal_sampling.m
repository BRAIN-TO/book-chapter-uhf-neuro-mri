% Script example_hexagonal_sampling
% Demonstrates how hexagonal sampling (aka CAIPIRINHA) minimizes aliasing for
% spherical/elliptical objects (densest packing)
%
%  example_hexagonal_sampling
%
%
%   See also
 
% Author:   Lars Kasper
% Created:  2021-12-18
% Copyright (C) BRAIN-TO Lab, Techna Institute, UHN, Toronto, Canada
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create sampling patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaleFactorAreaHexagonCartesian = sqrt(3)/2;
scalerFactorEdgeHexagonCartesian = sqrt(scaleFactorAreaHexagonCartesian);

nPixels = 128;
cartesianGrid_R2x2 = zeros(nPixels);
cartesianGrid_R2x2(1:2:end,1:2:end) = 1;
hexagonalGrid_R2x2 = cartesianGrid_R2x2;

%vertical
cartesianGrid_R2x2(2:2:end,1:2:end) = 1;
hexagonalGrid_R2x2(2:2:end,2:2:end) = 1;

Kcart = MrImage(cartesianGrid_R2x2);
Khex = MrImage(hexagonalGrid_R2x2);

Kcart.plot;
Khex.plot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Shapes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shepp-logan
phantomMatrix = phantom(nPixels);
phantomImage = MrImage(phantomMatrix);

% Circle
imageSizeX = nPixels;
imageSizeY = nPixels;

[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
centerX = nPixels/2;
centerY = nPixels/2;
radius = nPixels/2;
circleMatrix = (rowsInImage - centerY).^2 ...
+ (columnsInImage - centerX).^2 <= radius.^2;

circleImage = MrImage(circleMatrix);

% Hexagon
theta=linspace(0,2*pi,7);
vertexX=cos(theta);
vertexY=sin(theta);
[columnsInImage,rowsInImage] = meshgrid(linspace(-1,1,nPixels),linspace(-1,1,nPixels));
hexagonMatrix = inpolygon(columnsInImage,rowsInImage,vertexX,vertexY);

hexagonImage = MrImage(hexagonMatrix);

% Hexagon, scaled to the size of the actual FOV w/o overlap, induced by the
% imaging pattern in hexagonalGrid_R2x2

% no idea where the factor ^3 comes from. Would have thought it to be ^1)
nPixelsScaled = 2*floor(round(nPixels*scalerFactorEdgeHexagonCartesian.^3)/2);

[columnsInImage,rowsInImage] = ...
    meshgrid(linspace(-1,1,nPixelsScaled),linspace(-1,1,nPixelsScaled));
hexagonScaledMatrix = inpolygon(columnsInImage,rowsInImage,vertexX,vertexY);
hexagonScaledMatrix =  padarray(hexagonScaledMatrix, ...
    round((nPixels - nPixelsScaled)/2*[1 1]), 0, 'both');

hexagonScaledImage = MrImage(hexagonScaledMatrix);



%% Plot reconstructed image with different k-space undersampling patterns
X = Kcart;
Y = phantomImage;
plot(abs(fft((Y.fft('2d')).*X, '2d')))

X = Khex;
plot(abs(fft((Y.fft('2d')).*X, '2d')))

Y = circleImage;
plot(abs(fft((Y.fft('2d')).*X, '2d')))

Y = hexagonImage;
plot(abs(fft((Y.fft('2d')).*X, '2d')))

Y = hexagonScaledImage;
plot(abs(fft((Y.fft('2d')).*X, '2d')))
