## Introduction
This code is made to calculate the overlap between actin and clathrin-coated pits, acquired by super-resolution data. The demo data included is the data used in the paper.

### How to run on your own data?
It was specifically written for our analysis pipeline (as in: the data structure is specific for our pipeline), but can easily be changed to fit your analysis pipeline. 
The core of the calculations (i.e., the overlap calculation) will be the same for every analysis pipeline, but the way the dat ais ordered may be different depending on your own pipeline.
Please structure your own data so that it is conform to the scripts written here, or change any lines that are specific to our pipeline (e.g., l105 - 109 in 'OverlapCalculation.m') to fit your data.

## System requirements
The files were tested in MATLAB R2021b (The MathWorks, USA), on a i7-12700H 2.30 GHz (32 GB RAM) laptop running Windows 64-bit. No errors were encountered (only some warnings sometimes related to the polyshape function of MATLAB, but these can safely be ignored).
The code was not tested in another version of MATLAB, but should be working in any version of MATLAB where the polyshape.m function exists (i.e., MATLAB R2017b or newer).
We also included the data set that was used in the paper as a demo code.

## Installation and run guide
To Run:
  - Download the full folder to your computer.
  - Add the full folder to your MATLAB path 
  ```
  Option 1: Navigate to the folder through the 'Current Folder' menu and right click -> Add To Path -> Selected Folders and Subfolders
  Option 2: Home tab in MATLAB -> Environment group: Set Path -> Add with Subfolders -> Select the folder in the input dialog -> Save -> Close
  ```
  - Run the 'ToRun.m' file
  ```
  In the Command Window, type: ToRun.m
  ```
 
 A typical "installation" should not take you longer than a minute, and the run time on a i7-12700H 2.30 GHz (32 GB RAM) laptop with Windows 64-bit is ~2 minutes.
 
 The output will be:
  - An Excel file with the entire summary of the output. An explanation of the output can be found in the 'OverlapCalculation.m' file.
  - Two MATLAB figures that will also be saved as .png files in the working directory.

## Other
For more information, please refer to: Yang C, Colosi P, Hugelier S, Zabezhinsky D, Lakadamyali M & Svitkina T. Actin polymerization promotes invagination of flat clathrin-coated lattices in mammalian cells by pushing at the lattice edges. Nat. Comm. 2022.
