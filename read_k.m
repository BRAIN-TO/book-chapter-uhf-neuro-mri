function [k, gradobj] = read_k(idTraj, pathTrajData);
% Loads previously created trajectory from file and returns it alongside
% gradient object
%
% [k, gradobj] = read_k(idTraj, pathTrajData);
%
% IN
%
% OUT
%
% EXAMPLE
%   read_k
%
%   See also
%
% Lars Kasper (c) 2020-03-12 


fileGradient = 'gradientsFull.txt';
fileGradient = fullfile(pathTrajData, num2str(idTraj), fileGradient);

if ~isfile(fileGradient)
    fileGradient = 'gradients.txt';
    fileGradient = fullfile(pathTrajData, num2str(idTraj), fileGradient);
end

gs = GradientSystem();
gs.MAX_GRADIENT = 0.031;
gradobj = GradientWriter(gs,GradientWriterInput());
gradobj.loadFromTxt(fileGradient);

k = squeeze(gradobj.GetK());
