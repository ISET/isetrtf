% This example script uses existing code from Michael Pieroni to calculate
% the entrance pupils for a given lens design.
% It works projecting each lens element back to the object space (in
% paraxial limit)
% This means that there is an entrance pupil for each lens. 
%
% In practice it will usually be the projection of the diapgraphm that is
% the most limiting.
% However, at off-axis positions the other pupils also can start limiting
% the rays. This effectively corresponds to mechanical/optical vignetting.
%
% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('fisheye.87deg.3.0mm.json');

%lensFileName = fullfile('tessar.22deg.3.0mm.json');
exist(lensFileName,'file');


lens = lensReverse(lensFileName);
lens = lensC('fileName', lensFileName)


%% Modifcation of lens parameters if desired

 diaphragm_diameter=1;
 lens.surfaceArray(12).apertureD=diaphragm_diameter
 lens.apertureMiddleD=diaphragm_diameter
 
%%
impoint=lens.findImagePoint([0 0 -3000],1,1)
z_im_mm = impoint(1,3)
 
%% Find Pupils
% Optical system needs to be defined to be comptaible wich legacy code
% 'paraxFindPupils'.
opticalsystem = lens.get('optical system'); 
exit = paraxFindPupils(opticalsystem,'exit'); % exit pupils
entrance = paraxFindPupils(opticalsystem,'entrance'); % entrance pupils;


% TG: To check: As far as I can see now the entrance (exit) pupil positions are defined
% with respect to the first (last) surface.


%% Draw diagram Entrance pupils

lens.draw
for i=1:numel(entrance)
    
    % entrance pupil (with respect to first surface)
    firstEle=lens.surfaceArray(1); % First lens element
    firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    pupil_radius(i)=entrance{i}.diam(1,1)
    pupil_position(i)=firstsurface_z+entrance{i}.z_pos(1)
    
    
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    % Number each entrance pupil so it is easy to see to which surface it
    % belongs
    text(pupil_position(i),1.2*pupil_radius(i),num2str(i))
    
    
    
end
title('Entrance pupils ')
legh=legend('');
legh.Visible='off';


pupil_position(1)=pupil_position(1)+0.1697;


%% Choose entrance pupil nr

entrancepupil_nr=6;

%% Check if ray can pass
clear p;


thetas = linspace(-40,40,50);
phis = linspace(0,359,50);

positions=[0 0.8 0.85 0.9]
positions=[0 0.2 0.5 0.8 0.85 0.88]


% Initiate the arrays as NaNs, else the zeros will be interpreted at a
% position for which a ray passed
pupilshape = nan(3,numel(pupil_position),numel(thetas),numel(phis));
pupilshape_trace = nan(3,numel(pupil_position),numel(thetas),numel(phis));

