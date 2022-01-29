
clear

lensNameNoJsonExtension = 'dgauss.22deg.50.0mm';
diaphragmDiameter_mm=7;
maxRadiusMargin=2
offsetinput=0.01;
offsetoutput=0.01;
intersectionPlaneDistance=3;
%% Lens name and propertievs
lensFileName= [lensNameNoJsonExtension, '.json'];
lens=lensReverse(lensFileName);
radius_firstsurface=lens.surfaceArray(1).apertureD/2;

% If diaphraghm is not set, set it to size on file
if(isnan(diaphragmDiameter_mm))
    diaphragmDiameter_mm=lens.get('diaphragmdiameter'); 
end

% Generate ray pairs
reverse = true; 
maxRadius = 10.53
minRadius = 0;
offset=0.01;
offset_sensorside=offset;
offset_objectside=offset; %%mm



[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensFileName, 'visualize', false,...
    'n radius samp', 8, 'elevation max', 40,...
    'nAzSamp',300,'nElSamp',500,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset_objectside),'diaphragmdiameter',diaphragmDiameter_mm);




%%

%% Prepare distances for inputoutputplane Z position calculation
% By convention z=0 at the output side vertex of the lens
lensThickness_mm=lens.get('lens thickness');

frontvertex_z=-lensThickness_mm;  % By convention
planes.input=frontvertex_z-offsetinput;
planes.output=offsetoutput;


%% Preprocess input output rays

% Only keep the rays that passed the lens (output ray is not NAN)
passedRays=~isnan(oRays(:,1));
iRays=iRays(passedRays,:);
oRays=oRays(passedRays,:);

%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(iRays,planes.input,'circleplanedistance',intersectionPlaneDistance);
[radii,centers] = vignettingFitEllipses(pupilShapes);



%% Colors
colors=hot;
colornopass = colors(70,:);
colorpass = colors(160,:);
%% Visualize
figure;
subplot(211)
plot(positions,radii','.-','markersize',10,'linewidth',2,'color',colorpass);
title('Ellipse Radii');
legend('X','Y');
subplot(212)
plot(positions,centers','.-','markersize',10,'linewidth',2,'color',colorpass);
title('Ellipse Centers');
legend('X','Y');


%%

% Show pupil sampling
fig=figure;
fig.Position=[680 420 737 319]
nbPos = numel(positions);
for p=1:numel(positions)
    subplot(2,4,p);
    hold on
    pupil=pupilShapes{p};
    hpupil=scatter(pupil(1,:),pupil(2,:),'.')
    set(hpupil,'cdata',colorpass);
    
    %hellipse=drawellipse('center',[centers(1,p) centers(2,p)],'semiaxes',[radii(1,p) radii(2,p)],...
    %    'color','k','markersize',0.01,'faceAlpha',0)
    
    % Draw ellipse
    t = linspace(0,2*pi,200);
    ellipse=centers(:,p)+radii(:,p).*[sin(t);cos(t)];
    hellipse=plot(ellipse(1,:),ellipse(2,:),'k','linewidth',2)
    
    title(['$\mathbf{\rho=}$\textbf{' num2str(round(positions(p),1)) ' mm}']);
        
    xlim([-1 1]*1.2)
    ylim(centers(:,p)'+[-1 1]*1.2)
    axis off;
    
     ax=gca;
     ax.Position(3:4)= [0.1566 0.29];

    
end

legh=legend([hpupil hellipse],'Intersections','Pass/NoPass ellipse')
legh.Box='off';
legh.Orientation='horizontal';
legh.Position=[0.2520 0.9326 0.4457 0.0767]
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

exportgraphics(gcf,'./fig/passnopass_ellipses.png')





