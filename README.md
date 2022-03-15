[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6359855.svg)](https://doi.org/10.5281/zenodo.6359855)

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
1. You will have to update the paths in `uhfbold_get_paths` to your system environment. 
2. Not all code folders are needed (e.g., `recon`), best try out 
3. For saving the plots you need the [export_fig]() package by Yair Altman 
4. At the beginning of a new Matlab session with this code, setup the paths via
```
uhfbold_setup_paths`   
```

### BOLD sensitivity (Fig. 24.4.1)
This should run out of the box, if you followed the instruction in General.

1. Run `uhfbold_plot_bold_sensitivity` in the Matlab command window

### Sequence Diagram Cartoon (Fig. 24.4.2)
This generates gradient waveform and 2D trajectory figures for a Cartoon spiral and EPI (only a few k-space windings/lines), the latter is used in panel B of Fig. 24.4.2.

1. In `uhfbold_create_epi_spiral_trajectories`, uncomment the code cell subscribed `%% For Gradient timecourse plots`
uhfbold_plot_epi_spiral_sequence
    - You will need the folder `nominalTrajectory` to generate the spiral and EPI trajectories, ask Lars whether you can obtain it.
2. If you have the created gradient text files, plot them via `uhfbold_plot_epi_spiral_sequence`.


### SNR Comparison 2D vs 3D vs SMS (Fig. 24.4.3)
This should run out of the box, if you followed the instruction in General.

1. Run `uhfbold_plot_snr_2Dvs3DvsSMS` in the Matlab command window

### Acquisition Efficiency: 2D spiral/EPIs (Fig. 24.4.3)
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


### Acquisition Efficiency Table (Literature Review) (Fig. 24.4.4)
- This is not actually code but an excel table `Table24.5.1_AcquisitionEfficiency.xlsx` you may change to your liking, include your favorite sequence etc.
- It contains data extracted from several papers on matrix size, resolution, TR etc. to compute Acquisition efficiency (resolved voxels per unit time) for the listed publications.
- There are two sheets in the Table, the first one contains only contains the papers that made it into the figure (best-in-class for the different introduced acquisition types.
- The second sheet contains many more papers that I surveyed during the literature search for this chapter. Maybe your favorite sequence is already in there.
- If you add a row with your favorite publication, the plot should automatically update (otherwise click on the bar plot and adapt the highlighted data range (cells) of the table)
