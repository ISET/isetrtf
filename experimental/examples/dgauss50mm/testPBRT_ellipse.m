%% Dgauss 50mm test with PBRT using ellipse PassNoPass
clear
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


thisR=piRecipeDefault('scene','ChessSet')
%thisR=piRecipeDefault('scene','flatSurface'); thisR.set('light','#1_Light_type:point','type','distant')



%% Set camera position

%% Set camera position

filmZPos_m           = -0.9;
thisR.lookAt.from(3)= filmZPos_m;
distanceFromFilm_m   = 1.469+50/1000





%% FIlm distance as provided by Google


%load('p4aLensVignetFrontCam_p0286s.mat')


filmdistance_mm=37.959;
pixelpitch_mm=1.4e-3; 

%sensordiagonal_mm=sqrt(sensorwidth_mm^2+sensorheight_mm^2)



%% Compare  circls and ellipse approach, for now this runs on separate docker images
label{1}='omni'
cameras{1} = piCameraCreate('omni','lensfile','dgauss.22deg.50.0mm_aperture6.0.json');
cameras{1}.aperturediameter.type='float';
cameras{1}.aperturediameter.value=7
cameras{1}.filmdistance.type='float';
rmfield(cameras{1},'focusdistance');


thisDocker{1} = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';

label{2}='circles'
cameras{2} = piCameraCreate('raytransfer','lensfile','dgauss.22deg.50.0mm_aperture6.0.json-filmtoscene-raytransfer.json');
cameras{2}.aperturediameter.type='float';
cameras{2}.aperturediameter.value=7
thisDocker{2} = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';

label{3}='ellipse'
cameras{3} = piCameraCreate('raytransfer','lensfile','dgauss.22deg.50.0mm_aperture6.0-diaphragm7mm-raytransfer.json');


thisDocker{3} = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';


% Linear
%label{2}='linear'
%cameras{2} = piCameraCreate('raytransfer','lensfile','pixel4a_linear-frontcamera-filmtoscene-raytransfer.json')



for c=1:numel(cameras)
    
    cameraRTF = cameras{c};
    cameraRTF.filmdistance.value=filmdistance_mm/1000;
    
    thisR.set('pixel samples',100);
    thisR.set('film diagonal',40,'mm');
    thisR.set('film resolution',[300 300]);
    
    
    thisR.integrator.subtype='path';
    
    thisR.integrator.numCABands.type = 'integer';
    thisR.integrator.numCABands.value =1;
    
    
    
    % Render
    
    % % RTF
    thisR.set('camera',cameraRTF);
    piWrite(thisR);
    
    
    %
    
    [oiTemp,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker{c});
    oiTemp.name=label{c};
    oi{c} =oiTemp;
    
    
    oiWindow(oiTemp);
    pause(2)
    %exportgraphics(gca,['./fig/chesset_pixel4a' label{c} '.png'])
  %  exportgraphics(gca,['./fig/chesset_pixel4arear_quick' label{c} '.png'])
end
%% Compare diagional
maxnorm=@(x)x/max(x);
figure; hold on
for i=1:numel(oi)
    plot(maxnorm(diag(oi{i}.data.illuminance)));
end
xlabel('pixels on diagonal')
ylabel('illuminance')
legend(label)


return
%% Vignetting plot

fig=figure(10);clf;hold on
fig.Position=[475 270 978 396];
for p=1:numel(oi)
    profile=medfilt1(oi{p}.data.photons(end/2,:,1),5);
    profile=profile/max(profile);
    x=linspace(-sensorwidth_mm/2,sensorwidth_mm/2,numel(profile));
    plot(x,profile,'-','linewidth',2);
end

pixels=linspace(-sensorwidth_mm/2,sensorwidth_mm/2,size(pixel4aLensVignetFrontCamp0286s,2));

% Plot pixels
plot(pixels,pixel4aLensVignetFrontCamp0286s(end/2,:),'k--','linewidth',2);


exitpupil=2.2
plot(x,cosd(atand(x/exitpupil)).^4,'linewidth',2);


legend('PBRT linear','PBRT with pupilwalking','Measurement','Expected cosine fourth','location','best')

set(gca,'Fontsize',12)
xlabel('Offcenter (mm)')
xlim([-1 1]*sensorwidth_mm/2)


return



%% Manual loading of dat file


label={};path={};

%label{end+1}='linear';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront_linear.dat';
%label{end+1}='nonlinear';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront_nonlinear.dat';
label{end+1}='ellipse'; path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/cornellbox/rtf.dat'

for p=1:numel(path)
    oi{p} = piDat2ISET(path{p}, 'wave', 400:10:700, 'recipe', thisR);
    oi{p}.name =label{p}
    
    oiWindow(oi{p});
    oiSet(oi{p},'gamma',0.8)
    data{p}=oi{p}.data.photons;
    
    ax = gca;
    
end



return
%% Vignetting plot

fig=figure(10);clf;hold on
fig.Position=[475 270 978 396];
for p=1:numel(path)
    profile=medfilt1(oi{p}.data.photons(end/2,:,1),5);
    profile=profile/max(profile);
    x=linspace(-sensorwidth_mm/2,sensorwidth_mm/2,numel(profile));
    plot(x,profile,'-','linewidth',2);
end

pixels=linspace(-sensorwidth_mm/2,sensorwidth_mm/2,size(pixel4aLensVignetFrontCamp0286s,2));

% Plot pixels
plot(pixels,pixel4aLensVignetFrontCamp0286s(end/2,:),'k--','linewidth',2);


exitpupil=2.2
plot(x,cosd(atand(x/exitpupil)).^4,'linewidth',2);


legend('PBRT linear','PBRT with pupilwalking','Measurement','Expected cosine fourth','location','best')

set(gca,'Fontsize',12)
xlabel('Offcenter (mm)')
xlim([-1 1]*sensorwidth_mm/2)