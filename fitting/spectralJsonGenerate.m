function [jsonPath,rtf] = spectralJsonGenerate(fPolyPath, varargin)
% Write json files for polynomial terms for multiple wavelengths.
%
% Json file structure:
% description:
% name:
% % x, y, u, v, w. Using x as an example, same to y, u, v, w
% p.description = 'test';
% p.name = 'polynomial';
% p.polynomials: cell array
% p.polynomials{i}.poly.outx.termr = [1 2 3;4 5 6];
% p.polynomials{i}.poly.outx.termu
% p.polynomials{i}.poly.outx.termv
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
p.addParameter('planeoffsetinput', [], @isnumeric);       
p.addParameter('planeoffsetoutput', [], @isnumeric);       
p.addParameter('lensthickness',[], @isnumeric);
p.addParameter('usedzpolynomial',false, @islogical);

p.addParameter('description', 'Ray Transfer Function', @ischar);
p.addParameter('name', 'polynomial', @ischar);
p.addParameter('outpath', fullfile(ilensRootPath, 'local', 'polyjson.json'), ...
                            @ischar);
p.addParameter('polynomials', []);
                  


p.parse(fPolyPath, varargin{:});
description = p.Results.description;
name = p.Results.name;
jsonPath = p.Results.outpath;
planes = p.Results.planes;
planeOffsetIn= p.Results.planeoffsetinput;
planeOffsetOut= p.Results.planeoffsetoutput;
polynomialsPerWavelength = p.Results.polynomials;
lensThickness= p.Results.lensthickness;
useDZpolynomial=p.Results.usedzpolynomial;

%% Load polynomial term file
if ischar(fPolyPath)
    polyModel = cell(1,6);
    load(fPolyPath);
elseif iscell(fPolyPath)
    polyModel = fPolyPath;
end
js.description = description;
js.name = name;
if ~isempty(planes)
    js.thickness = lensThickness;
    js.planeoffsetoutput= planeOffsetOut;
    js.planeoffsetinput= planeOffsetIn;
else
    warning('No plane info!')
    js.thickness = 0;
end

%%
js.useDZpolynomial=useDZpolynomial;

%%
for p =1:numel(polynomialsPerWavelength)
    % x, y, u, v, w
    outName = {'x', 'y','z', 'dx', 'dy','dz'};
    termName = {'r', 'dx', 'dy'};
    
    nbPoly = numel(polynomialsPerWavelength{p}.polyModel);
    for ii=1:nbPoly
        
        
        thisOut.outputname = strcat('out', outName{ii});
        
        % coefficients
        thisOut.coeff = num2cell(polynomialsPerWavelength{p}.polyModel{ii}.Coefficients);
          % Convert to cell array to make sur the json library exports
            % single numbers also an array
  
        % Loop over input variables
        for jj=1:3
            thisTermName = strcat('term', termName{jj});
            % Convert to cell array to make sur the json library exports
            % single numbers also an array. Because PBRT expects an array
            % when reading these terms (One can fix this in PBRT using a
            % try catch)
            thisOut.(thisTermName) = num2cell(polynomialsPerWavelength{p}.polyModel{ii}.ModelTerms(:, jj)');
        end
   
        polynomialsPerWavelength{p}.poly(ii) = thisOut;
    end
    % Remove unneeded fields
    polynomialsPerWavelength{p}=rmfield(polynomialsPerWavelength{p},'polyModel');
    
end

js.polynomials = polynomialsPerWavelength;


%% Write json file
opts.indent = ' ';
jsonwrite(jsonPath, js, opts);

% full json matlab represtation
rtf=js;

end