% Exampel script of checking whether a ray would pass through the system
% using only the pupils.


%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.3.0mm.json');
exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)



%% Modifcation of lens parameters if desired
diaphragm_diameter=0.6;
lens.surfaceArray(6).apertureD=diaphragm_diameter
lens.apertureMiddleD=diaphragm_diameter


%% Calculate pupils

[pupil_positions,pupil_radii]=lensGetEntrancePupils(lens);


%% Check if a ray would pass
th=0;
origin=[0 ;0 ;-2];
dir= [0; sind(th) ;cosd(th)];
pass=checkRayPassLens(origin,direction,pupil_positions,pupil_radii)

