function [bins,counts,peaks,lens,positionsOnFilm_mm] = receptiveField(lenstype,lensFilePath,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,varargin)
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lenstype', @ischar);
p.addRequired('rtfJSONfilepath', @ischar);
p.addRequired('filmdistance_mm', @isnumeric);
p.addRequired('receptiveFieldDistanceFromFilm_mm', @isnumeric);
p.addParameter('imageheight',0,@isnumeric);
p.addParameter('gridpoints',1000,@isnumeric);
p.addParameter('gridsize_mm',30,@isnumeric);
p.addParameter('histogrambins',50,@isnumeric);
p.addParameter('diaphragmdiameter',7,@isnumeric);
p.parse(lenstype,lensFilePath,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,varargin{:});


imageHeight_mm = p.Results.imageheight;
nbGridPoints =  p.Results.gridpoints;
gridSize_mm=p.Results.gridsize_mm;
nbBins = p.Results.histogrambins;
diaphragmdiameter= p.Results.diaphragmdiameter;

%% Load RTF from JSON file
if(isequal(lenstype,"rtf"))
    opts.indent = ' ';
    RTF=jsonread(lensFilePath,opts);
    lensThickness = RTF.thickness;
    lens=RTF;
elseif(isequal(lenstype,"isetlens"))
    lens=lensReverse(lensFilePath);
    close all
    lens.set('middleaperturediameter',diaphragmdiameter);
    lensThickness = lens.get('lens thickness');
    addPlane=outputPlane(receptiveFieldDistanceFromFilm_mm-filmdistance_mm-lensThickness); % Scene plane for receptive field
    lens = addPlane(lens);

end

%% Object distances with different reference ponts

filmDistanceFromFront = lensThickness+filmdistance_mm;

%% Grid definition to sample the pupil uniformly
gridCenterZ = -lensThickness;
gridpoints = linspace(-gridSize_mm/2,gridSize_mm/2,nbGridPoints);

[rows,cols] = meshgrid(gridpoints,gridpoints);
grid=[rows(:) cols(:) ones(numel(rows),1)*gridCenterZ];


%% Generate collection of rays by tracing origin points to grid points
origins = repmat([0 imageHeight_mm -filmDistanceFromFront],[numel(rows) 1]);
directions = (grid-origins);
directions = directions./sqrt(sum(directions.^2,2));

%% Trace rays 
if(isequal(lenstype,"rtf"))
    % Trace through RTF lens
    % Ik heb mijn twijfels dat ik de positie hier correct bereken
    
    %planeDistanceFromOutputPlane =  receptiveFieldDistanceFromFilm_mm-(filmdistance_mm+lensThickness+RTF.planeoffsetoutput);
    planeDistanceFromRearVertex =  receptiveFieldDistanceFromFilm_mm-(filmdistance_mm+lensThickness);
    positionsOnFilm_mm=rtfTraceObjectToFilm(RTF,origins,directions,planeDistanceFromRearVertex);
elseif(isequal(lenstype,"isetlens"))
    waveindex=1;
    waveIndices=waveindex*ones(1, size(origins, 1));
    rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
    [~, ~, positionsOnFilm_mm, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);
end


%% Calculate Linespread functions
% positionsOnFilm contains the coordinates of the points on the image
% plane. By making a histogram for only the X values, one effectively has
% aggregated over Y direction (summed all bins in Y direction).

maxnorm = @(x)x/max(x);
mmToMicron=1e3;
for i=1:2
    [countsTemp,binsTemp]=hist(mmToMicron*positionsOnFilm_mm(:,i),nbBins);
    bins(:,i)=binsTemp;
    counts(:,i)=countsTemp;
    peaks(i)=sum(binsTemp.*countsTemp)./sum(countsTemp);
end

end