
%% Pixel 4 Front camera PBRT test
clear
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


thisR=piRecipeDefault('scene','ChessSet')


thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';


%% Set camera position


%filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
%distanceFromFilm_m=1.469+50/1000\

% Set camera and camera position
%filmZPos_m           = -0.9;
%thisR.lookAt.from(3)= filmZPos_m;





%% FIlm distance as provided by Google


%load('p4aLensVignetFrontCam_p0286s.mat')


filmdistance_mm=57.315
sensordiagonal_mm=150;


%% Add a lens and render.


%cameras{1} = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');
cameras={};
for degree=[6]
    label{degree}=['dgauss28deg-polydeg' num2str(degree)]
    filename=['dgauss28deg-zemax-poly' num2str(degree) '-raytransfer.json']
    cameras{end+1} = piCameraCreate('raytransfer','lensfile',filename);
end

% Linear
%label{2}='linear'
%cameras{2} = piCameraCreate('raytransfer','lensfile','pixel4a_linear-frontcamera-filmtoscene-raytransfer.json')



for c=1:numel(cameras)
    
    cameraRTF = cameras{c};
    cameraRTF.filmdistance.value=filmdistance_mm/1000;
    
    thisR.set('pixel samples',320);
    thisR.set('film diagonal',sensordiagonal_mm,'mm');
    thisR.set('film resolution',[300 300]);
    
    
    thisR.integrator.subtype='path';
    
    thisR.integrator.numCABands.type = 'integer';
    thisR.integrator.numCABands.value =1;
    
    
    
    % Render
    
    % % RTF
    thisR.set('camera',cameraRTF);
    piWrite(thisR);
    
    
    %
    
    [oiTemp,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);
    oiTemp.name=label{c};
    oi{c} =oiTemp;
    
    
    oiWindow(oiTemp)
    pause(2)
    %exportgraphics(gca,['./fig/chesset_pixel4a' label{c} '.png'])
  %  exportgraphics(gca,['./fig/chesset_pixel4arear_quick' label{c} '.png'])
end
%% Make figures
