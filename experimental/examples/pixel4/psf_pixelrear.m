%% Plot relative illumination DGAUSS 50mm lens compare Omni with RTF

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

thisR=piRecipeDefault('scenename','flatsurface')
%% Set camera position


filmdistance_mm=0.464135918;
pixelpitch_mm=1.4e-3; 
sensordiagonal_mm=3.5;
lensThickness=4.827;

filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
distanceFromFilm_m=1.469+50/1000


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';




%% Filmdistance and 
% Positions of chart as measured from the film


distancesFromFilm_meter = [2 4 5 6 7 10]
distancesFromFrontSurface_meter = [distancesFromFilm_meter]-(filmdistance_mm+lensThickness)/1000;


  %% Creat camera camera
    
cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');

cameraRTF.filmdistance.value=filmdistance_mm/1000;
%% Lights

  %% Creat camera camera
    
cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');

cameraRTF.filmdistance.value=filmdistance_mm/1000;
%% Lights
radius_mm = 0.02;

%% Loop over different chart distances, as measured from film

for i=1:numel(distancesFromFilm_meter)

    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
  
    
    % Set camera and camera position and direction. Pointing along z axis.
    thisR.lookAt.from=[0 0 0];
    thisR.lookAt.to = thisR.lookAt.from+[0 0 1];
    filmZPosition=thisR.lookAt.from(3); 

    % Add light

    thisR     = piLightDelete(thisR, 'all');
    lightGrid = piLightDiskGridCreate('depth',distancesFromFilm_meter(i),'center', [0 0],'grid',[1 1],'spacing',0.01,'diskradius',radius_mm/1000);
    piAddLights(thisR,lightGrid)
    
        
    
    
    thisR.set('camera',cameraRTF);
    thisR.set('spatial resolution',[1000 500]);
    thisR.set('rays per pixel',50000);
    thisR.set('film diagonal',0.015*sqrt(2)); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi,log] = piRender(thisR,'render type','radiance');
    oi.name=['Chart distance from front: ' num2str(distancesFromFrontSurface_meter(i))]
    oiList{i}=oi;
    oiWindow(oi)
end




%%
save(['/scratch/thomas42/psf/pixel4a-rear-radius' num2str(radius_mm) '.mat']);



%%
load(['/scratch/thomas42/psf/pixel4a-rear-radius' num2str(radius_mm) '.mat']);



%% Compare edge smoothing at different depths
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))

figure(5);clf; hold on
for i=1
   oi=oiList{i} ;
   edge=mean(oi.data.photons(end/2-10:end/2+10,:,1),1); % Take horizontal line in center
   plot(1e3*pixels,edge,'color',color(25*i,:))
   labels{i}=[num2str(distancesFromFrontSurface_meter(i)) ' m'];
   xlabel('micron')
   xlim(1e3*pixels([1 end])/2)
end
legend(labels)
%% Linespread

color=hot;
filmWidth=oiGet(oi,'width','mm');
filmHeight=oiGet(oi,'height','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
pixelsRows = 1e3*linspace(-filmHeight/2,filmHeight/2,oiGet(oi,'rows'))

figure(4);clf; hold on
%for i=1:numel(distancesFromFrontSurface_meter)
for i=1
   oi=oiList{i} ;
   edgeCols=sum(oi.data.photons(:,:,1),1); % Take horizontal line in center
   edgeRows=sum(oi.data.photons(:,:,1),2); % Take horizontal line in center
   plot(pixels,edgeCols,'color',color(25*i,:))
   plot(pixelsRows,edgeRows,'color','b')
   labels{i}=[num2str(distancesFromFrontSurface_meter(i)) ' m'];
   xlabel('micron')
   xlim(pixels([1 end]))
end
legend(labels)
title('Linespread')

