function jsonPath = polyJsonGenerate(fPolyPath, varargin)
% Write json files for polynomial terms
%
% Json file structure:
% description:
% name:
% % x, y, u, v, w. Using x as an example, same to y, u, v, w
% p.description = 'test';
% p.name = 'polynomial';
% p.poly.outx.termr = [1 2 3;4 5 6];
% p.poly.outx.termu
% p.poly.outx.termv
% % p.poly.outx.termw (not used for now)
% p.poly.outx.coeff

% Example:
%{
fname = fullfile(ilensRootPath, 'local', 'poly.mat');
jPath = polyJsonGenerate(fname);
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('fPolyPath', @(x)(iscell(x)) || exist(x, 'file'));
p.addParameter('planes', struct(), @isstruct);
p.addParameter('description', 'equivalent lens poly', @ischar);
p.addParameter('name', 'polynomial', @ischar);
p.addParameter('outpath', fullfile(ilensRootPath, 'local', 'polyjson.json'), ...
                            @ischar);
p.addParameter('pupilpos', [],@isnumeric);
p.addParameter('lensthickness',NaN,@isnumeric);
p.addParameter('pupilradii', [], @isnumeric);                        
p.addParameter('planeoffset', [], @isnumeric);                        
p.addParameter('circleradii', [], @isnumeric);                        
p.addParameter('circlesensitivities', [], @isnumeric);                        
p.addParameter('circleplanez', [], @isnumeric);                        


p.parse(fPolyPath, varargin{:});
description = p.Results.description;
name = p.Results.name;
jsonPath = p.Results.outpath;
planes = p.Results.planes;
pupilPos = p.Results.pupilpos;
pupilRadii = p.Results.pupilradii;
lensThickness = p.Results.lensthickness;
planeOffset= p.Results.planeoffset;
circlePlaneZ= p.Results.circleplanez;
circleRadii= p.Results.circleradii;
circleSensitivities= p.Results.circlesensitivities;

%% Load polynomial term file
if ischar(fPolyPath)
    polyModel = cell(1, 5);
    load(fPolyPath);
elseif iscell(fPolyPath)
    polyModel = fPolyPath;
end
js.description = description;
js.name = name;
if ~isempty(planes)
    js.thicknesswithplanes = abs(planes.input - planes.output);
    js.thickness = lensThickness
    js.planeoffset= planeOffset;
else
    warning('No plane info!')
    js.thickness = 0;
end
% 

js.circleRadii = circleRadii;
js.circleSensitivities = circleSensitivities;
js.circlePlaneZ = circlePlaneZ;
pupil_distances=circlePlaneZ./(1-circleSensitivities);
js.pupilpos = pupil_distances;
js.pupilradii = abs(pupil_distances./circlePlaneZ).*circleRadii;;
%%
% x, y, u, v, w
outName = ['x', 'y', 'u', 'v'];
termName = ['r', 'u', 'v'];
for ii=1:4
    thisOut.outputname = strcat('out', outName(ii));
    
    % term
    for jj=1:3
        thisTermName = strcat('term', termName(jj));
        thisOut.(thisTermName) = polyModel{ii}.ModelTerms(:, jj)';
    end
    % coefficients
    thisOut.coeff = polyModel{ii}.Coefficients;
    
    js.poly(ii) = thisOut;
end

%% Write json file
opts.indent = ' ';
jsonwrite(jsonPath, js, opts);
end