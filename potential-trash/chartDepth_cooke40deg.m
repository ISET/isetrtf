%% Script with charts at different depths 
% This script is written as part of a class project on autofocus  psych221
% For Itamar
%
% The aim is to generate a scene with objects at controllable depths
% Supervised by Thomas Goossens

ieInit;




%% Ray trace optiosn
nbRaysPerPixel=2000;

rtf=jsonread('cooke40deg-zemax-poly5-raytransfer.json');
lensThickness_mm = rtf.thickness;

filmdistance_mm=51.915 % mm
filmdiagonal_mm=60*2;
filmdiagonal_mm=60*2/100*2;



% Positions of chart as measured from the film
distanceFromLensToObject_meter = [0.3 0.5]
scaleFactors = [0.03 0.4]
distancesFromFilm_meter = (filmdistance_mm+lensThickness_mm)/1000+distanceFromLensToObject_meter



%% Create A camera for each polynomial
cameras={}

degrees=[3 5 10 12]
degrees=[1:12];
for degree=degrees
lensname=['cooke40deg-zemax-poly' num2str(degree) '-raytransfer']
cameraRTF = piCameraCreate('raytransfer','lensfile',[lensname '.json']);
cameraRTF.filmdistance.type='float';
cameraRTF.filmdistance.value=(filmdistance_mm)/1000;
cameras{end+1} = cameraRTF;
end





%% Loop over different chart distances, as measured from film
for c=1:numel(cameras)
for i=1:numel(distancesFromFilm_meter)
    disp(['Render Camera ' num2str(c) ' position ' num2str(i)])
    
    % Build the scene
    thisR=piRecipeDefault('scene name','flatsurface');
    
    % Add chart at depth
    positionXY = [0 0];% Center
    scaleFactor=scaleFactors(i);
    piChartAddatDistanceFromFilm(thisR,distancesFromFilm_meter(i),positionXY,scaleFactor);
     
%     % Change camera look so edge of cube is in the center
%     thisR.lookAt.from([1 3 ]) = 0;
%     thisR.lookAt.from([1]) = -643.26/2;
%     thisR.lookAt.to = thisR.lookAt.from + [0 -1 0]
%     
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
    thisR.lights{1}.type='distant'
    
    % Set identical camera setup
    thisR.set('camera',cameras{end});
    thisR.set('spatial resolution',[2*500 1]);
    thisR.set('rays per pixel',nbRaysPerPixel);
    thisR.set('film diagonal',filmdiagonal_mm); % Original
    
%         % Change camera look so edge of cube is in the center
%     thisR.lookAt.from([1 3 ]) = 0;
%     thisR.lookAt.from([1]) = -643.26/2;
%     thisR.lookAt.to = thisR.lookAt.from + [0 -1 0]
%     
    thisR.set('node', '0003ID_Cube_B', 'scale', [1 0.01 1]);  % Rescale as desired

    
    % Write and render
    piWrite(thisR);
    [oi log] = piRender(thisR,'render type','radiance');

    % Estimate noise for a patch around the center
    edgePBRT=double(oi.data.photons(end,end/2-200:end/2+200,1)); % Take horizontal line in center
    edgePBRT=edgePBRT/max(mean(edgePBRT));
    renderNoiseFloor=rms(1-edgePBRT)
figure;plot(double(oi.data.photons(end,:,1)))
%% Compare edge smoothing at different depths

pause(1)
load esf-cooke40deg.mat
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
smooth = @(x)conv(x,[1 1 1 1 1]/5,'same' )
figure(5);clf; hold on
for i=1:numel(distancesFromFilm_meter)
    %subplot(2,3,i);hold on
    
      for d=1:(size(oiList,1))
subplot(numel(degrees),numel(distancesFromFilm_meter),i+(d-1)*numel(distancesFromFilm_meter));hold on
%           % Omni
%     oi=oiList{1,i} ;   edgePBRT=oi.data.photons(end,:,1); % Take horizontal line in center
%    plot(pixels,edgePBRT/max(smooth(edgePBRT)),'color',color(35*i,:))
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
   xlim([-80 100])
   end
end
legend('PBRT omni','PBRT RTF','ZEMAX')



%% Single figure all degrees



load esf-cooke40deg.mat
color=hot;
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
smooth = @(x)conv(x,[1 1 1 1 1]/5,'same' )
figure(5);clf; hold on
for i=1:numel(distancesFromFilm_meter)
    %subplot(2,3,i);hold on
    
      for d=(size(oiList,1))

    oi=oiList{d,i} ;   edgePBRT=oi.data.photons(end,:,1); % Take horizontal line in center
    plot(pixels,edgePBRT/max(smooth(edgePBRT)),'color',color(30*d,:),'linewidth',2)
   
   
   % ESF zemax
   lsfi=lsf{i};
   plot(flip(lsfi(:,1)),lsfi(:,3),'color','k','linestyle',':','linewidth',2)
   labels{i}=[num2str(distancesFromFilm_meter(i)) ' m'];
   title(['poly:' num2str(degrees(d)) ' ' num2str(distancesFromFilm_meter(i)) ' m']);
   xlabel('micron')
   xlim([-60 100])
   end
end
legend('PBRT omni','PBRT RTF','ZEMAX')



%% Test cross correlation metric
filmWidth=oiGet(oi,'width','mm');
pixels = 1e3*linspace(-filmWidth/2,filmWidth/2,oiGet(oi,'cols'))
for i=1:numel(distancesFromFilm_meter)
      for d=1:(size(oiList,1))

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
   peakCorr(d,i) = errormetric(edgeResampled-edgeZemax);
   
   
      end
end

%renderNoiseFloor = errormetric(1-edgeResampled(edgeZemax==1));
%renderNoiseFloor=errormetric(edgeResampled-smooth(edgeResampled))
fig=figure; hold on
    fig.Position=[680 757 184 209]
    

for p=1:numel(distancesFromFilm_meter)
    h(p)=plot(degrees,peakCorr(:,p),'linewidth',2,'color',color(45*p,:));
    line([degrees(1) degrees(end)],[renderNoiseFloor renderNoiseFloor],'color','k','linewidth',2,'linestyle','--')
   
end
xlabel('Polynomial Degree')

% Figure styles
box on

legh=legend([h(1) h(2)],['$d=$' num2str(distanceFromLensToObject_meter(1)) '$\,$m'],[num2str(distanceFromLensToObject_meter(2)) '$\,$m'])
legh.Box = 'off' ;

set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');