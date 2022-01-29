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




%% Get all OI's of interest
paths={};
names = {}
colors = {'r','k','b'};
style = {'-','-.'};

names{end+1} = 'reallens';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/scene-lens.dat';

names{end+1} = 'blackbox';
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/multipleSlantedBars/renderings/scene-black.dat';

oiList={};
for i = 1:numel(paths)
    path=paths{i};
    oiList{i} = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
    oiList{i}.name =names{i};
end

clear positions;
positions(1,:)=[326   768    78   178];
positions(2,:)=[408   103    59   104];
positions(3,:)=[493   322    93   138];



%% Image through a sensor


% The pixel size is not the limit!
sensor = sensorCreate;
%sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
% How to set correct pixel size given PBRT recipe?

sensor = sensorSet(sensor,'size',[320 320]);
sensor = sensorSet(sensor,'fov',50,oiList{1}); % what FOV should I use?


% These positions give numerically stable results


ip = ipCreate;

%% MTF loop

% Compare visually MTF's

for i=1:numel(oiList)
    sensor = sensorCompute(sensor,oiList{i});
    ip = ipCompute(ip,sensor);
    for p=1:size(positions,1)
        MTF{i,p} = ieISO12233(ip,sensor,'all',positions(p,:));
        close(gcf)
    end

end

fig=figure; hold on;
fig.Position=[691 440 560 220];
clear h
for i=1:numel(oiList)
        for p=1:size(positions,1)
            h(i)=plot(MTF{i,p}.freq,MTF{i,p}.mtf(:,1),'color',colors{p},'linestyle',style{i}); hold on;
        end
end
legend(h,names);
ylim([0 1])
xlim([0 100])
title('MTF')
xlabel('Spatial frequency on the sensor (cy/mm)')
saveas(gcf,'./fig/mtf-slanted-dgauss.png');


%%

%% Compare Falloff profiles
photonsLens=oiList{1}.data.photons;
photonsBlack=oiList{2}.data.photons;


fig=figure(3);clf;hold on;
fig.Position=[691 440 560 220];
plot(photonsLens(end/2,:,1),'k')
plot(photonsBlack(end/2,:,1),'r')
xlabel('pixel')
saveas(gcf,'./fig/falloff-multislant-dgauss.png');
