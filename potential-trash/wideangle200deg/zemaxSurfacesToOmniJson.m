
%% ZEMAX TO OMNI JSON
% This scripts takesthe table from zemax  ( copyied manually into a CSV
% file) and turns it into a json lens file that can be read by PBRT Omni or
% Isetlens.

% The manual work involves several steps
%  1. Determine all materials used and their refractive index at the
%  wavelength of interest
%  2. Select the following columns in the zemax Lens Data Tab and copy into
%  CSV file:  radius, thickness, semi-diameter   
% Ignore row 0 (object) and row 1 (image).
%  Set the thickness of the last surface to zero, because zemax uses that
%  distance to define the film distance. PBRT and isetlens do this
%  differently.

clear;
%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: /usr/local/scratch/thomas42/rtfpaper/zemaxlenses_analysis/data/wideangle200deg-surfaces.csv
%
% Auto-generated by MATLAB on 10-Jan-2022 07:00:46

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["E001", "E000", "VarName3", "E000_1"];
opts.VariableTypes = ["char", "double", "char", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "VarName3", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "VarName3", "EmptyFieldRule", "auto");

% Import the data
wideangle200degsurfaces1 = readtable("wideangle200deg-surfaces.csv", opts);

%% Convert to output type
wideangle200degsurfaces1 = table2cell(wideangle200degsurfaces1);
numIdx = cellfun(@(x) ~isnan(str2double(x)), wideangle200degsurfaces1);
wideangle200degsurfaces1(numIdx) = cellfun(@(x) {str2double(x)}, wideangle200degsurfaces1(numIdx));

%% Clear temporary variables
clear opts


%%
BK7=1.52244
LAKN7=1.65939
SF8=1.70463
SF3=1.75870

clear json

json.description=""
json.name="wideangle200deg-zemax"

rowAperture = 11; % whcih surface is diaphragm
for r=1:size(wideangle200degsurfaces1,1)
    radius=wideangle200degsurfaces1{r,1}

    if(ischar(radius) ) %infinity
        radius=1e5
    end
    if(r==rowAperture)
    radius=0; 
    end
    thickness=wideangle200degsurfaces1{r,2};
    semidiameter=wideangle200degsurfaces1{r,4};
    material=wideangle200degsurfaces1{r,3};
switch(material)
    case "BK7" 
        n=BK7;
    case "SF3"
        n=SF3;
    case "SF8"
        n=SF8;

    case "LAKN7"
        n=LAKN7;

    otherwise
        if(abs(radius)>0)
            n=1;
        else
            n=0; % aperture
        end
end

json.surfaces(r).ior=n;
json.surfaces(r).semi_aperture=semidiameter;
json.surfaces(r).radius=radius;
json.surfaces(r).thickness=thickness;

end
json.metadata.focalLength=0.8544;
json.metadata.fNumber=1.97;

jsonwrite('wideangle200deg-automatic-zemax.json',json)

lens=lensC('file','wideangle200deg-automatic-zemax.json')

lens.draw