clear; close all;


%% Lens name and propertievs
lensName = 'dgauss.22deg.50.0mm_aperture6.0';
lensFileName= [lensName, '.json'];
lens=lensReverse(lensFileName);
radius_firstsurface=lens.surfaceArray(1).apertureD/2;

% Set diaphragm diameter manually
diaphragmDiameter_mm=7;

% Generate ray pairs
reverse = true; 
maxRadius = radius_firstsurface*2; % enough margin
minRadius = 0;
offset=0.01;
offset_sensorside=offset;
offset_objectside=offset; %%mm



[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensFileName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset_objectside),'diaphragmdiameter',diaphragmDiameter_mm);

%% RTF generation options
polyDeg = 7
outputDir = fullfile(piRootPath, 'data/lens/');
%outputDir='./'
visualize=true;

rtfLensName=[lensName '-diaphragm' num2str(diaphragmDiameter_mm) 'mm-raytransfer'];
rtfLensName=[lensName '-poly' num2str(polyDeg) '-diaphragm' num2str(diaphragmDiameter_mm) 'mm-raytransfer'];

%% generateRTF
rtf=generateRTFfromIO(rtfLensName,iRays,oRays,offset_sensorside,offset_objectside,lensThickness,'outputdir',...
    outputDir,'visualize',visualize,'polynomialdegree',polyDeg,'intersectionplanedistance',17)
%save([rtfLensName '-raytransfer.mat'],'rtf')