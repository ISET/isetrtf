clear; close all;



lensName='pixel4a-frontcamera'

filmdistance_mm=0.3616965582;
offset_sensorside=filmdistance_mm;
offset_objectside=1; %%mm

%Actual Z positions of the planes

thickness_bsc7=0.21
thickness_blackboxlens=3.0333179923;

lensThickness=thickness_bsc7+thickness_blackboxlens;

frontvertex_z=-lensThickness;
planes.input=frontvertex_z-offset_sensorside;
planes.output=offset_objectside;





%% Get ZEMAX rays
X=dlmread('Gout-P4Fa_20111018.txt','\s',1);


Xnonan=X(~isnan(X(:,1)),:);





iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);






%% Polynomial fit
polyDeg = 6

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[0.5800 0.5800 ]
circleSensitivities =[0.0440 0.0440]
circlePlaneZ =   2.2
pupilPos=[2.3 2.3];
pupilRadii=[0.6067 0.6067];


sparsitytolerance = 0*1e-4;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'sparsitytolerance',sparsitytolerance);
%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength


apertureRadius_mm=1 %UNKONWN

fit{w}.wavelength_nm = 550;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivities;
fit{w}.circlePlaneZ = circlePlaneZ;
fit{w}.diaphragmIndex=0;
fit{w}.diaphragmToCircleRadius=1


fit{w}.circleNonlinearRadius = [1 0 0 0 0 -6.3258e-4]  % newradius =radius*(1+a*x+b*x^2+....)
fit{w}.circleNonlinearSensitivity= [0 0.0233 0 0 0  0.0035] % offset - position*(0+a*x+b*x^2+....) %%mm



%% Nonlinearity



%fit{w}.planes = planes; %% Not needed because it can b calculated



%% Generate Spectral JSON file
fpath = fullfile(piRootPath, 'data/lens/',[lensName '-filmtoscene-raytransfer.json']);

lensinfo.name=lensName;
lensinfo.description='Pixel 4A front lens RTF'
lensinfo.apertureDiameter=2.8
lensinfo.focallength=0;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness',...
        lensThickness, 'planes',...
        planes,'planeOffset input',offset_sensorside,...
        'plane offset output',offset_objectside,...
        'outpath', fpath,...
        'polynomials',fit);

end