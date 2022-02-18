# book-chapter-uhf-neuro-mri
Educational Code related to book *"Ultra High Field Neuro MRI"*, chapter 24: _"BOLD fMRI: Physiology and Acquisition strategies"_

## Purpose

This repository shall contain code to illustrate certain acquisition considerations for fMRI at ultra-high field, in particular:

- Acquisition Efficiency: 2D spiral/EPIs for different undersampling factors (R) and gradient systems
- BOLD sensitivity
- SNR comparison: 2D vs 3D vs multi-band
- thermal vs physiological noise

It also serves to recreate certain figures within the book chapter.

## Getting Started

### General
You will have to update the paths in `uhfbold_get_paths` to your system environment. Not all code folders are needed (e.g., `recon`)

### Acquisition Efficiency: 2D spiral/EPIs
This part of the code simulates realistic gradient waveforms for EPI and spiral trajectories
for different defined gradient systems.

It is based on custom Matlab code to generate the shape of the k-space trajectories, as well as
code published alongside the following paper for transforming trajectories into gradients, given the slew rate and amplitude 
constraints specified for the gradient system.

Lustig, M., Kim, S.-J., Pauly, J.M., 2008. 
A Fast Method for Designing Time-Optimal Gradient Waveforms for Arbitrary 
k-Space Trajectories. 
IEEE Transactions on Medical Imaging 27, 866–873. 
https://doi.org/10.1109/TMI.2008.922699


1. Create the trajectories via `uhfbold_create_epi_spiral_trajectories`. 
    - `idSubject` will change the folder where resulting waveforms and figures are saved, 
      and also change chosen gradient specs within the file
    - Per default the relevant trajectory parameters are generated in this file as parameter grids, 
      but if you want to try only a few individual trajectories, set
      `doUseGradientFile = true` and edit the `index_gradient_files_uhfbold.m` parameter file 
        - (`idSubject` has to match the suffix (`uhfbold`) of that file then)
2. Plot the trajectories with `uhfbold_plot_created_trajectories`
    - Note that `idSubject` has to match the one from the creation again
    - if `doSavePlot = true`, the generated plots are saved to file (`.png`) and closed after saving.
      Otherwise, the Matlab figure window remains open.
3. Plot the comparison in acquisition duration between epis/spirals with different acceleration on different gradient systems
    - Before plotting, you will have to manually save output data from the previous steps via
      ```
        save('acqDurationEPISpiral_msArray', 'acqDuration_msArray', ...
        'maxGArray', 'maxSrArray', 'rPArray', 'dxMArray', 'iEpiTrajArray', ...
        'iSpiralTrajArray', 'GmaxArray', 'SRmaxArray', 'resArray')
     ```
    - Then, run `uhfbold_plot_acq_duration_epi_spiral`
