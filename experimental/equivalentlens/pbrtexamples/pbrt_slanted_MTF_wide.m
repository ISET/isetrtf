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
thisR.set('aperture diameter', 2.5318);
thisR.set('film distance', 0.001967);
thisR.set('film diagonal', 15); % mm
%%

% OPTIONAL: Only useful for actual normal PBRTrendering
% piWrite(thisR);
% [oi, result] = piRender(thisR, 'render type', 'radiance');
% oiWindow(oi);




%% Get all OI's of interest
paths={};
names = {}
colors = {'r','r','k','k','b','b'};
style = {'-','-.','-','-.','-','-.'};

names{end+1} = 'lens';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens-wide.dat'
 
 names{end+1} = 'blackbox';
 paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox-wide.dat'
 %
% 


names{end+1} = 'lens 1.5mm';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens-wide-1.5mm.dat'

names{end+1} = 'blackbox 1.5mm';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox-wide-1.5mm.dat'

names{end+1} = 'lens 5.9mm';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens-wide-5.9mm.dat'


% 
 names{end+1} = 'blackbox 5.9mm';
 paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox-wide-5.9mm.dat'


oiList={};
for i = 1:numel(paths)
    path=paths{i};
    oiList{i} = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
    oiList{i}.name =names{i};
end






%% Image through a sensor


% The pixel size is not the limit!
sensor = sensorCreate;
%sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
% How to set correct pixel size given PBRT recipe?
sensor = sensorSet(sensor,'size',[256 256]);
%sensor = sensorSet(sensor,'fov',20,oiList{1}); % what FOV should I use?


% These positions give numerically stable results
positions =  [ 35    15   206   228]

ip = ipCreate;

%% MTF loop

% Compare visually MTF's

for i=1:numel(oiList)
    sensor = sensorCompute(sensor,oiList{i});
    ip = ipCompute(ip,sensor);
    MTF{i} = ieISO12233(ip,sensor,'all',positions);
    close(gcf)
end
fig=figure; hold on;
fig.Position=[691 440 560 220];
clear h
for i=1:numel(oiList)
    h(i)=plot(MTF{i}.freq,MTF{i}.mtf(:,1),'color',colors{i},'linestyle',style{i}); hold on;
end
legend(h,names);
ylim([0 1])
xlim([0 30])
title('MTF')
xlabel('Spatial frequency on the sensor (cy/mm)')
saveas(gcf,'./fig/mtf-slanted-wide.png');


%%

%% Compare Falloff profiles
photonsLens=oiList{1}.data.photons;
photonsBlack=oiList{2}.data.photons;

fig=figure(3);clf;hold on;
fig.Position=[691 440 560 220];
plot(photonsLens(end/2,:,1),'k')
plot(photonsBlack(end/2,:,1),'r')
xlabel('pixel')
saveas(gcf,'./fig/falloff-wide.png');

