function [rtf,rtfLensName] = isetlensToRTF(lensNameNoJsonExtension,varargin)

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lensname', @(x)(exist([x '.json'], 'file')));
p.addParameter('diaphragmdiameter', NaN, @isnumeric);
p.addParameter('maxradiusmargin', 2, @isnumeric); % Scaling the maximum off axis distance 
p.addParameter('polydegree', 5, @isnumeric); % Polynomial degree
p.addParameter('outputdir',  './',@ischar);      

p.parse(lensNameNoJsonExtension, varargin{:});
diaphragmDiameter_mm = p.Results.diaphragmdiameter;
maxRadiusMargin = p.Results.maxradiusmargin;
outputDir = p.Results.outputdir;
polyDegree = p.Results.polydegree;
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
    'n radius samp', 50, 'elevation max', 60,...
    'nAzSamp',300,'nElSamp',300,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset_objectside),'diaphragmdiameter',diaphragmDiameter_mm);

%% RTF generation options
%outputDir = fullfile(piRootPath, 'data/lens/');

visualize=true;

rtfLensName=[lensNameNoJsonExtension '-poly' num2str(polyDegree) '-diaphragm' num2str(diaphragmDiameter_mm) 'mm-raytransfer'];

%% generateRTF
rtf=generateRTFfromIO(lensNameNoJsonExtension,rtfLensName,iRays,oRays,offset_sensorside,offset_objectside,lensThickness,'outputdir',...
    outputDir,'visualize',visualize,'polynomialdegree',polyDegree,'intersectionplanedistance',17);


end