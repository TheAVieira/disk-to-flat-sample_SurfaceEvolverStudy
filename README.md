## Introduction
This repository showcases the use of Surface Evolver (supported by MATLAB) for estimating the contact angle along irregularly shaped contact line (CL) of droplets in contact with a surface. More specifically, the droplet is attached to a drop-holding disk (top) while in contact with a flat surface. The examples cover the hydrophobic case, but philic regime would also be possible, provided the droplet is attached to a disk uptop and the shape of the CL is known. 

For reference, The shape of the CL is typically measured from real-world experiments, e.g. observed through the droplet with a top-view microscope as illustrated in [1].

All MATLAB and Surface Evolver functions are located in the /library folder.

## Requirements
- MATLAB R2020a.
- [Surface Evolver 2.70](https://kenbrakke.com/evolver/evolver.html)
- ffmpeg (v5.0.1) - Used to compress videos with minimal loss.

## Examples

- **Example 1 - Flat field correction** - This example showcases how through-drop top-view video of a droplet sliding experiment can be corrected with a flat-field reference image.

- **Example 2 - Frame to CL** - This example shows how the CL can be obtained on top-view frames of a droplet sliding video using machine vision.

- **Example 3 - CL to Surface Evolver** - This example uses a MATLAB script to automatically create a Surface Evolver script (*.fe). Surface evolver simuations start with a set of xyz point cordinates that define the initial state of a mesh representing the water-air interface of the droplet. MATLAB is used to automate this process of calculating the mesh points, vertices, and facets. The Surface Evolver recipes used to calculate the shape of the droplet can be found in DiskToSampleCommands.se, within the example folder.

## Concept

A millimiter sized droplet is attached to an undercut disk. The droplet is brought into contact with a surface, as shown in Figure 1 below. The CL is the perimeter of the interface between the droplet and the surface, which is taken as boundary condition to the shape of the water-air interface. The top circular boundary of the disk defines another boundary condition.
Together with the shape of the CL, the final shape of the droplet is defined by:

- rd - radius of the droplet holding disk.
- h - height of the droplet.
- V - volume of the droplet.

![Alt text](Droplet_Anotated.png "Optional title")

Figure 1 - Concept illustration of a droplet attached between a disk and a flat hydrophobic surface.




## References
[1] - Vieira et. al, _Through-drop imaging of moving contact lines and contact areas on opaque water-repellent surfaces_, Soft Matter, 2023,19, 2350-2359
