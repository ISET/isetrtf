function [rtf] =generateRTFfromIO(lensName,rtfName,inputrays,outputrays,offsetinput,offsetoutput,lensThickness_mm,varargin)
%generateRTFfromIO Give the inputoutput information, generate a full RTF
%function, including vignetting and ouput the JSON file.
%%%%%%%%%%%%%%%%%%%% AUTOMATIC BELOW %%%%%%%%%%%%%%%%%%%%%%% 
%% Fit Pass/NoPass function
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lensname', @ischar);
p.addRequired('rtfname', @ischar);
p.addRequired('inputrays', @isnumeric);
p.addRequired('outputrays', @isnumeric);
p.addRequired('offsetinput', @isnumeric);      
p.addRequired('offsetoutput', @isnumeric);  
p.addRequired('lensthickness', @isnumeric);  
p.addParameter('polynomialdegree', 4, @isnumeric);
p.addParameter('outputtype', 'plane', @ischar); % plane or surface
p.addParameter('disable_dz_polynomial', true, @islogical); %  Use when backwards traveling waves can occur(dz<0)
% This could happen for systems with mirrors or fish eye lenses (for ewhich
% you will need a spherical output surfaces (outputtype='surface'))

p.addParameter('visualize', false, @islogical);
p.addParameter('fpath', '', @ischar);
p.addParameter('sparsitytolerance', 1e-9, @isnumeric);      
p.addParameter('outputdir',  './',@ischar);      
p.addParameter('lensdescription',  '',@ischar);      
p.addParameter('raypassplanedistance',10,@isnumeric); % Default value, it does not really matter but not zero
p.parse(lensName,rtfName,inputrays,outputrays,offsetinput,offsetoutput,lensThickness_mm,varargin{:});


polyDegree = p.Results.polynomialdegree;
visualize = p.Results.visualize;
outputtype= p.Results.outputtype;
sparsitytolerance= p.Results.sparsitytolerance;
fpath= p.Results.fpath;
outputdir= p.Results.outputdir;
lensdescription= p.Results.lensdescription;
rayPassPlaneDistance = p.Results.raypassplanedistance;
disableDZpoly=p.Results.disable_dz_polynomial;
%% Prepare distances for inputoutputplane Z position calculation
% By convention z=0 at the output side vertex of the lens
frontvertex_z=-lensThickness_mm;  % By convention
planes.input=frontvertex_z-offsetinput;
planes.output=offsetoutput;


%% Preprocess input output rays

% Only keep the rays that passed the lens (output ray is not NAN)
passedRays=~isnan(outputrays(:,1));
inputrays=inputrays(passedRays,:);
outputrays=outputrays(passedRays,:);

%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(inputrays,planes.input,'circleplanedistance',rayPassPlaneDistance);
[radii,centers] = vignettingFitEllipses(pupilShapes);


if(visualize)
    figure;
    subplot(211)
    plot(positions,radii','.-','markersize',10,'linewidth',2);
    title('Ellipse Radii');
    legend('X','Y');
    subplot(212)
    plot(positions,centers','.-','markersize',10,'linewidth',2);
    title('Ellipse Centers');
    legend('X','Y');



% Show pupil sampling    
figure;
nbPos = numel(positions);
for p=1:numel(positions)
    subplot(ceil(sqrt(nbPos)),ceil(sqrt(nbPos)),p);
    hold on
    pupil=pupilShapes{p};
    scatter(pupil(1,:),pupil(2,:),'.');
    
    drawellipse('center',[centers(1,p) centers(2,p)],'semiaxes',[radii(1,p) radii(2,p)],'color','r');
%   pupil=pupilShapes{1};
%      pupil(isnan(pupil(1,:)))=[]; % Remove nans
    %scatter(pupil(1,:),pupil(2,:),'r+')
    title(positions(p));
    
    %axis equal
    
end


end



%% Polynomial fit
fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(inputrays, outputrays,...
    'visualize', visualize,...
    'maxdegree', polyDegree,...
   'sparsitytolerance',sparsitytolerance);



%% Add meta data to polymodel sepearte struct
w=1; % only one wavelength
rtf{w}.wavelength_nm = 550;
rtf{w}.polyModel = polyModel;
rtf{w}.raypass.method='minimalellipse';
rtf{w}.raypass.positions=positions;
rtf{w}.raypass.radiiX=radii(1,:);
rtf{w}.raypass.radiiY=radii(2,:);
rtf{w}.raypass.centersX=centers(1,:);
rtf{w}.raypass.centersY=centers(2,:);
rtf{w}.raypass.intersectPlaneDistance=intersectionplane;



%% Generate Spectral JSON file

rtfdirectory = fullfile(outputdir,lensName);

if ~exist( fullfile(outputdir,lensName), 'dir')
       mkdir(rtfdirectory)
end


fpath = fullfile(rtfdirectory,[rtfName '.json']);

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness',...
        lensThickness_mm, 'planes',...
        planes,'planeOffset input',offsetinput,...
        'plane offset output',offsetoutput,...
        'outpath', fpath,...
        'polynomials',rtf,'name',lensName,'description',lensdescription,'useDZpolynomial',~disableDZpoly);
    
end



end
