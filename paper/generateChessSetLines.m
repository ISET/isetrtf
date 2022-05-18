%% Compare rendered horizontal line across chesset scene for known lens and its corresponding RTF.
% This script renders a single pixel row of chess set scenes for a collection of lenses.  The
% scene is rendered for both the exact lens model and using a ray-transfer
% function.
% Because we render only one pixel row we can set the number or rays per
% pixel to 20000 to minimize rendering noise.


ieInit
if ~piDockerExists, piDockerConfig; end



config={};

% Colors for plottinng
colors=[0 0.49 0.90;0.83 0 0];


%% RTF DEFINITIONS 
% Below are listed all configurations to be simulated. Configurations are
% saved in cell array of structs.
%%
i=numel(config)+1;
config{i}.name='tessar';
config{i}.lensfile='tessar-zemax.json';
config{i}.filmdistance_mm=160;
config{i}.rtffile= 'tessar-zemax-poly13-raytransfer.json';
config{i}.sensordiagonal_mm=450;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*8.111;
config{i}.hline = 0.5; % proportion of filmresolution



%%
i=numel(config)+1;
config{i}.name='wideangle200deg';
config{i}.lensfile='wideangle200deg-automatic-zemax.json';
config{i}.filmdistance_mm=2.004;
config{i}.rtffile= 'wideangle200deg-circle-zemax-poly11-raytransfer.json';
config{i}.sensordiagonal_mm=3;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*0.62000000;
config{i}.hline = 0.66; % proportion of filmresolution
 %From/to % Camera position Offset because else the horizontal line goes
 %through a bright window which obscures all the other details
config{i}.cameraposition = [0 0.07 -0.3; 0.35 0.07 0.5];



%%
i=numel(config)+1;
config{i}.name='wideangle200deg-offset0';
config{i}.lensfile='wideangle200deg-automatic-zemax.json';
config{i}.filmdistance_mm=2.004;
config{i}.rtffile= 'wideangle200deg-offset0-circle-zemax-poly11-raytransfer.json';
config{i}.sensordiagonal_mm=3;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*0.62000000;
config{i}.hline = 0.66; % proportion of filmresolution
 %From/to % Camera position Offset because else the horizontal line goes
 %through a bright window which obscures all the other details
config{i}.cameraposition = [0 0.07 -0.3; 0.35 0.07 0.5];


%%
i=numel(config)+1;
config{i}.name='petzval';
config{i}.lensfile='petzval-zemax.json';
config{i}.filmdistance_mm=45;
config{i}.rtffile= 'petzval-5mminput-zemax-poly12-circles-raytransfer.json';
config{i}.sensordiagonal_mm=150;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=28*2;
config{i}.hline = 0.5; % proportion of filmresolution



%%
i=numel(config)+1;
config{i}.name='cooke40deg';
config{i}.lensfile='cooke40deg-zemax.json';
config{i}.rtffile= 'cooke40deg-zemax-poly12-raytransfer.json';
config{i}.filmdistance_mm=50;
config{i}.sensordiagonal_mm=100;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*5;
config{i}.hline = 0.5; % proportion of filmresolution




%%
i=numel(config)+1;
config{i}.name='dgauss28deg';
config{i}.lensfile='dgauss.28deg-zemax.json';
config{i}.filmdistance_mm=80;
config{i}.rtffile= 'dgauss28deg-zemax-poly8-raytransfer.json';
config{i}.sensordiagonal_mm=150;  % original 100
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*10.229;
config{i}.hline = 0.5; % proportion of filmresolution


%%
i=numel(config)+1;
config{i}.name='inversetelephoto';
config{i}.lensfile='inversetelephoto-zemax.json';
config{i}.rtffile= 'inversetelephoto-zemax-poly8-raytransfer.json';
config{i}.filmdistance_mm=1.2;
config{i}.sensordiagonal_mm=2.5;
config{i}.filmresolution=4000;
config{i}.raysperpixel=20000;
config{i}.omni_aperturediameter_mm=2*0.166;
config{i}.hline = 0.5; % proportion of filmresolution

%% Loop over all configurations and save the rendered image for alter

for ic=1:numel(config)
    c=config{ic};
    % The chess set with pieces
    thisR=piRecipeDefault('scenename','chess set')
    
    % Choose docker container
    thisDocker = 'vistalab/pbrt-v3-spectral:latest';
    
    
    if(isfield(c,'cameraposition')) % WHen given, move the default camera
        % Set camera and camera position
        thisR.lookAt.from= c.cameraposition(1,:);
        thisR.lookAt.to= c.cameraposition(2,:);
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
    cameraOmni.simpleweighting.type='bool'
    cameraOmni.simpleweighting.value='false'; % This is necessary because the RTF does not implement the simple weighting algorithm
    
    % RTF camera
    
    cameraRTF = piCameraCreate('raytransfer','lensfile',c.rtffile);
    cameraRTF.filmdistance.value=c.filmdistance_mm*1e-3;
    
    
    % Rendering Options

    c.raysperpixel = 20000;
    thisR.set('pixel samples',c.raysperpixel)
    thisR.set('film diagonal',c.sensordiagonal_mm,'mm');
    
    thisR.set('film resolution',[c.filmresolution 1])
    
    
    
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
    
    
    % Estimate Rendering Noise with OMNI
    
    thisR=piRecipeDefault('scene','flatSurface');
    thisR.set('pixel samples',c.raysperpixel)
    thisR.set('film diagonal',c.sensordiagonal_mm,'mm');
    thisR.set('film resolution',c.filmresolution*[1 1])
    thisR.set('film resolution',[4000 1])
    % Set Light that is all around the world, so do not depend on the size of the target
    % This is especially important for wide angle lenses
    thisR.set('light','#1_Light_type:point','type','infinite');
    
    disp('---------Render Omni for estimating rendering noise----------')
    thisR.set('camera',cameraOmni);
    [oi,resultsOmniNoise] = piWRS(thisR,'render type','radiance','dockerimagename',thisDocker);
    oi.name=['noise']
    oiNoise{ic}=oi;
    
    
end



%save('./fig/chess/data.mat','oiRTF','oiOmni')

%% Generate plots
for ic=1:numel(config)
    c=config{ic};
    oiList={oiOmni{ic} oiRTF{ic} }
    % Export images to PNG files

    
    % Compare horizontal line and generate PNG file
    fig=figure; hold on
    fig.Position=[687 474 623 146]
    colororder(colors);
    
    
    clear hline

    for i=1:2
        oi=oiList{i};
        
        % Sum up across all 31 wavelengths in the photons datacube.
        hline(:,i)=sum(oi.data.photons(round(c.hline*end),:,:),3);
        hline(:,i)=hline(:,i)/max(hline(1:end,i)); % Normalize because iset3d (piReadDAT) rescales the photon counts for RTF due to some wrong default values (fnumber and focal length not known)0
        plot(hline(:,i),'linewidth',2)
        ylim([0 1])

    end
    
    
    % Add a text indicating the RMSE error
    % ISET3D causes some rescaling of the number of photons for the RTF, so we first peak
    % normalize before comparing the error.
    maxnorm=@(x)x/max(x);
    A=maxnorm(hline(1:end,1));
    B=maxnorm(hline(1:end,2));
    RMS(ic) = rms(A-B)
    text(3400,0.9,sprintf('RMSE: %0.3f',RMS(ic)))
    
    
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