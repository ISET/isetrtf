%% Generate all relative Illumination  figures comparing PBRT RTF to ZEMAX
%
%  This uses the data from data/relativeillumination-pbrt/
% Thomas Goossens

clear; close all
addpath(genpath(irtfRootPath))

config={};

%% Lens configurations
i=numel(config)+1;
config{i}.name='dgauss28deg';
config{i}.filmdistance_mm=57.315;
config{i}.sensordiagonal_mm=110;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'dgauss28deg-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/dgauss28deg-relativeillum-zemax.mat';


%% Lens configurations
i=numel(config)+1;
config{i}.name='dgauss28deg-offset0.01';
config{i}.filmdistance_mm=57.315;
config{i}.sensordiagonal_mm=110;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'dgauss28deg-offset0.01-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/dgauss28deg-comparison.mat';



%%
i=numel(config)+1;
config{i}.name='inversetelephoto';
config{i}.filmdistance_mm=1.5;
config{i}.sensordiagonal_mm=1.5*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'inversetelephoto-offset0.1-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/inversetelephoto-comparison.mat';

%%
i=numel(config)+1;
config{i}.name='inversetelephoto-offset0.1';
config{i}.filmdistance_mm=1.5;
config{i}.sensordiagonal_mm=1.5*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'inversetelephoto-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/inversetelephoto-comparison.mat';
%% 
i=numel(config)+1;
config{i}.name='petzval';
config{i}.filmdistance_mm=15.196;
config{i}.sensordiagonal_mm=35*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'petzval-zemax-poly8-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/petzval-comparison.mat';
%% 

i=numel(config)+1;
config{i}.name='petzval-5mminput';
config{i}.filmdistance_mm=15.196;
config{i}.sensordiagonal_mm=35*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'petzval-5mminput-zemax-poly8-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/petzval-comparison.mat';
%% 

i=numel(config)+1;
config{i}.name='petzval-5mminput-circles';
config{i}.filmdistance_mm=15.196;
config{i}.sensordiagonal_mm=35*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'petzval-5mminput-zemax-poly8-circles-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/petzval-comparison.mat';
%% 
i=numel(config)+1;
config{i}.name= 'cooke40deg';
config{i}.filmdistance_mm=50;
config{i}.sensordiagonal_mm=42*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'cooke40deg-zemax-poly9-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/cooke40deg-comparison.mat';

%% 
i=numel(config)+1;
config{i}.name= 'cooke40deg-offset0.01';
config{i}.filmdistance_mm=50;
config{i}.sensordiagonal_mm=42*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'cooke40deg-offset0.01-zemax-poly9-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/cooke40deg-comparison.mat';

%% 
%%
i=numel(config)+1;
config{i}.name= 'tessar'; 
config{i}.filmdistance_mm=100;
config{i}.sensordiagonal_mm=100*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'tessar-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/tessar-comparison.mat';
%%
i=numel(config)+1;
config{i}.name= 'tessar-offset0.01'; 
config{i}.filmdistance_mm=100;
config{i}.sensordiagonal_mm=100*2;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[900 1];
config{i}.rtffile = 'tessar-offset0.01-zemax-poly6-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/tessar-comparison.mat';



%%

i=numel(config)+1;
config{i}.name='wideangle200deg-circle';
config{i}.filmdistance_mm=2.004;   %% Add offset to avoid issue with filmdistance = inputoffset
config{i}.sensordiagonal_mm=3;
config{i}.pixelsamples=2000;
config{i}.filmresolution=[300 1];
config{i}.rtffile = 'wideangle200deg-circle-zemax-poly11-raytransfer.json';
config{i}.zemaxfile='./data/relativeillumination-pbrt/wideangle200deg-circle-comparison.mat';

%%

% i=numel(config)+1;
% config{i}.name='wideangle200deg-edge';
% config{i}.filmdistance_mm=2.2;   %% Add offset to avoid issue with filmdistance = inputoffset
% config{i}.sensordiagonal_mm=3.5;
% config{i}.pixelsamples=2000;
% config{i}.filmresolution=[300 1];
% config{i}.polydegree=6;
%% Add a lens and render.

for p=1:numel(config)
cameraRTF={};
c=config{p}


thisR=piRecipeDefault('scene','flatSurface'); 

% Set Light that is all around the world, so do not depend on the size of the target
% This is especially important for wide angle lenses
thisR.set('light','#1_Light_type:point','type','infinite'); 

thisDocker = 'vistalab/pbrt-v3-spectral:latest';




%    cameraRTF = piCameraCreate('raytransfer','lensfile',fullfile(irtfRootPath,'paper','data','rtf',c.name,c.rtffile));
    
cameraRTF = piCameraCreate('raytransfer','lensfile',which(c.rtffile));    
    cameraRTF.filmdistance.value=c.filmdistance_mm/1000;
    thisR.set('camera',cameraRTF);


    thisR.set('pixel samples',c.pixelsamples);
    thisR.set('film diagonal',c.sensordiagonal_mm,'mm');
    thisR.set('film resolution',c.filmresolution);

    
    thisR.integrator.subtype='path';
    thisR.integrator.numCABands.type = 'integer';
    thisR.integrator.numCABands.value =1;
    
    recipies{p}=thisR;
    % Render
    piWrite(thisR);
    
    [oiTemp,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);
    oiTemp.name=c.name;
        oi{p} =oiTemp;
    
end





%% Generate a relative illumination plot for each lens
colors = hot;
for p=1:numel(config)
    c=config{p};
    
    
    maxnorm= @(x)x/max(x)
    
    oiTemp=oi{p}
    relativeIllumPBRT=maxnorm(oiTemp.data.photons(1,:,1))
    %construct x axis
    resolution=recipies{p}.get('film resolution');resolution=resolution(1);

    xaxis=0.5*recipies{p}.get('filmwidth') *linspace(-1,1,resolution);

    fig=figure(p);clf; hold on
    fig.Position=[680 811 180 155];  % Very small
    
    
    zemaxRelativeIllum=csvread(c.zemaxfile);
    
    hpbrt=plot(xaxis,relativeIllumPBRT,'color',[0.83 0 0 ],'linewidth',2)
    hzemax=plot(zemaxRelativeIllum(:,1),zemaxRelativeIllum(:,2),'k-.','linewidth',2,'color','k')

    xlim([0 inf])
    xlabel('Image height (mm)')

    if(p==1)    
        [legh]=legend([hpbrt,hzemax],'RTF','Zemax')
       legh.Box='off'
        %legh.Orientation = 'horizontal'
        legh.Position=[0.162 0.3532 0.4833 0.1097]
    
    end

% Figure styles
box on

set(findall(gcf,'-property','FontSize'),'FontSize',11);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');
pause(1)
exportgraphics(gcf,['./fig/relativeillumination/' c.name '.pdf'])
end



