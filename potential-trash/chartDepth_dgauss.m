%% Script with charts at different depths 
% This script is written as part of a class project on autofocus  psych221
% For Itamar
%
% The aim is to generate a scene with objects at controllable depths
% Supervised by Thomas Goossens

ieInit;




%% Ray trace optiosn
nbRaysPerPixel=2000;

rtf=jsonread('dgauss28deg-zemax-poly5-raytransfer.json');
lensThickness_mm = rtf.thickness;

filmdistance_mm=67.768 % mm
filmdiagonal_mm=150/100;



% Positions of chart as measured from the film
distanceFromLensToObject_meter = [1 1.2]
distanceFromLensToObject_meter = [1 1.2]
distancesFromFilm_meter = (filmdistance_mm+lensThickness_mm)/1000+distanceFromLensToObject_meter



%% Create A camera for each polynomial
cameras={}
degrees = [3:7];
degrees=[3 7]

for degree=degrees
lensname=['dgauss28deg-zemax-poly' num2str(degree) '-raytransfer']
cameraRTF = piCameraCreate('raytransfer','lensfile',[lensname '.json']);
cameraRTF.filmdistance.type='float';
cameraRTF.filmdistance.value=(filmdistance_mm)/1000;
cameras{end+1} = cameraRTF;
end



%% Add omni model for comparison

 %% Create the two cameras and choose a lens
 lensname='dgauss.28deg-zemax'
 cameraOmni = piCameraCreate('omni','lensfile',[lensname '.json']);
 cameraOmni.filmdistance.type='float';
 cameraOmni.filmdistance.value=filmdistance_mm/1000;
 cameraOmni = rmfield(cameraOmni,'focusdistance');
 cameraOmni.aperturediameter.value=2*10.229;

 
 cameras{end+1} = cameraOmni;





%% Loop over different chart distances, as measured from film
for c=1:numel(cameras)
for i=1:numel(distancesFromFilm_meter)
    disp(['Render Camera ' num2str(c) ' position ' num2str(i)])
    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
    % Add chart at depth
    positionXY = [0 0];% Center
    scaleFactor=0.1; % adjust to your liking
    piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(i),positionXY,scaleFactor);
        
    thisR.set('camera',cameras{c});
    thisR.set('spatial resolution',[2*500 1]);
    thisR.set('rays per pixel',nbRaysPerPixel);
    thisR.set('film diagonal',filmdiagonal_mm); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi log] = piRender(thisR,'render type','radiance');
    oi.name=['Chart distance from film: ' num2str(distancesFromFilm_meter(i))]
    oiList{c,i}=oi;
    oiWindow(oi)
end

end

%% Determine Render noise floor
    disp(['Estimate RenderNoise Floor'])
    
    % Build the scene with white diffuse flat surface
    thisR=piRecipeDefault('scene name','flatsurface');

    % Set identical camera setup
    thisR.set('camera',cameras{end});
    thisR.set('spatial resolution',[2*500 1]);
    thisR.set('rays per pixel',nbRaysPerPixel);
    thisR.set('film diagonal',filmdiagonal_mm); % Original
    
    
    % Write and render
    piWrite(thisR);
    [oi log] = piRender(thisR,'render type','radiance');

    % Estimate noise for a patch around the center
    edgePBRT=double(oi.data.photons(end,end/2-200:end/2+200,1)); % Take horizontal line in center
    edgePBRT=edgePBRT/max(mean(edgePBRT));
    renderNoiseFloor=rms(1-edgePBRT)

%% Compare edge smoothing at different depths

pause(1)
load esf-dgauss28deg.mat
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
smooth = @(x)conv(x,[1 1 1 1 1]/5,'same' )
figure(5);clf; hold on
for i=1:numel(distancesFromFilm_meter)
    %subplot(2,3,i);hold on
    
    for d=1:numel(degrees)
        subplot(numel(degrees),numel(distancesFromFilm_meter),i+(d-1)*numel(distancesFromFilm_meter));hold on
        % Omni
        oi=oiList{end,i} ;   edgePBRT=oi.data.photons(end,:,1); % Take horizontal line in center
        plot(pixels,edgePBRT/max(smooth(edgePBRT)),'color',color(35*i,:),'linestyle','--')
        %
        % RTF
        
        
        oi=oiList{d,i} ;   edgePBRT=oi.data.photons(end,:,1); % Take horizontal line in center
        plot(pixels,edgePBRT/max(smooth(edgePBRT)),'color',color(1*i,:))
        
        
        % ESF zemax
        lsfi=lsf{i};
        plot(flip(lsfi(:,1)),lsfi(:,3),'color',color(35*i,:),'linestyle',':','linewidth',2)
        labels{i}=[num2str(distancesFromFilm_meter(i)) ' m'];
        title(['poly:' num2str(degrees(d)) ' ' num2str(distancesFromFilm_meter(i)) ' m']);
        xlabel('micron')
        xlim([-500 500])
    end
end
legend('PBRT omni','PBRT RTF','ZEMAX')


%% Test cross correlation metric
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
for i=1:numel(distancesFromFilm_meter)
    for d=1:numel(degrees)
        
        % ESF zemax
        lsfi=lsf{i};
        pixelsZemax = lsfi(:,1);
        edgeZemax=flip(lsfi(:,3));
        
        % RTF
        oi=oiList{d,i} ;
        edgePBRT=double(oi.data.photons(end,:,1)); % Take horizontal line in center
        edgePBRT=edgePBRT/max(smooth(edgePBRT));
        %Resample rtf to same grid as zemax
        edgeResampled=interp1(pixels,edgePBRT,pixelsZemax);
        
        %Calcualte cross correlation excluding the part where saturation is
        %reached because the longer this region, the higher the correlation will
        %be.
        partForComparison=~(edgeZemax==1);
        
        [correlations,lags]=crosscorr(partForComparison.*edgeResampled,partForComparison.*edgeZemax);
        %[correlations,lags]=crosscorr(diff(edgeResampled),diff(edgeZemax));
        peakCorr(d,i) = max(correlations);
        
        % Compare width of ESF
        
        errormetric = @(x)rms(x);
        peakCorr(d,i) = errormetric(edgeResampled-edgeZemax)
        
        
    end
end

%renderNoiseFloor = errormetric(1-edgeResampled(edgeZemax==1));
%renderNoiseFloor=errormetric(edgeResampled-smooth(edgeResampled))
figure; hold on
for p=1:numel(distancesFromFilm_meter)
    plot(degrees,peakCorr(1:numel(degrees),p),'linewidth',2,'color',color(15*p,:));
    line([degrees(1) degrees(end)],[renderNoiseFloor renderNoiseFloor],'color','k','linewidth',2,'linestyle','--')
end
%ylim([0 1])
