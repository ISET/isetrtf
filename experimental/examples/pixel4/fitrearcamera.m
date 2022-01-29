clear; close all;



lensName='pixel4a-rearcamera'

filmdistance_mm=0.464135918
offset_sensorside=filmdistance_mm;
offset_objectside=1.48002192; %%mm

lensThickness=4.827;

frontvertex_z=-lensThickness;
planes.input=frontvertex_z-offset_sensorside;
planes.output=offset_objectside;





%% Get ZEMAX rays
X=dlmread('Gout-P4Ra_20111103.txt','\s',1);
X=dlmread('/usr/local/scratch/thomas42/MATLAB/libs/isetlens/local/Gout-P4Rb183050_20211115.txt','\s',1);

Xnonan=X(~isnan(X(:,1)),:);





iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);






%% Polynomial fit
polyDeg = 5

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[0.3802 0.3802 ]
circleSensitivities =[0.0522 0.0522] % Bug: Duplicate to keep it an array when generating json
circlePlaneZ =   2.5893



sparsitytolerance = 0*1e-4;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,...
    'visualize', true,...
    'maxdegree', polyDeg,...
    'sparsitytolerance',sparsitytolerance);


%% Fit Pass/NoPass function

%% Generate vignetting functions
% Prepare positions in struct to interface to vignettingFitEllipses

for p=1:numel(positions)
     pointsPerPosition{p}=squeeze(pupilshape_trace([1 2],p,:));
end
  
[radii,centers,rotations]=vignettingFitEllipses(pointsPerPosition);
  


%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength

apertureRadius_mm=1 %UNKONWN

polynomials{w}.wavelength_nm = 550;
polynomials{w}.polyModel = polyModel;
polynomials{w}.circleRadii = circleRadii;
polynomials{w}.circleSensitivities = circleSensitivities;
polynomials{w}.circlePlaneZ = circlePlaneZ;
polynomials{w}.diaphragmIndex=0;
polynomials{w}.diaphragmToCircleRadius=1


polynomials{w}.circleNonlinearRadius = [1 0 0.0741 0.05 -0.0360 0 0.0012]  % newradius =radius*(1+a*x+b*x^2+....)
polynomials{w}.circleNonlinearSensitivity= [0.0522 -0.0237 0.0456 ] % offset - position*(0+a*x+b*x^2+....) %%mm




%% Nonlinearity



%fit{w}.planes = planes; %% Not needed because it can b calculated



%% Generate Spectral JSON file
fpath = fullfile(piRootPath, 'data/lens/',[lensName '-filmtoscene-raytransfer.json']);

lensinfo.name=lensName;
lensinfo.description='Pixel 4A Rear Lens RTF'
lensinfo.focallength=0;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness',...
        lensThickness, 'planes',...
        planes,'planeOffset input',offset_sensorside,...
        'plane offset output',offset_objectside,...
        'outpath', fpath,...
        'polynomials',polynomials);

end



return

%% Explore optimal degree fit
polyDegs = 1:6
error = zeros(6,numel(polyDegs))
for i=1:numel(polyDegs)

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[0.3802 0.3802 ]
circleSensitivities =[0.0522 0.0522]
circlePlaneZ =   2.5893



sparsitytolerance = 1e-4;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDegs(i),...
    'sparsitytolerance',sparsitytolerance);

poly{i}=polyModel;
for p = 1:numel(polyModel)
error(i,p)= polyModel{p}.RMSE;
end
figure(10);clf
semilogy(error)
xlabel('Polynomial degree')
ylabel('RMSE')
pause(1)
end
