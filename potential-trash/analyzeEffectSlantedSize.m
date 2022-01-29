
%% Script with charts at different depths 
% This script is written as part of a class project on autofocus  psych221
% For Itamar
%
% The aim is to generate a scene with objects at controllable depths
% Supervised by Thomas Goossens

ieInit;



%% Filmdistance and 
lens=lensC('file','tessar-zemax.json')
filmdistance_mm=100 % mm

% Positions of chart as measured from the film
distancesFromFilm_meter = (100+16.4)/1000+[2 1.267384 1.8 2 3  ]
distancesFromFilm_meter = (100+16.4)/1000+[2 1.267384 3 4 1.5]
distancesFromFilm_meter = (100+16.4)/1000+[1.267384]


%% Create the two cameras and choose a lens
lensname='tessar-zemax'
cameraOmni = piCameraCreate('omni','lensfile',[lensname '.json']);
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm/1000;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=2*8.111;
%cameraOmni.aperturediameter.value=8.111;

cameras = {cameraOmni}; oiLabels = {'cameraOmni'};




%% Loop over different chart distances, as measured from film
scalefactors=[0.1 0.25 0.5 1 1.5 2 4]
for i=1:numel(scalefactors)

    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
    % Add chart at depth
    positionXY = [0 0];% Center
    scaleFactor=scalefactors(i); % adjust to your liking
    piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(1),positionXY,scaleFactor);
        
    thisR.set('camera',cameras{1});
    thisR.set('spatial resolution',[50000 1]);
    thisR.set('rays per pixel',400);
    thisR.set('film diagonal',50.5); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi log] = piRender(thisR,'render type','radiance');
    oi.name=['Chart distance from film: ' num2str(distancesFromFilm_meter)]
    oiList{i}=oi;
    oiWindow(oi)
end


%% Compare edge smoothing at different depths

pause(1)
load lsf.mat
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
smooth = @(x)conv(x,[1 1 1 1 1]/5,'same' )
figure(5);clf; hold on
for i=1:numel(scalefactors)
    

    oi=oiList{i} ;   edge=oi.data.photons(end,:,1); % Take horizontal line in center
   plot(pixels,edge/max(smooth(edge)),'color',color(15*i,:))
   
   
   % ESF zemax
   xlim([-500 500])

end


