# ISETRTF: Using ray transfer functions for camera simulation in PBRT with unknown lens designs


Repository for software to support the analyses in the paper on ray transfer functions
<div>
<img src="./paper/fig/drawings/rtf-matrix.pdf-1.png" alt="RTF" width="30%" >
<img src="./paper/fig/drawings/rtf-function.pdf-1.png" alt="RTF" width="30%" >
<img src="./paper/fig/drawings/rtf-surface.pdf-1.png" alt="RTF" width="30%" >
</div>



# Requirements to run

## Dependencies
1) *ISET cam:* https://github.com/ISET/isetcam
2) *ISET Lens:*  https://github.com/ISET/isetlens
3) *ISET 3D:*  https://github.com/ISET/iset3d-v3
4) *JSONio*: https://github.com/gllmflndn/JSONio

## Unpack ZIP files 
In the directory 'paper/data/zemaxratrace/' unzip the archive file to obtain the datasets produces by the zemax macro.
This is required before running ''generateRTFfromzemax.m'

# Example
An example is given in the examples folder.
The general use of the software is
1. Generate a ray dataset using the zemax macro (see paper/zemax/zemaxMacroRTF.ZPL)

2. Generate a RTF Json file using the fitting scripts 

3. Render a scene in PBRT using the RTF camera 

# Publication
T. Goossens, Z. Lyu, J. Ko, G. Wan, J. Farrell, B. Wandell, *Ray-transfer functions for camera simulation of 3D scenes with hidden lens design*, https://arxiv.org/abs/2202.08880

# RTF in PBRT Compared to tracing Through Lens
<div>
<img src="./paper/fig/drawings/chessSet-dgauss28deg-Omni.png" alt="RTF" width="49%" >
<img src="./paper/fig/drawings/chessSet-dgauss28deg-RTF.png" alt="RTF" width="49%" >
<img src="./paper/fig/drawings/chessSet-hline-dgauss28deg.png" alt="RTF" width="100%" >
</div>


