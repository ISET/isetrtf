%% Co%% Compare rendered chess set scene for known lens and its corresponding RTF.
%
% Lens: Double Gauss 28deg from zemax sample library

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces
thisR=piRecipeDefault('scenename','chess set')

% Choose docker container
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



%% Set camera position

filmdistance_mm=80; 



%% Define cameras
sensordiagonal_mm=100;
% OMNI (known lens) camera
cameraOmni = piCameraCreate('omni','lensfile','dgauss.28deg-zemax.json');
cameraOmni.filmdistance.type='float';
cameraOmni.filmdistance.value=filmdistance_mm*1e-3;
cameraOmni = rmfield(cameraOmni,'focusdistance');
cameraOmni.aperturediameter.value=2*10.229;
cameraOmni.aperturediameter.type='float';


% RTF camera
rtffile=['dgauss28deg-zemax-poly6-raytransfer.json'];
cameraRTF = piCameraCreate('raytransfer','lensfile',rtffile);
cameraRTF.filmdistance.value=filmdistance_mm*1e-3;


%% Rendering Options
thisR.set('pixel samples',300)
thisR.set('film diagonal',sensordiagonal_mm,'mm');
resolution=300;
thisR.set('film resolution',resolution*[1 1])
    

% Path integrator, only use one wavelength
thisR.integrator.subtype='path'
thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value = 1


%% Render images

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




%% Export images to PNG files
for i=1:numel(oiList)
    oi=oiList{i}{1};
    oiWindow(oi);
    exportgraphics(gca,['./fig/chessSet-' oi.name '.png'])
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
exportgraphics(gca,['./fig/chessSet-hline-dgauss28deg.png'])


