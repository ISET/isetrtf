%% PART1: Normal rendering from ISET3d
clear;
ieInit;
if ~piDockerExists, piDockerConfig; end

% This section has to be run at least once in order to use the second part
% of code below
thisR = piRecipeDefault('scene name', 'simple scene');
lensfile = 'lenses/wide.56deg.3.0mm.json';

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 0.4350);
thisR.set('film distance', 0.001967);
thisR.set('film diagonal', 18); % mm
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

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/lens-wide.dat'

oiPoly = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiPoly.name ='lens'

oiWindow(oiPoly);
oiSet(oiPoly,'gamma',0.5)
Dlens=oiPoly.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'./fig/lens-wide.png')



%% Lens Exitpupil example

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/lens-wide-exit.dat'

oiPoly = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiPoly.name ='lens exit'

oiWindow(oiPoly);
oiSet(oiPoly,'gamma',0.5)
Dlens=oiPoly.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'./fig/lens-wide-exitpupilsample.png')




%% Blackbox example

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/blackbox-wide.dat'
%path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/flatSurface/renderings/blackbox.dat'

%path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/scene-blackbox-5deg.dat'
%path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/scene-blackbox-otherthickness-1024.dat'

oiPoly = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiPoly.name ='blackbox'
oiWindow(oiPoly);
Dblack=oiPoly.data.photons;
pause(1);
ax = gca;
exportgraphics(ax,'./fig/blackbox-wide.png')

return
%% Blackbox without vignetting example

path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/renderings/scene-blackbox-novignet-256.dat'

oiPoly = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiPoly.name ='blackbox-novignet'
oiWindow(oiPoly);
Dblacknovignet=oiPoly.data.photons;

%% Vignetting ratio map
% Vignetting ratio
figure(5);clf;
subplot(131)
ratio=(abs(Dlens(:,:,1)./Dblack(:,:,1)));

imagesc(ratio,[0.5 2]); colormap hot
subplot(132)
ratio=(abs(Dlens(:,:,1)./Dblack(:,:,1)));
ratiofilt = medfilt2(ratio,[10 10]);
imagesc(ratiofilt,[0 1.2]); colormap hot

title('Vignetting ratio')
subplot(133)
imagesc((abs(Dlens(:,:,1)-Dblack(:,:,1)))); colormap hot
title('Vignetting difference')

