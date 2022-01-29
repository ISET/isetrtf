clear;close all
ieInit;

% Set diaphragm size small enough, else PBRT might automatically
% adjust causing a mismatchin the comparison. 
lensNameNoJsonExtension = 'wide.56deg.3.0mm'; filmdiagonal=40;        
lens=lensC('file',[lensNameNoJsonExtension '.json']);
diaphragmDiameter_mm = lens.apertureMiddleD/2;
maxRadiusMargin = 2;
outputDir = fullfile(piRootPath,'data','lens/');
%% Lens name and propertievs
lensFileName= [lensNameNoJsonExtension, '.json'];
lens=lensReverse(lensFileName);
radius_firstsurface=lens.surfaceArray(1).apertureD/2;

% If diaphraghm is not set, set it to size on file
if(isnan(diaphragmDiameter_mm))
    diaphragmDiameter_mm=lens.get('diaphragmdiameter'); 
end

% Generate ray pairs
reverse = true; 
maxRadius = radius_firstsurface*maxRadiusMargin; % enough margin
minRadius = 0;
offset=0.01;
offset_sensorside=offset;
offset_objectside=offset; %%mm



[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensFileName, 'visualize', false,...
    'n radius samp', 100, 'elevation max', 60,...
    'nAzSamp',500,'nElSamp',500,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset_objectside),'diaphragmdiameter',diaphragmDiameter_mm);

%% RTF generation options
polyDeg = 5;
%outputDir = fullfile(piRootPath, 'data/lens/');

visualize=true;

rtfLensName=[lensNameNoJsonExtension '-diaphragm' num2str(diaphragmDiameter_mm) 'mm-raytransfer'];

%% generateRTF
rtf=generateRTFfromIO(rtfLensName,iRays,oRays,offset_sensorside,offset_objectside,lensThickness,'outputdir',...
    outputDir,'visualize',visualize,'polynomialdegree',polyDeg,'intersectionplanedistance',17);


%% PBRT
rtfVsOmniPBRT([lensNameNoJsonExtension '.json'], [rtfLensName '.json'], 'diaphragmdiameter',diaphragmDiameter_mm,'filmdiagonal',filmdiagonal);