for p=1:numel(positions)
    p
    for ph=1:numel(phis)
    for t=1:numel(thetas)
        
        % Origin of ray
        origin = [0;positions(p);-2];
        
        
        % Direction vector of ray
        phi=phis(ph);
        theta=thetas(t);
        direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
        
        
        
        
        % Check whether ray goes through all pupils
        for i=1:numel(entrance)
            alpha = (pupil_position(i) - origin(3))/(direction(3));
            pointOnPupil(:,i) = origin+alpha*direction;
            passpupil(i)= norm(pointOnPupil(1:2,i))<=pupil_radius(i);
                        
        end
        pass = prod(passpupil); % boolean AND operation, ray needs to pass through all
        
        if(pass)
            pupilshape(:,p,t,ph)= pointOnPupil(:,entrancepupil_nr);
        end
        
        
        
        % Trace ray with isetlens
        wave = lens.get('wave');
        rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
        [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
        pass_trace = not(isnan(prod(out_point)));
        if(pass_trace)
            pupilshape_trace(:,p,t,ph)=  pointOnPupil(:,entrancepupil_nr);

        end
        
        compare(:,p,t,ph) = [pass_trace pass];
        
    end
    end
end

%% Plot pupil shapes
figure;

for p=1:numel(positions)    
    subplot(ceil(numel(positions)/2),ceil(numel(positions)/2),p); hold on;
    
    % Plot paraxial pupil shape
    P=pupilshape(1:2,p,:);
    P=P(1:2,:);
    
    scatter(P(1,:),P(2,:),'.')
    
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
                   

    %area = convhull(Ptracenonan(1,:)',Ptracenonan(2,:)')
    scatter(Ptrace(1,:),Ptrace(2,:),'o')
    
    
    % Draw entrance pupil
    viscircles([0 0],pupil_radius(entrancepupil_nr),'color','k')
    
    % Draw dominant vignetting circle pupil (last surface)
    pupil_nr=1;
    hx=(pupil_position(entrancepupil_nr)-origin(3));
    hp=(pupil_position(pupil_nr)-origin(3)); % h/l
    sensitivity = (1-hx/hp); 
    dvignet=sensitivity*positions(p);
    projected_radius = abs(hx/hp)*pupil_radius(pupil_nr);
    viscircles([0 dvignet],projected_radius)
    
    % Draw dominant vignetting circle pupil (first surface)
    pupil_nr=11;
    hx=(pupil_position(entrancepupil_nr)-origin(3));
    hp=(pupil_position(pupil_nr)-origin(3)); % h/l
    sensitivity = (1-hx/hp); 
    dvignet=sensitivity*positions(p);
    projected_radius =abs(hx/hp)*pupil_radius(pupil_nr);
    viscircles([0 dvignet],projected_radius,'color','b')
    
    %axis equal
    ylim([-1 1])
    xlim(0.5*[-1 1])
    title(['x = ' num2str(positions(p))])
end





%% Fit ellipse on entrance pupil


for p=1:numel(positions)
    
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    
    NaNCols = any(isnan(Ptrace));
    Pnan = Ptrace(:,~NaNCols);
    ZeroCols = any(Pnan(:,:)==[0;0]);
    Pnan = Pnan(:,~ZeroCols);
    
    
    k=convhull(Pnan(1,:),Pnan(2,:))  
    [A , c] = MinVolEllipse(Pnan(:,k),0.01);
    center(:,p)=c;
    [U Q V]=svd(A);
    radius_x(p)=1/sqrt(Q(1,1))
    radius_y(p)=1/sqrt(Q(2,2))


    
end


%% Plot Fitted ellipses
figure(1);clf;
for p=1:numel(positions);
    subplot(2,3,p);hold on
    
    
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    
    %NaNCols = any(isnan(Ptrace));
    %Pnan = Ptrace(:,~NaNCols);
    %k=convhull(Pnan(1,:),Pnan(2,:))
    %scatter(Pnan(1,:),Pnan(2,:))
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    % Draw entrance pupil
    %viscircles([0 0],radius,'color','k')
    h = drawellipse('Center',center(:,p)','SemiAxes',[radius_y(p),radius_x(p)],'Color','r');
    ylim(1.2*radius_y(1)*[-1 1])
    xlim(1.2*radius_x(1)*[-1 1])
    
end


return
%%%%%%%%%%%%%% PROCEDURE FOR FITTING CIRCLE INTERSECTIONS
%% STEP 1: Determine first circle on axis

 Ptrace=pupilshape_trace(1:2,p,:);
 Ptrace=Ptrace(1:2,:);
    
    NaNCols = any(isnan(Ptrace));
    Pnan = Ptrace(:,~NaNCols);
    ZeroCols = any(Pnan(:,:)==[0;0]);
    Pnan = Pnan(:,~ZeroCols);
    
    
    k=convhull(Pnan(1,:),Pnan(2,:))  
    [A , c] = MinVolEllipse(Pnan(:,k),0.01);



return
%%
th=27;
origin=[0 ;-0.2;-1];
dir= [0; sind(th) ;cosd(th)];
rays = rayC('origin',origin','direction',dir', 'waveIndex', 1, 'wave', wave);
[~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',true);
hold on;


% Draw diagram Entrance pupils
for i=1:numel(entrance)

    
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    % Number each entrance pupil so it is easy to see to which surface it
    % belongs
    text(pupil_position(i),1.2*pupil_radius(i),num2str(i))
    
    
    
    
    
    
end

% Draw condinued ray
r = origin + alpha .* dir;
alpha=linspace(0,10,100);
plot(r(3,:),r(2,:),'r--')


% Did they ray pass according to pupil intersections?

pass=checkRayPassLens(origin,dir,pupil_position,pupil_radius)