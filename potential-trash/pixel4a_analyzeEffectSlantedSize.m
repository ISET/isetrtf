

%% Script with charts at different depths 
% This script is written as part of a class project on autofocus  psych221
% For Itamar
%
% The aim is to generate a scene with objects at controllable depths
% Supervised by Thomas Goossens

ieInit;



%% Filmdistance and 
%lens=lensC('file','tessar-zemax.json')
filmdistance_mm=0.49234 % mm

filmdiagonal_mm=7;

rtf=jsonread('/usr/local/scratch/thomas42/MATLAB/libs/iset3d/data/lens/RTF/pixel4a-rear/pixel4a-rearcamera-ellipse-raytransfer.json')
lensThickness=rtf.thickness;

% Positions of chart as measured from the film
distancesFromFilm_meter = (filmdistance_mm+lensThickness)/1000  + 0.5;
distancesFromFilm_meter = 0.2


%% Create the two cameras and choose a lens
lensname='pixel4a-rearcamera-ellipse-raytransfer'
cameraRTF = piCameraCreate('raytransfer','lensfile',[lensname '.json']);
cameraRTF.filmdistance.type='float';
cameraRTF.filmdistance.value=filmdistance_mm/1000;



cameras = {cameraRTF}; oiLabels = {'cameraRTF'};




%% Loop over different chart distances, as measured from film
scalefactors=[0.1 2 4]
for i=1:numel(scalefactors)

    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
    % Add chart at depth
    positionXY = [0 0];% Center
    scaleFactor=scalefactors(i); % adjust to your liking
    piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(1),positionXY,scaleFactor);
        
    thisR.set('camera',cameras{1});
    thisR.set('spatial resolution',[50000 1]);
    thisR.set('rays per pixel',200);
    thisR.set('film diagonal',filmdiagonal_mm); % Original
    
    
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


