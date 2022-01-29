%%
ieInit;

%%
lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';
reverse = true; 
%% Generate ray pairs
maxRadius = 15;
minRadius = 0;
offset=0.01;
offset_sensorside=offset;
offset_objectside=offset; %%mm


[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', reverse,... 
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

% csvwrite('inputrays-dgauss.csv',inputs)
% 
% outputs = oRays;
% csvwrite('outputrays-dgauss.csv',outputs)
% 


%% Polynomial fit
polyDeg = 5

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[    7.5  125.3000   9.5]
circleSensitivities =[    0.9281 -11.5487   -0.0152]
circlePlaneZ =   17

% Four circles REVERSE LENS  (wrong exit pupil)

apertureRadius_mm=6;
circleRadii =[  7.2291  125.3000    9.5000    8.2000]
circleSensitivities =[    0.7991  -11.5487   -0.0152    1.0060]
circlePlaneZ =[    17]


% Three circles reverselense aperture diameter = 7
apertureRadius_mm=7/2;
circleRadii =[5.2300    8.1000  107.3000  ,  7.2291  125.3000    9.5000  ]
circleSensitivities =[ 0.0652    1.0075   -9.8241,    0.7991  -11.5487   -0.0152 ]
circlePlaneZ =[    17]

sparsitytolerance = 0;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'sparsitytolerance',sparsitytolerance);

%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength

fit{w}.wavelength_nm = 550;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivitqies;
fit{w}.circlePlaneZ = circlePlaneZ;
fit{w}.diaphragmIndex=diaphragmIndex;
fit{w}.diaphragmToCircleRadius=(2*circleRadii(diaphragmIndex+1))/(2*apertureRadius_mm);
fit{w}.planes = planes;


fit{w}.circleNonlinearRadius = [1 0 -0.0016 ]  % newradius =radius*(1+a*x+b*x^2+....)
fit{w}.circleNonlinearSensitivity= [0 -0.0351 0.0280] % offset - position*(0+a*x+b*x^2+....) %%mm



%% Generate Spectral JSON file
fpath = fullfile(piRootPath, 'data/lens/',[lensName '-filmtoscene-raytransfer.json']);
lens  = lensC('file',lensName);
lensinfo.name=lensName;
lensinfo.description=lens.description;
lensinfo.apertureDiameter=lens.apertureMiddleD;
lensinfo.focallength=lens.focalLength;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness',...
    lensThickness, 'planes', planes,...
    'plane offset input',offset_sensorside,...
    'plane offset output',offset_objectside,...
    'outpath', fpath,...
    'polynomials',fit);

end

%% For use in matlab
save('rtf-dgauss.22deg.50mm-reverse.mat','fit')
