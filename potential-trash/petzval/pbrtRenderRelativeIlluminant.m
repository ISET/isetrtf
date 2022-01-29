%% Pixel 4 Front camera PBRT test
clear
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


%thisR=piRecipeDefault('scene','ChessSet')
thisR=piRecipeDefault('scene','flatSurface'); 

thisR.set('light','#1_Light_type:point','type','infinite')
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';


%% Set camera position


% Set camera and camera position
%thisR.lookAt.to(2)=250
%thisR.lookAt.from = thisR.lookAt.to -[ 0 -1 0];





%% FIlm distance as provided by Google


%load('p4aLensVignetFrontCam_p0286s.mat')


filmdistance_mm=20; 
sensordiagonal_mm=85;

%% Add a lens and render.


%cameras{1} = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');
cameras={};
for degree=[8]
    label{degree}=['petzval-polydeg' num2str(degree)]
    filename=['petzval-zemax-poly' num2str(degree) '-raytransfer.json']
    cameras{end+1} = piCameraCreate('raytransfer','lensfile',filename);
end

% Linear
%label{2}='linear'
%cameras{2} = piCameraCreate('raytransfer','lensfile','pixel4a_linear-frontcamera-filmtoscene-raytransfer.json')

  

for c=1:numel(cameras)
    
    cameraRTF = cameras{c};
    cameraRTF.filmdistance.value=filmdistance_mm/1000;
    
    thisR.set('pixel samples',350);
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

load relativeillum-zemax-forward.mat
maxnorm= @(x)x/max(x)
figure; hold on    
relativeIllumPBRT=maxnorm(oiTemp.data.photons(end/2,:,1))
%construct x axis
resolution=thisR.get('film resolution');resolution=resolution(2);
filmdiagonal=thisR.get('filmdiagonal')
xaxis=0.5*filmdiagonal/sqrt(2) *linspace(-1,1,resolution);

relativeIllum.lens= 'petzval'
relativeIllum.pbrt.x=xaxis;
relativeIllum.pbrt.y=maxnorm(medfilt1(relativeIllumPBRT,10));
relativeIllum.zemax.x=relativeillum(:,1);
relativeIllum.zemax.y=maxnorm(relativeillum(:,2));
save('relativeillum-comparison.mat','relativeIllum')

hpbrt=plot(xaxis,relativeIllum.pbrt.y,'k')
hzemax=plot(relativeillum(:,1),maxnorm(relativeillum(:,2)),'r')

% Reverse
load relativeillum-zemax.mat
hzemax=plot(relativeillum(:,1),maxnorm(relativeillum(:,2)),'b')

