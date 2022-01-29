%% Plot relative illumination DGAUSS 50mm lens compare Omni with RTF

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

thisR=piRecipeDefault('scenename','flatsurface')
%thisR=piRecipeDefault('scenename','chess set')


%% Set camera position


filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
distanceFromFilm_m=1.469+50/1000


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



%% Light should be add infinitey to avoid additional vignetting nintrouced
% by light falloff
light =  piLightCreate('distant','type','distant')

 thisR     = piLightDelete(thisR, 'all');
thisR.set('light', 'add', light);



%% Load vignetting measurement
load p4aRearLensVignet.mat
%% Loop ver Different aperture sizes


filmdistance_mm=0.464135918+0.001;
pixelpitch_mm=1.4e-3; 
sensordiagonal_mm=2*3.5;
lensThickness=4.827;

%cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-ellipse-raytransfer.json');
%cameraRTF = piCameraCreate('raytransfer','lensfile','/home/thomas42/Documents/MATLAB/libs/isetlens/local/dgauss.22deg.50.0mm_aperture6.0.json-raytransfer.json')
cameraRTF.filmdistance.value=filmdistance_mm/1000;
    

thisR.set('pixel samples',500);
thisR.set('film diagonal',sensordiagonal_mm,'mm');
 aspectratio = size(pixel4aLensVignetSlope,2)/size(pixel4aLensVignetSlope,1);
 filmresolution_vertical=100;
 filmresolution_horizontal=round(filmresolution_vertical*aspectratio);
thisR.set('film resolution',[filmresolution_horizontal filmresolution_vertical]);

    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value =1



% RTF
disp('---------Render RTF-----------')
thisR.set('camera',cameraRTF);
[oi,resultsRTF] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oiRTF=oi;
close all


%% Plot relative illuminations
cmap = hot;
s=size(cmap,1);
color{2,1}=cmap(round(0.3*s),:);
color{2,2}=cmap(round(0.45*s),:);
color{2,3}=cmap(round(0.5*s),:);
color{2,4}=cmap(round(0.6*s),:);
color{2,5}=cmap(round(0.66*s),:);
color{1,1}='k';
color{1,2}='k';
color{1,3}='k';
color{1,4}='k';
color{1,5}='k';

%load('oiRelativeIllumination.mat')
colors={'k',[0.9 0 0.1]};
clear mtf relativeIllum;
fig=figure(3);clf;hold on;
fig.Position=[554 437 781 280];
maxnorm = @(x)x/max(x);


%construct x axis
filmdiagonal=thisR.get('filmdiagonal');
ss = oiGet(oi,'sample spacing','mm');
xaxis=0.5*oiGet(oi,'width','mm')*linspace(-1,1,filmresolution_horizontal);

linestyle={'-' ,'-.'};
% Plot relative illuminations

relativeIllum=maxnorm(oi.data.photons(end/2,:,1));
hold on;             
h=plot(xaxis,relativeIllum,'color',color{1,1},'linewidth',2,'linestyle',linestyle{1});
%x=2.731905465288036;
%plot(xaxis,cosd(atand(xaxis/x)).^4,'r--')

% Measured vignetting
x=(1:size(pixel4aLensVignetSlope,2)); x=x-x(end/2); x=x*pixelpitch_mm;
hold on; plot(x,pixel4aLensVignetSlope(end/2,:),'b-')


xlabel('Image height (mm)');
title('Relative illumination');
legend('Simulated','measured')

