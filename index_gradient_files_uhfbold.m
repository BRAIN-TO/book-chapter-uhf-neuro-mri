% id, FOVm, FOVp, FOVs, dxm, dxp, dxs, Rp, Rs, nIl, maxG, maxSR, maxTacq, in/out
% OR (# added echoes), type, scheme3D, nPlanesPerShot
% InOut/OutIn-Trajektorien
% For 2D trajectories, set FOVs and dxs to zero.
% scheme3D: 'etagere', 'stack' (of spirals),'yarnball','shells','cones',
% 'blippedCones','gaSpiral' (leave empty or 'stack' for 2D traj)


%% Demo for Talk 1mm spiral and
% comparative EPI with same k-space are (sqrt(4/pi) factor in resolution)
101, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 4, 1, 1, 40e-3, 200, 0, 0, EPI, stack, 1
201, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 4, 1, 1, 40e-3, 200, 0, out, minTime, stack, 1


1001, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 1, 1, 1, 200e-3, 600, 0, 0, EPI, stack, 1
2001, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 1, 1, 1, 200e-3, 600, 0, out, minTime, stack, 1

1101, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 1, 1, 1, 100e-3, 1200, 0, 0, EPI, stack, 1
2101, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 1, 1, 1, 100e-3, 1200, 0, out, minTime, stack, 1
