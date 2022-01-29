%% Generate Figures showing the elliptical fit of the ray pass function

clear
% Configuration variables 
% each lens has its own requirements and configurations
zemaxDataFile={};
lensName={};
offset_sensorside={};
offset_objectside={};
lensThickness={};
disable_dz_polynomial={}; % Set to true for planar surfaces, false for spherical surfaces
polynomialDegrees={};% Polynomial degrees to fit for this lens

%%
%%%% Double gauss 28deg lens 
%%% Tessar lens
lensName{end+1}='tessar-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/tessar-rayaim-novignetfactors.txt';
offset_sensorside{end+1}=0.01;
offset_objectside{end+1}=0.01; %%mm
lensThickness{end+1}=16.4;
disable_dz_polynomial{end+1}=true;
polynomialDegrees{end+1}=[1:13];  


%%%% Cooke 40deg
lensName{end+1}='cooke40deg-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/cooke40deg-primaryWL1.txt';
offset_sensorside{end+1}=0.01;
offset_objectside{end+1}=0.01; %%mm
lensThickness{end+1}=17.96897;
disable_dz_polynomial{end+1}=true;
polynomialDegrees{end+1}=[1:12];  

%%%% Petzval
lensName{end+1}='petzval-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/petzval-primaryWL1.txt';
offset_sensorside{end+1}=0.01;
offset_objectside{end+1}=0.01; %%mm
lensThickness{end+1}=143.8312;
disable_dz_polynomial{end+1}=true;
polynomialDegrees{end+1}=[1:8];  


%%% Inversetelephoto
lensName{end+1}='inversetelephoto-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/inversetelephoto.txt';
offset_sensorside{end+1}=0.1;
offset_objectside{end+1}=0.1; %%mm
lensThickness{end+1}=1.30140;
disable_dz_polynomial{end+1}=true;
polynomialDegrees{end+1}=[1:8];  


%%%% Double gauss 28deg lens 
lensName{end+1}='dgauss28deg-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/dgauss28deg.txt';
offset_sensorside{end+1}=0.01;
offset_objectside{end+1}=0.01; %%mm
lensThickness{end+1}=75.67388;
disable_dz_polynomial{end+1}=true;
polynomialDegrees{end+1}=[1:7];  

%%%%% Wide angle lens 200deg  with spherical output surface
lensName{end+1}='wideangle200deg-circle-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/wideangle200deg-primaryWL1.txt';
offset_sensorside{end+1}=2.003;
offset_objectside{end+1}=2; %%mm
lensThickness{end+1}=14.19057;
disable_dz_polynomial{end+1}=false;
polynomialDegrees{end+1}=[2:13];  



%%

for i=1:numel(lensName)
  % Load input output rays
    X=dlmread([zemaxDataFile{i}],'\s',1);
    
    
    % Extract input and output rays from matix
    iRays=X(:,[3 5 6]);
    oRays=X(:,[8 9 10 11 12 13]);
    
    % By convention in our implementation,Z output values need to be
    % measured from rear vertex so we need to.
    % However it is an easy mistake to forget to set the zemax global
    % coordinate system to last vertex of the reverse lens.
    % Hence this piece of code  automatically corrects the z values accordingly
    
    if(max(oRays(:,3))==offset_objectside{i})
        % This branch assumes that the global coordinate was set at the
        % last lens surface. The Z coordinate hence should be the distance of
        % the output plane from the last surface.
        % The maximal Z value is used to account for spherical output surfaces
        oRays(:,3)= oRays(:,3); % No correction needed
    else
        % We apply this translation to put the coordinate axis at the last lens
        % surface.
        oRays(:,3)= oRays(:,3) +(offset_objectside{i}-max(oRays(:,3)));
        
    end
    

%% Preprocess input output rays

% Only keep the rays that passed the lens (output ray is not NAN)
passedRays=~isnan(oRays(:,1));
iRays=iRays(passedRays,:);
oRays=oRays(passedRays,:);


%% Prepare distances for inputoutputplane Z position calculation
% By convention z=0 at the output side vertex of the lens
lensThickness_mm=lensThickness{1};

frontvertex_z=-lensThickness_mm;  % By convention
planes.input=frontvertex_z-offset_sensorside{1};
planes.output=offset_objectside{1};
intersectionPlaneDistance=17 % Some arbitrary distance to choose for the intersection plane
%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(iRays,planes.input,'circleplanedistance',intersectionPlaneDistance);
[radii,centers] = vignettingFitEllipses(pupilShapes);



%% Color style
colors=hot;
colornopass = colors(70,:);
colorpass = colors(160,:);

%% Visualize how the radii and centers changes with the position on the input plane
figure;
subplot(211)
plot(positions,radii','.-','markersize',10,'linewidth',2,'color',colorpass);
title('Ellipse Radii');
legend('X','Y');
subplot(212)
plot(positions,centers','.-','markersize',10,'linewidth',2,'color',colorpass);
title('Ellipse Centers');
legend('X','Y');


%% Show pupil sampling and ellipse on one graph
fig=figure;
fig.Position=[680 420 737 319]
nbPos = numel(positions);

% The number of positions can be arbitrary large depending on the size of
% the input dataset from zemax. To span the whole range with 8 subplots, we subsample uniformly 
%  at 8 positions.
pselection=round(linspace(1,numel(positions),8));

for p=1:numel(pselection)
    subplot(2,4,p);
    hold on
    pupil=pupilShapes{pselection(p)};
    hpupil=scatter(pupil(1,:),pupil(2,:),'.')
    set(hpupil,'cdata',colorpass);
         
    % Draw ellipse using polar coordinates
    theta = linspace(0,2*pi,200);
    ps=pselection(p);
    ellipse=centers(:,ps)+radii(:,ps).*[sin(theta);cos(theta)];
    hellipse=plot(ellipse(1,:),ellipse(2,:),'k','linewidth',2,'linestyle','--')
    
    
    % Choose the boundaries of the axes to  so that the circle is always
    % centered. We only translate the coordinate system to keep the same
    % scale in each subplot. This enables visual comparison
    rad=1.1*max(radii(:))
    xlim([-1 1]*rad)
    ylim(centers(:,ps)'+[-1 1]*rad)
    axis off; % We hide the axis 

    
    % Figure formatting
    ax=gca; ax.Position(3:4)= [0.1566 0.29];
    title(['$\mathbf{\hat{y}=}$\textbf{' num2str(round(positions(ps),1)) ' mm}']);
    
end

% Create Legend
legh=legend([hpupil hellipse],'Intersections of passing rays','Ray Pass Function using ellipses')
legh.Box='off';
legh.Orientation='horizontal';
legh.Position=[0.2520 0.9326 0.4457 0.0767]


% Make all text latex formatted
set(findall(gcf,'-property','FontSize'),'FontSize',12);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

exportgraphics(gcf,['./fig/passnopass_ellipses_' lensName{i} '.png'])

end



