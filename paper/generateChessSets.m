%% Compare rendered chess set scene for known lens and its corresponding RTF.

ieInit
if ~piDockerExists, piDockerConfig; end



config={};


%% Colors
colorpass = [0 49 90]/100;    
color2 = [0.83 0 0];
colors=[colorpass;color2];
%%
i=numel(config)+1;
config{i}.name='tessar';
config{i}.lensfile='tessar-zemax.json';
config{i}.filmdistance_mm=160;
config{i}.rtffile= 'tessar-zemax-poly13-raytransfer.json';
config{i}.sensordiagonal_mm=450;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=2*8.111;
config{i}.hline = 0.5; % proportion of filmresolution




%%
i=numel(config)+1;
config{i}.name='wideangle200deg';
config{i}.lensfile='wideangle200deg-automatic-zemax.json';
config{i}.filmdistance_mm=2.004;
config{i}.rtffile= 'wideangle200deg-circle-zemax-poly11-raytransfer.json';
config{i}.sensordiagonal_mm=3;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=2*0.62000000;
config{i}.hline = 0.66; % proportion of filmresolution
config{i}.cameraposition = -0.3; % Camera position



%%
i=numel(config)+1;
config{i}.name='petzval';
config{i}.lensfile='petzval-zemax.json';
config{i}.filmdistance_mm=45;
config{i}.rtffile= 'petzval-5mminput-zemax-poly8-circles-raytransfer.json';
%config{i}.rtffile= 'petzval-zemax-poly8-raytransfer.json';
config{i}.sensordiagonal_mm=150;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=28*2;
config{i}.hline = 0.5; % proportion of filmresolution



%%
i=numel(config)+1;
config{i}.name='cooke40deg';
config{i}.lensfile='cooke40deg-zemax.json';
config{i}.rtffile= 'cooke40deg-zemax-poly12-raytransfer.json';
config{i}.filmdistance_mm=50;
config{i}.sensordiagonal_mm=100;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=2*5;
config{i}.hline = 0.5; % proportion of filmresolution


%%
i=numel(config)+1;
config{i}.name='dgauss28deg';
config{i}.lensfile='dgauss.28deg-zemax.json';
config{i}.filmdistance_mm=80;
config{i}.rtffile= 'dgauss28deg-zemax-poly7-raytransfer.json';
config{i}.sensordiagonal_mm=100;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=2*10.229;
config{i}.hline = 0.5; % proportion of filmresolution


%%
i=numel(config)+1;
config{i}.name='inversetelephoto';
config{i}.lensfile='inversetelephoto-zemax.json';
config{i}.rtffile= 'inversetelephoto-zemax-poly6-raytransfer.json';
config{i}.filmdistance_mm=1.2;
config{i}.sensordiagonal_mm=2.5;
config{i}.filmresolution=600;
config{i}.raysperpixel=1000;
config{i}.omni_aperturediameter_mm=2*0.166;
config{i}.hline = 0.5; % proportion of filmresolution

%%

for ic=1:numel(config)
    c=config{ic};
% The chess set with pieces
thisR=piRecipeDefault('scenename','chess set')

% Choose docker container
thisDocker = 'vistalab/pbrt-v3-spectral:latest';


    if(isfield(c,'cameraposition'))
    % Set camera and camera position
    filmZPos_m           = c.cameraposition;
    thisR.lookAt.from(3)= filmZPos_m
    end
    
% Define cameras
sensordiagonal_mm=c.sensordiagonal_mm;
% OMNI (known lens) camera
cameraOmni = piCameraCreate('omni','lensfile',c.lensfile);
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=c.filmdistance_mm*1e-3;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=c.omni_aperturediameter_mm;
cameraOmni.aperturediameter.type='float';


% RTF camera

cameraRTF = piCameraCreate('raytransfer','lensfile',c.rtffile);
cameraRTF.filmdistance.value=c.filmdistance_mm*1e-3;


% Rendering Options
thisR.set('pixel samples',c.raysperpixel)
thisR.set('film diagonal',c.sensordiagonal_mm,'mm');

thisR.set('film resolution',c.filmresolution*[1 1])
    

% Path integrator, only use one wavelength
thisR.integrator.subtype='path'
thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1


% Render images

% Omni
disp('---------Render Omni----------')
thisR.set('camera',cameraOmni);
tic
[oi,resultsOmni] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['Omni']
oiOmni{ic}=oi;
omniTime(ic)=toc;

% RTF
disp('---------Render RTF-----------')
thisR.set('camera',cameraRTF);
tic;
[oi,resultsRTF] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['RTF']
oiRTF{ic}=oi;
rtfTime(ic)=toc;

end



%save('./fig/chess/data.mat','oiRTF','oiOmni')

%% Generate plots
for ic=1:numel(config)
    c=config{ic};
oiList={oiOmni{ic} oiRTF{ic} }
% Export images to PNG files
for i=1:numel(oiList)
        oi=oiList{i};
    oiWindow(oi);
    line([0 600],[300 300],'linestyle','--','color',colors(i,:),'linewidth',2)
    exportgraphics(gca,['./fig/chess/chessSet-' c.name '-' oi.name '.png'])
end


% Compare horizontal line and generate PNG file
fig=figure; hold on
 fig.Position=[687 474 623 146]


colororder(colors);



for i=1:2
    oi=oiList{i};
    
    % Sum up across all 31 wavelengths in the photons datacube.
    hline=sum(oi.data.photons(round(c.hline*end),:,:),3);
    hline=hline/max(hline);
    plot(hline,'linewidth',2)
    
    
end


% Format figure
xlabel('Pixel')
ylabel('Photons (a.u.)')
set(gca,'Position',[0.1300 0.2614 0.7750 0.4978])

% Format legend
if(c.name=="dgauss28deg")
    legh=legend('Known Lens', 'RTF');
    legh.Orientation='horizontal';
    legh.Box='off';
    legh.Position= [0.3385 0.8155 0.3394 0.1479];
end
% Make all text latex formatted
set(findall(gcf,'-property','FontSize'),'FontSize',11);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

% Export png
exportgraphics(gca,['./fig/chess/chessSet-hline-' c.name '.png']);

end
