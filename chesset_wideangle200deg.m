%% CHEESSET For wide angle lens OMNI VS RTF



%% ATTENTION README
% I manually added  0.2mm to the filmdistannce of the omni ( see below).
% THis is because the RTF was estmate with an additional thickness of0.2
% (air) added on the sensor side.

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

thisR=piRecipeDefault('scenename','chess set')
%% Set camera position

filmdistance_mm=2.003+0.001; 
sensordiagonal_mm=3;
%filmZPos_m=-0.6;filmdistance_mm=80; thisR.lookAt.from(3)=filmZPos_m;


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



%% Light should be add infinitey to avoid additional vignetting nintrouced
% by light falloff
light =  piLightCreate('distant','type','distant')

% thisR     = piLightDelete(thisR, 'all');
%thisR.set('light', 'add', light);



% Set camera and camera position
filmZPos_m           = -0.3;
thisR.lookAt.from(3)= filmZPos_m

%% Loop ver Different aperture sizes





a=1
% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','wideangle200deg-automatic-zemax.json');
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=(filmdistance_mm+0.2)*1e-3;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=2*0.620000005;
cameraOmni.aperturediameter.type='float';
%cameraOmni = rmfield(cameraOmni,'aperturediameter');



rtffile=['wideangle200deg-circle-zemax-poly8-raytransfer.json'];
cameraRTF = piCameraCreate('raytransfer','lensfile',rtffile);
%cameraRTF = piCameraCreate('raytransfer','lensfile','/home/thomas42/Documents/MATLAB/libs/isetlens/local/dgauss.22deg.50.0mm_aperture6.0.json-raytransfer.json')
cameraRTF.filmdistance.value=filmdistance_mm*1e-3;
%cameraRTF.aperturediameter.value=aperturediameters(a);
%cameraRTF.aperturediameter.type='float';
thisR.set('pixel samples',100)



thisR.set('film diagonal',sensordiagonal_mm,'mm');
resolution=900;
thisR.set('film resolution',resolution*[1 1])
    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1


% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
%chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar
% Omni
disp('---------Render Omni----------')
thisR.set('camera',cameraOmni);
[oi,resultsOmni] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['Omni']
oiOmni{a}=oi;


% RTF
disp('---------Render RTF-----------')
thisR.set('camera',cameraRTF);
[oi,resultsRTF] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['RTF']
oiRTF{a}=oi;



oiList = {oiOmni,oiRTF};




%% Generate images
for i=1:numel(oiList)
    oi=oiList{i}{1};
    oiWindow(oi);
    exportgraphics(gca,['./fig/chessSet-wideangle200deg-' oi.name '.png'])
end


%% Compare
return

%% diff image
data=oiOmni{1}.data;
data.photons=(oiOmni{1}.data.photons-oiRTF{1}.data.photons);
data.illuminance=(oiOmni{1}.data.illuminance-oiRTF{1}.data.illuminance);

oiDiff = oiSet(oiOmni{1},'data',data)
oiWindow(oiOmni{1})
