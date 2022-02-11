
%% Plot relative illumination DGAUSS 50mm lens compare Omni with RTF

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

thisR=piRecipeDefault('scenename','chess set')
%% Set camera position

filmdistance_mm=160;

%filmZPos_m=-0.6;filmdistance_mm=80; thisR.lookAt.from(3)=filmZPos_m;


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



%% Light should be add infinitey to avoid additional vignetting nintrouced
% by light falloff
light =  piLightCreate('distant','type','distant')

% thisR     = piLightDelete(thisR, 'all');
%thisR.set('light', 'add', light);


%% Loop ver Different aperture sizes





a=1
% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','tessar-zemax.json');
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm*1e-3;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=2*8.111;
cameraOmni.aperturediameter.type='float';
%cameraOmni = rmfield(cameraOmni,'aperturediameter');



rtffile=['tessar-zemax-poly13-raytransfer.json'];
cameraRTF = piCameraCreate('raytransfer','lensfile',rtffile);
%cameraRTF = piCameraCreate('raytransfer','lensfile','/home/thomas42/Documents/MATLAB/libs/isetlens/local/dgauss.22deg.50.0mm_aperture6.0.json-raytransfer.json')
cameraRTF.filmdistance.value=filmdistance_mm*1e-3;
%cameraRTF.aperturediameter.value=aperturediameters(a);
%cameraRTF.aperturediameter.type='float';
thisR.set('pixel samples',300)



thisR.set('film diagonal',2*150,'mm');
resolution=5*300;
thisR.set('film resolution',resolution*[1 1])
    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1


% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
%chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar
% Omni
disp('---------Render Omni----------')
thisR.set('camera',cameraOmni);
[oi,resultsOmni] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['Omni']
oiOmni{a}=oi;


% RTF
disp('---------Render RTF-----------')
thisR.set('camera',cameraRTF);
[oi,resultsRTF] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
oi.name=['RTF']
oiRTF{a}=oi;



oiList = {oiOmni,oiRTF};




%% Generate images
for i=1:numel(oiList)
    oi=oiList{i}{1};
    oiWindow(oi);
%    exportgraphics(gca,['./fig/chessSet-tessar-' oi.name '.png'])
end


%% Compare horizontal line and generate PNG file
fig=figure; hold on
 fig.Position=[687 474 623 146]
colorpass = [0 49 90]/100;    
color2 = [0.83 0 0];
colors=[colorpass;color2];
colororder(colors);
for i=1:numel(oiList)
    oi=oiList{i}{1};
    
    % Sum up across all 31 wavelengths in the photons datacube.
    hline=sum(oi.data.photons(end/1.5,:,:),3);
    hline=hline/max(hline);
    plot(hline,'linewidth',2)
    
end


% Format figure
xlabel('Pixel')
ylabel('Irradiance (a.u.)')
set(gca,'Position',[0.1300 0.2614 0.7750 0.4978])

% Format legend
legh=legend('Known Lens', 'RTF');
legh.Orientation='horizontal';
legh.Box='off';
legh.Position= [0.3385 0.8155 0.3394 0.1479];

% Make all text latex formatted
set(findall(gcf,'-property','FontSize'),'FontSize',11);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

% Export png
exportgraphics(gca,['./fig/chessSet-hline-tessar.png'])
