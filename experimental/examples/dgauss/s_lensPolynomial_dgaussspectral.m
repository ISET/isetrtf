%%
clear;
ieInit;


%% Fitting options

polyDeg = 5;
tolerance=1e-2; % for sparsity of polynomial

%% Crown glass 

n= @(l) sqrt(2.24187488 -0.00891932146*l.^2 +0.0126251741./l.^2 -0.000298598739./l.^4+5.95648836e-5*1./l.^6-2.58633231E-6*1./l.^8);
n = @(l) 1.67/1.5*n(l); % correctie
wavelengths_micron=linspace(0.395,0.705,31);
wavelengths_micron=linspace(0.395,0.705,1);

lensName = 'dgauss.22deg.3.0mm.json'

lens=lensC('file',lensName)

for w = 1:numel(wavelengths_micron)
    wavelength=wavelengths_micron(w);
    % Update all refractive indices
    lens.surfaceArray(1).n = n(wavelength);
                
    
    lens.fileWrite('temporarylens.json')




%% Generate ray pairs
maxRadius = 0.6;
minRadius = 0;
offset=0.01;

[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs('temporarylens.json', 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', true,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset));


%% Save dataset for google
clear inputs
inputs(:,2) = iRays(:,1);
inputs(:,1) = 0;
inputs(:,3) = -offset;
inputs(:,4) = iRays(:,2); % dx
inputs(:,5) = iRays(:,3); % dy
inputs(:,6) = sqrt(1-iRays(:,2).^2-iRays(:,3).^2);

outputs = oRays;




%% Polynomial fit


% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[    1.2700    1.3500   10.0000]
circleSensitivities =[   -1.6628    0.8298  -15.6821]
circlePlaneZ = 3;



fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');

fpath = fullfile(['polyjson_test' num2str(wavelength) '.json']);

[polyModel] = lensPolyFit(iRays, oRays,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'plane offset',offset,...
    'pupil radii', pupilRadii,...
    'circle radii',circleRadii,...
    'circle sensitivities',circleSensitivities,...
    'circle plane z',circlePlaneZ,...
    'sparsity tolerance',tolerance,...
    'lensthickness',lensThickness);

close all;


% Create struct which will be passed to JSON file
fit{w}=struct;
fit{w}.wavelength_nm = wavelengths_micron(w)*1e3;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivities;
fit{w}.circlePlaneZ = circlePlaneZ;
fit{w}.diaphragmIndex=diaphragmIndex;
fit{w}.diaphragmToCircleRadius=(2*circleRadii(diaphragmIndex+1))/0.6;

end

%% Generate Spectral JSON file
fpath = fullfile(ilensRootPath, 'local',[lensName '-raytransfer.json']);
lensinfo.name=lens.name;
lensinfo.description=lens.description;
lensinfo.apertureDiameter=lens.apertureMiddleD;
lensinfo.focallength=lens.focalLength;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness', lensThickness, 'planes', planes,'planeOffset',offset, 'outpath', fpath,...
        'polynomials',fit);

end

