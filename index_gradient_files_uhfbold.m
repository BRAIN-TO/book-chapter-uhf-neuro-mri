% id, FOVm, FOVp, FOVs, dxm, dxp, dxs, Rp, Rs, nIl, maxG, maxSR, maxTacq, in/out
% OR (# added echoes), type, scheme3D, nPlanesPerShot
% InOut/OutIn-Trajektorien
% For 2D trajectories, set FOVs and dxs to zero.
% scheme3D: 'etagere', 'stack' (of spirals),'yarnball','shells','cones',
% 'blippedCones','gaSpiral' (leave empty or 'stack' for 2D traj)

%id = [gradient system, res, R, EPI=1,Spiral=2]

%% Demo for Talk 1mm spiral and
% comparative EPI with same k-space are (sqrt(4/pi) factor in resolution)
1741, 0.22, 0.22, 0, 0.75e-3, 0.75e-3, 0, 4, 1, 1, 40e-3, 200, 0, 0, EPI, stack, 1
1742, 0.22, 0.22, 0, 0.6647e-3, 0.6647e-3, 0, 4, 1, 1, 40e-3, 200, 0, out, minTime, stack, 1

2741, 0.22, 0.22, 0, 0.75e-3, 0.75e-3, 0, 4, 1, 1, 80e-3, 200, 0, 0, EPI, stack, 1
2742, 0.22, 0.22, 0, 0.6647e-3, 0.6647e-3, 0, 4, 1, 1, 80e-3, 200, 0, out, minTime, stack, 1


1141, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 4, 1, 1, 40e-3, 200, 0, 0, EPI, stack, 1
1142, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 4, 1, 1, 40e-3, 200, 0, out, minTime, stack, 1

2141, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 4, 1, 1, 80e-3, 200, 0, 0, EPI, stack, 1
2142, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 4, 1, 1, 80e-3, 200, 0, out, minTime, stack, 1

3111, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 1, 1, 1, 200e-3, 600, 0, 0, EPI, stack, 1
3112, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 1, 1, 1, 200e-3, 600, 0, out, minTime, stack, 1

4111, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 1, 1, 1, 100e-3, 1200, 0, 0, EPI, stack, 1
4112, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 1, 1, 1, 100e-3, 1200, 0, out, minTime, stack, 1

3141, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 4, 1, 1, 200e-3, 600, 0, 0, EPI, stack, 1
3142, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 4, 1, 1, 200e-3, 600, 0, out, minTime, stack, 1

4141, 0.22, 0.22, 0, 1e-3, 1e-3, 0, 4, 1, 1, 100e-3, 1200, 0, 0, EPI, stack, 1
4142, 0.22, 0.22, 0, 0.8862e-3, 0.8862e-3, 0, 4, 1, 1, 100e-3, 1200, 0, out, minTime, stack, 1

