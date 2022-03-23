%% Pixel 4 Front camera PBRT test
% 2022 Thomas Goossens

clear
ieInit
if ~piDockerExists, piDockerConfig; end

%% Load PBRT recipe of the chess set scene
thisR=piRecipeDefault('scene','ChessSet')
thisDocker = 'vistalab/pbrt-v3-spectral:latest';


%% Set camera position
% Set camera and camera position
filmZPos_m           = -0.9;
thisR.lookAt.from(3)= filmZPos_m;


%% Make an example rendered scene with the RTF lens of the pixel4a rear camera

filmdistance_mm=0.464135918+0.01;
pixelpitch_mm=1.4e-3;
sensordiagonal_mm=3.5;

%% Render chessset scene with the ray transfer function

% RTF camera 
% The lens file is taken from the local folder
lensfile=fullfile(irtfRootPath,'examples','pixel4a','pixel4a-rearcamera-ellipse','pixel4a-rearcamera-ellipse-poly5-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile',lensfile)
cameraRTF.filmdistance.value=filmdistance_mm/1000;

thisR.set('pixel samples',100); % Number of rays per pixel (Increase to reduce rendering noise)
thisR.set('film diagonal',sensordiagonal_mm/2,'mm');
thisR.set('film resolution',[300 300])

% Path integrated, only simulate for one wavelength
thisR.integrator.subtype='path'
thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value =1

% Write PBRT File
thisR.set('camera',cameraRTF);
piWrite(thisR);

% Render PBRT file
[oi,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);

% Show end result
% increase pixel samples to reduce rendering noise
oiWindow(oi)
    
