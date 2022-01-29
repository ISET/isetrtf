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



%% Lens example


path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens.dat'
path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens-further.dat'
path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/scene-lens.dat';
oiLens = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiLens.name ='lens'

oiWindow(oiLens);
oiSet(oiLens,'gamma',0.7)
Dlens=oiLens.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'lens-slantedBar.png')
exportgraphics(ax,'lens-slantedBar.pdf')
%% Blackbox example

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox.dat'
path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox-further.dat'

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/scene-black.dat';

oiBlack = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiBlack.name ='blackbox'
oiWindow(oiBlack);
Dblack=oiBlack.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'blackbox-slantedBar.png')
exportgraphics(ax,'blackbox-slantedBar.pdf')




%% OI's to analyze

oiList = {oiBlack,oiLens};

%% Image through a sensor
oi=oiBlack;

% The pixel size is not the limit!
sensor = sensorCreate;
%sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
% How to set correct pixel size given PBRT recipe?
sensor = sensorSet(sensor,'size',[320 320]);
sensor = sensorSet(sensor,'fov',50,oi); % what FOV should I use?


% These positions give numerically stable results
positions =  [ 35    15   206   228]

ip = ipCreate;

%% MTF loop

% Compare visually MTF's
figure
hlens=plot(mtfLens.freq,mtfLens.mtf,'r'); hold on;
hblack=plot(mtfBlack.freq,mtfBlack.mtf,'k'); hold on;

legend([hlens(1) hblack(1)],'Omni lens','Blackbox lens')
ylim([0 1])
title('MTF')
xlabel('Spatial frequency on the sensor (cy/mm)')


% 
   positions(1,:)=[326   768    78   178];
    positions(2,:)=[408   103    59   104];
    positions(3,:)=[493   322    93   138];
%%

%  MTF

%%%%%%%%%%%% MTF BLACK

% black
sensor = sensorCompute(sensor,oiBlack);
ip = ipCompute(ip,sensor);
ipWindow(ip);

[locs,rect] = ieROISelect(ip);
positions = round(rect.Position);

mtfBlack = ieISO12233(ip,sensor,'all',positions);


%%
%%%%%%%%%%%% MTF Lens

sensor = sensorCompute(sensor,oiLens);
ip = ipCompute(ip,sensor);
ipWindow(ip);

% Use same rectangle 
mtfLens = ieISO12233(ip,sensor,'all',positions);

% Compare visually MTF's

figure
hlens=plot(mtfLens.freq,mtfLens.mtf,'r'); hold on;
hblack=plot(mtfBlack.freq,mtfBlack.mtf,'k'); hold on;

legend([hlens(1) hblack(1)],'Omni lens','Blackbox lens')
ylim([0 1])
title('MTF')
xlabel('Spatial frequency on the sensor (cy/mm)')

return
%ieDrawShape(ip,'rectangle',positions);
%% Vignetting ratio map
% Vignetting ratio
figure(5);clf;
subplot(131)
ratio=(abs(Dlens(:,:,1)./Dblack(:,:,1)));

imagesc(ratio,[0 2]); colormap hot
colorbar;

subplot(132)
ratio=(abs(Dlens(:,:,1)./Dblack(:,:,1)));
ratiofilt = medfilt2(ratio,[10 10]);
imagesc(ratiofilt,[0 2]); colormap hot
colorbar;

title('Vignetting ratio')
subplot(133)
imagesc((abs(Dlens(:,:,1)-Dblack(:,:,1)))); colormap hot
colorbar;
title('Vignetting difference')

