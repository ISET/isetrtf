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
p.addParameter('scalefactors',@isnumeric);
p.addParameter('resolution',1000,@isnumeric);
p.addParameter('degrees',@isnumeric)
p.addParameter('distances',@isnumeric) % Distances to chart measuerd from lens object side vertex
p.parse(varargin{:});



filmdiagonal_mm = p.Results.filmdiagonal;
filmdistance_mm= p.Results.filmdistance;
rtfName = p.Results.rtfname;
degrees= p.Results.degrees;
scaleFactors= p.Results.scalefactors;
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
        thisR=piRecipeDefault('scene name','flatsurface');
        
        % Add chart at depth
        positionXY = [0 0];% Center
        scaleFactor=scaleFactors(i);
        piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(i),positionXY,scaleFactor);
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
        %oiWindow(oi)
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



function thisR = piChartAddatDistanceFromFilm(thisR,distanceFromFilm,positionXY,scalefactor)

 %% Place a SLantedBarChart at specified Distance and position in the scene
% INPUTS
% thisR - piRecipe object of the scene
% distanceFromFilm - distance from the pbrt film to the plane of the chart

% Position XY: on the object plane

% Set scale factor if not given
    if nargin < 4
    scalefactor=  1;
  end
 
  
% Film position might not be at origin,
% We assume optical axis on z axis
% We force the camera direction along the z direction
thisR.lookAt.from= [0 0 0];
thisR.lookAt.to = thisR.lookAt.from+[0 0 1];
filmZPosition=thisR.lookAt.from(3); 

% Load slantedbar asset
sbar = piAssetLoad('slantedbar');

% Merge with given recipe
thisR=piRecipeMerge(thisR,sbar.thisR,'node name',sbar.mergeNode);

% Set scale to same as world coordinate system
initialScale=sbar.thisR.assets.Node{3}.scale{1};

% PATCH: Adding the same asset multiple times makes mergenode na,me
% nonunique. Although when adding a prefix is added, we do not have that
% prefix
%To implement ( from zheng) [~, newName] = piObjectInstanceCreate(thisR, 'colorChecker_B');

findIDWithPostfix=piAssetFind(thisR,'name','slantedbar-6680_G');
lastID=findIDWithPostfix(end); % latest is the one we added
newName=thisR.assets.Node{lastID}.name;


% The scaling will affact translastions, so we first undo the scaling,
% translate and reapply another scaling;
thisR.set('node', newName, 'scale', 1./initialScale);  % Undo initial scaling
thisR.set('node', newName, 'world position', [positionXY distanceFromFilm+filmZPosition]);  %  Translate to desired position
newScale=[0.2*initialScale(1:3)]*scalefactor  *distanceFromFilm/(2-filmZPosition); % This makes sure the size of the image remains approx identical whenplaced at different depths .
thisR.set('node', newName, 'scale', newScale);  % Rescale as desired

end


end

