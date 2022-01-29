% PSF fotn camrea with PBRT
clear
ieInit;


% FIlm distance as provided by Google


load('p4aLensVignetFrontCam_p0286s.mat')


filmdistance_mm=0.3616965582;
pixelpitch_mm=1.12e-3; 
sensorwidth_mm=pixelpitch_mm*size(pixel4aLensVignetFrontCamp0286s,2)
sensorheight_mm=pixelpitch_mm*size(pixel4aLensVignetFrontCamp0286s,1)
sensordiagonal_mm=sqrt(sensorwidth_mm^2+sensorheight_mm^2)


lensthickness_mm=3.2433;


%% Filmdistance and 
% Positions of chart as measured from the film


distancesFromFilm_meter = [10 15 1 1.5 2 3 4 5 6]
distancesFromFrontSurface_meter = [distancesFromFilm_meter]-(filmdistance_mm+lensthickness_mm)/1000;
%

%% Add a lens and render.

% Nonlinear
label{1}='RTF'
cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-frontcamera-filmtoscene-raytransfer.json');
cameraRTF.filmdistance.value=filmdistance_mm/1000;




%% Lights
radius_mm = 0.09;



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
    thisR.set('rays per pixel',1000);
    thisR.set('film diagonal',0.02*sqrt(2)); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi,log] = piRender(thisR,'render type','radiance');
    oi.name=['Chart distance from front: ' num2str(distancesFromFrontSurface_meter(i))]
    oiList{i}=oi;
    oiWindow(oi)
end




%%
save(['/scratch/thomas42/psf/pixel4-frontcamera-radius' num2str(radius_mm) '.mat']);



%%
load(['/scratch/thomas42/psf/pixel4-frontcamera-radius' num2str(radius_mm) '.mat']);
%% Compare edge smoothing at different depths
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))

figure(5);clf; hold on
for i=1:numel(distancesFromFrontSurface_meter)
   oi=oiList{i} ;
   edge=oi.data.photons(end/2,:,1); % Take horizontal line in center
   plot(1e3*pixels,edge,'color',color(25*i,:))
   labels{i}=[num2str(distancesFromFrontSurface_meter(i)) ' m'];
   xlabel('micron')
   xlim(1e3*pixels([1 end])/2)
end
legend(labels)
%% Linespread

color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))

figure(4);clf; hold on
%for i=1:numel(distancesFromFrontSurface_meter)
for i=3
   oi=oiList{i} ;
   edge=sum(oi.data.photons(:,:,1),1); % Take horizontal line in center
   plot(pixels,edge,'color',color(25*i,:))
   labels{i}=[num2str(distancesFromFrontSurface_meter(i)) ' m'];
   xlabel('micron')
   xlim(pixels([1 end]))
end
legend(labels)
title('Linespread')

