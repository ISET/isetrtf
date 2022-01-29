%% PART1: Normal rendering from ISET3d
clear;
ieInit;
if ~piDockerExists, piDockerConfig; end

% This section has to be run at least once in order to use the second part
% of code below
thisR = piRecipeDefault('scene name', 'simple scene');
lensfile = 'lenses/dgauss.22deg.3.0mm.json';

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('film distance', 0.002167);
thisR.set('film diagonal', 5); % mm
%%

% OPTIONAL: Only useful for actual normal PBRTrendering
% piWrite(thisR);
% [oi, result] = piRender(thisR, 'render type', 'radiance');
% oiWindow(oi);

%% PART2: Compare results after running seperately from PBRT
% This part needs to be run not within ISET3d but directly from PBRT. Later
% on we would make blackbox as a docker container that can be also called
% from ISET3d.
% fname = fullfile(piRootPath, 'local', 'Copy_of_simpleScene', 'renderings', 'test.dat');
% oiPoly = piDat2ISET(fname, 'wave', 400:10:700, 'recipe', thisR);
% oiWindow(oiPoly);



%%  Chromatic Lens example


path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/chromatic-lens.dat'



oiLens = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiLens.name ='Omni dgauss chromat'

oiWindow(oiLens);
%oiSet(oiLens,'gamma',0.5)
Dlens=oiLens.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'./fig/lens-dgauss-chromat.png')





%%  Chromatic RTF example


path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/chromatic-rtf.dat'


%path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/flatSurface/renderings/lens.dat'
%path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/scene-lens-512-diag2.dat'
oiRTF = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiRTF.name ='RTF Dgauss chromat'

oiWindow(oiRTF);
%oiSet(oiRTF,'gamma',0.5)
DRTF=oiRTF.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'./fig/lens-dgauss-rtf-chromat.png')



%% Image through a sensor
oiList = {oiLens, oiRTF};


for o=1:numel(oiList)
    
    oi=oiList{o};
    
    % The pixel size is not the limit!
    sensor = sensorCreate;
    %sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
    % How to set correct pixel size given PBRT recipe?
    sensor = sensorSet(sensor,'size',[320 320]);
    sensor = sensorSet(sensor,'fov',50,oi); % what FOV should I use?
    
    
    % These positions give numerically stable results
    %positions =  [ 35    15   206   228]
    positions=[ 266   534   286   416];
    ip = ipCreate;
    
    sensor = sensorCompute(sensor,oi);
    ip = ipCompute(ip,sensor);
    
    % MTF Lens
    
    positions(1,:)=[ 266   534   286   416];
    
    mtf{o}= ieISO12233(ip,sensor,'all',positions);
    xlim([0 60])
    ylim([0 1])
    title(oi.name);
    saveas(gcf,['./fig/MTF-comparison-'  oi.name '.png'])
    % Compare visually MTF's
end

%% MTF Compare RTF met Omni
color{1}='r'
color{2}='g'
color{3}='b'
color{4}='k'
linestyle{1}='-'
linestyle{2}='--'
% Compare visually MTF's

fig=figure;clf;
fig.Position= [498 419 1101 245];
for o=1:numel(mtf)
    for k =1:4
        subplot(1,4,k); hold on;
        h(o)=plot(mtf{o}.freq,mtf{o}.mtf(:,k),'color',color{k},'linestyle',linestyle{o}); hold on;
        ylim([0 1])
        xlim([0 50])
        title('MTF')
        xlabel('Freq. (cy/mm)')
        
    end
    
end
legend(h,'Omni','RTF')

saveas(gcf,'./fig/MTF-comparison.png')


