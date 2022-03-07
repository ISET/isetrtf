function [esf,pixels_micron,renderNoiseFloor] = calculateESF(varargin)
%% GenerateESF  - Generate a matrix of ESF functions  for a given RTF file
% INPUTS
%    rtfname - the prefix name of the rtf
%    rays - numbers of rays to trace per pixel
%    filmdiagional - size  in mm of diagonal (equals film width because there is only one row) 
%    filmdistance - distance of sensor (film in pbrt) to the first lens
%                   vertex on image side.
%    resolution - Number pixels on a single row
%    degrees -[1xD] vector containing the desired rtf polynomial degrees to
%               simulate
%    distances - [1xN] Distances of the object plane (in mm) measured from front
%                 lens vertex
%    scalefactors - [1xD] Factor to scale the slanted bar chart with. It
%                   should not be too large, because the slanted bar has finite resolution
%     which will change the ESF. It should also not be too small so that ESF
%    is wider thatn the chart . The numbers were emperically chosen for now
%    for each lens.
%
%
%  OUTPUTS
%    [esf,pixels_micron,renderNoiseFloor]  
%    esf - P x D x N   Matrix conting edge spread functions (D: degrees, N:
%    Distances)
%    pixels_micron - 1xP vector with x-values to plot the ESF
%    renderNoiseFloor - RMS value estimate of the rendering noise floor
%                       This is relevant in error analysis when comparing
%                       to zmeax. The RMSE cannot become significantly smaller than this
%                       number.
%
%
%  Note To future users: This has been hardcoded for a specific file name
%  convention. You may want to edit this.
%  In hindsight, I think it would have been better to pass an actual
%  filepath to this function and  hence externalize the filename
%  convention and need to supply polynomial degrees
%
% Thomas Goossens
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('rtfname', @ischar);
p.addParameter('rays',2000, @isnumeric);
p.addParameter('filmdiagonal', @isnumeric);
p.addParameter('filmdistance',@isnumeric);
p.addParameter('resolution',1000,@isnumeric);
p.addParameter('degrees',@isnumeric)
p.addParameter('distances',@isnumeric) % Distances to chart measuerd from lens object side vertex
p.parse(varargin{:});



filmdiagonal_mm = p.Results.filmdiagonal;
filmdistance_mm= p.Results.filmdistance;
rtfName = p.Results.rtfname;
degrees= p.Results.degrees;
distancesFromLens_mm = p.Results.distances; % mm to meter
nbRaysPerPixel=p.Results.rays;
resolution=p.Results.resolution;
%%  Setup distances from film
rtf=jsonread([rtfName '-poly' num2str(degrees(1)) '-raytransfer.json']);
lensThickness_mm = rtf.thickness;

% Positions of chart as measured from the film
distancesFromFilm_meter =1e-3* ( (filmdistance_mm+lensThickness_mm)+distancesFromLens_mm);



%% Create A camera for each polynomial degree
cameras={};


for degree=degrees
    lensname=[rtfName '-poly' num2str(degree) '-raytransfer']
    cameraRTF = piCameraCreate('raytransfer','lensfile',[lensname '.json']);
    cameraRTF.filmdistance.type='float';
    cameraRTF.filmdistance.value=(filmdistance_mm)/1000;
    cameras{end+1} = cameraRTF;
end


%% Loop over different chart distances, as measured from film
for c=1:numel(cameras)
    for i=1:numel(distancesFromFilm_meter)
        disp(['Render Camera ' num2str(c) ' position ' num2str(i)])
        
        % Build the scene
        thisR=piRecipeDefault('scene name','stepfunction');
        
        % Control Distance to Step Funtion Chart
         setChartDistance(thisR,distancesFromFilm_meter(i));
        %
        thisR.set('camera',cameras{c});
        thisR.set('spatial resolution',[resolution 1]);
        thisR.set('rays per pixel',nbRaysPerPixel);
        thisR.set('film diagonal',filmdiagonal_mm); % Original
        
        
        % Write and render
        piWrite(thisR);
        [oi log] = piRender(thisR,'render type','radiance','dockerimagename','vistalab/pbrt-v3-spectral:latest');
        oi.name=['Chart distance from film: ' num2str(distancesFromFilm_meter(i))]
        oiList{c,i}=oi;
        
    end
    
end

%% Determine Render noise floor
disp(['Estimate Render Noise Floor'])

% Build the scene with white diffuse flat surface
thisR=piRecipeDefault('scene name','flatsurface');


% Set identical camera setup
thisR.set('camera',cameras{end});
thisR.set('spatial resolution',[resolution 1]);
thisR.set('rays per pixel',nbRaysPerPixel);
thisR.set('film diagonal',filmdiagonal_mm); % Original



% Write and render
piWrite(thisR);
[oi log] = piRender(thisR,'render type','radiance');

% Estimate noise for a patch around the center
edgePBRT=double(oi.data.photons(end,end/2-200:end/2+200,1)); % Take horizontal line in center
edgePBRT=edgePBRT/mean(edgePBRT);
renderNoiseFloor=rms(1-edgePBRT);


%% Generate ESF matrix
clear esf
filmWidth=oiGet(oi,'width','mm');
pixels_micron = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
smooth = @(x)conv(x,[1 1 1 1 1]/5,'same' )
for i=1:numel(distancesFromFilm_meter)
    for d=1:(size(oiList,1))
        oi=oiList{d,i} ;   edgePBRT=oi.data.photons(end,:,1); % Take horizontal line in center
        esf(:,d,i)=edgePBRT/max(smooth(edgePBRT));

    end
end


%%
% The distance to the stepfunction chart, positioned at the xy-plane at z=0, is controlled by changing the distance of the
% camera. 
function thisR = setChartDistance(thisR,distanceFromFilm)
    thisR.lookAt.from= [0 0 -distanceFromFilm];
    thisR.lookAt.to= [0 0 1] ;
    thisR.lookAt.up=[ 0 1 0];
end





% 
% %% Add A step function using an area light in PBRT
% % I did not find how to make a square light source so I made a very large circular
% % light source offset by its radius. This approximates a step function on
% % the horizontal line.
%  function thisR = addLightSourceEdge(thisR,distanceFromFilm)
%      % Orient the camera the way I want it, making it easy for me   
%      thisR.lookAt.from= [0 0 0];        thisR.lookAt.to= [0 0 1] ;
%         piLightDelete(thisR,1) % delete all other light sources in the scene
%         
%         
%         radius=1e4; % Choose a large radius for the circle
%         
%         % Create offset circle area light
%         light=piLightDiskCreate('position',[-radius 0 distanceFromFilm],'radius',radius)
%         
%         % Add light to recipe
%         thisR=piAddLights(thisR,{light})
%         
% 
%  end



% function pointsource = piLightDiskCreate(varargin)
% % Create a diffuse Area source in the shape of disk
% % By default the normal vector on the disk is pointing in the z-direction
% 
% p = inputParser;
% p.addParameter('position', @isnumeric);
% p.addParameter('radius', @isnumeric)
% p.parse(varargin{:});
% 
% position_meters= p.Results.position;
% radius_meters= p.Results.radius;
% 
% pointsource =  piLightCreate('diffuse disk source',...
%     'type','area');
%     
% pointsource.translation.value = {[position_meters]};
% shape.radius=radius_meters;
% shape.meshshape='disk';
% pointsource.shape.value=shape;
% 
% end




end

