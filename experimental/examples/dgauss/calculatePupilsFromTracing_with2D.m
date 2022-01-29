%% Calculate pupil from ray tracing
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.3.0mm.json');

exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)
lens=lensReverse(lensFileName);
lens.draw

%% INput plane

firstEle=lens.surfaceArray(1); % First lens element
firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    
offset_inputplane=0.01;%mm
offset_inputplane=0.5;%mm
inputplane_z= firstsurface_z-offset_inputplane

%% Modifcation of lens parameters if desired
diaphragm_diameter=0.6;
lens.surfaceArray(6).apertureD=diaphragm_diameter;
lens.apertureMiddleD=diaphragm_diameter;

% Note there seems to be a redundancy in the lens which can get out of
% sync: lens.apertureMiddleD en lens.surfaceArray{i}.apertureD (i= index of
% middle aperture)
% lens.surfaceArray(6).apertureD=0.4 seems to be only used for drawing
%   lens.apertureMiddleD seems to be used for actual calculations in
%   determining the exit and entrance pupil


%% Choose entrance pupil position w.r.t. input plane
% Ideally this distance is chosen in the plane in which the entrance pupil
% doesn't shift.  
% This is the best guess. In principle the algorithm can handle  an unknown
% entrancepupil distance

% Good guess:
entrancepupil_distance =  1.1439;

% Bad guess: , 
%entrancepupil_distance =  3;
%entrancepupil_distance=  0.5;

%% Run ray trace, and log which rays can pass
clear p;

flag_runraytrace=false;

if(not(flag_runraytrace))
    % IF we don't want to redo all the ray trace, load a cached ray trace
    % file. This file was generated by just using save('./cache/...')
    load cache/dgauss-aperture0.6-sample250.mat;
    load cache/dgauss.22deg.3.0mm.json-May-14-2021_5-42PM.mat;
    load cache/dgauss.22deg.3.0mm.json-May-14-2021_5-42PM.mat;              
    %load cache/dgauss.22deg.3.0mm.json-offset0.5-June-02-2021_7-24PM.mat
else
     
    % Ray trace sampling parameters
    nbThetas=350;
    nbPhis=nbThetas;
    thetas = linspace(-40,40,nbThetas);
    phis = linspace(0,359,nbPhis);

    positions=[0 0.1 0.3 0.5 0.6 0.64 0.7 0.8 0.9 1 1.2 1.3]
    
    
    % Initiate the arrays as NaNs, else the zeros will be interpreted at a
    % position for which a ray passed
    pupilshape_trace = nan(3,numel(positions),numel(thetas),numel(phis));
    
    for p=1:numel(positions)
        p
        for ph=1:numel(phis)
            for t=1:numel(thetas)
                
                % Origin of ray
                origin = [0;positions(p);inputplane_z];
                
                
                % Direction vector of ray
                phi=phis(ph);
                theta=thetas(t);
                direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
                
                
                % Trace ray with isetlens
                wave = lens.get('wave');
                rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
                [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
                pass_trace = not(isnan(prod(out_point)));
                
                % If the ray passes the lens, save at which coordinate it
                % intersected with the chosen pupil plane.
                if(pass_trace)
                    % Linear extrapolation from origin to find intersection
                    % with entrance_pupil plane
                    pointOnPupil = origin+(entrancepupil_distance/(direction(3)))*direction;
                    
                    pupilshape_trace(:,p,t,ph)=  pointOnPupil;
                end
                
            end
        end
    end
    
    % Save the ray trace, because hey, it takes a long time!
    close all;
    save(['./cache/' lensFileName '-offset' num2str(offset_inputplane) '-' datestr(now,'mmmm-dd-yyyy_HH-MMAM') '.mat'])
end


%% 2D Trace along line to accurately find borders of the pupils
% In 3D you might easily undersample such that the most extreme points are
% lost. We assume here that these extreme points must lie on the center,
% and hence we can find them by sampling many more angles along one line.
nbThetas=10000;
nbPhis=nbThetas;
thetas = linspace(-40,40,nbThetas);



% To avoid zeros to be counted as "traced"
pupilshape_trace2D = nan(3,numel(positions),numel(thetas),numel(phis));
for p=1:numel(positions)
    p
    
    for t=1:numel(thetas)
        
        % Origin of ray
        origin = [0;positions(p);inputplane_z];
        
        % Direction vector of ray
        phi=90;
        theta=thetas(t);
        direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
        
        
        % Trace ray with isetlens
        wave = lens.get('wave');
        rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
        [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
        pass_trace = not(isnan(prod(out_point)));
        
        % If the ray passes the lens, save at which coordinate it
        % intersected with the chosen pupil plane.
        if(pass_trace)
            % Linear extrapolation from origin to find intersection
            % with entrance_pupil plane
            pointOnPupil = origin+(entrancepupil_distance/(direction(3)))*direction;
            
            pupilshape_trace2D(:,p,t)=  pointOnPupil;
        end
        
    end
end

    

%% Extreme points based on 2D sampling


extreme_top=max(pupilshape_trace2D(2,:,:),[],3);
extreme_bottom=min(pupilshape_trace2D(2,:,:),[],3);

figure(1);clf;
for p=1:numel(positions)
    subplot(2,6,p); hold on;
    
    % Trace 3D
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
        
    
    % Trace 2D
    Ptrace=pupilshape_trace2D(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    xlim(2*radius_entrance_prev*[-1 1])
    ylim(2*radius_entrance_prev*[-1 1])
end

%% Step 1 : Fit exit pupil on-axis.   
% At the onaxis position (p=1), there is no vignetting, and by construciton
% the pupil you see is the entrance pupil. The radius is estimated by
% finding the minimally bounding circle (using the toolbox)

p=1
Ptrace=pupilshape_trace(1:2,p,:);
Ptrace=Ptrace(1:2,:);

NaNCols = any(isnan(Ptrace));
Pnan = Ptrace(:,~NaNCols);
ZeroCols = any(Pnan(:,:)==[0;0]);
Pnan = Pnan(:,~ZeroCols);

[center0,radius0] = minboundcircle(Pnan(1,:)',Pnan(2,:)')

figure(1);clf; hold on;
viscircles(center0,radius0)
scatter(Ptrace(1,:),Ptrace(2,:),'.')



%% Step 1: Automatic entrance puil
% When the exit pupil distance is not exactly known, we also need to
% estimate a sensitivity for the entrance pupil as it will not remaind
% stationairy.
% The top part is used because (at least for dgauss) this is the last
% surface to be cut off

% Top
position_selection=[1 3]; % Choose the positions for which the top circle is unaffected by vignetting.
offaxis_distances=positions(position_selection);


offset=0.01;
stepsize_radius=0.01;
[radius_entrance,sensitivity_entrance]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'extremepoints',extreme_top(position_selection),'stepsizeradius',stepsize_radius)
[radius_entrance_prev,sensitivity_entrance_prev]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'offset',offset,'stepsizeradius',stepsize_radius)


%% Step 2: Automatic estimation of the vignetting circles
% The automatic estimation algorithm tries to fit a circle that matches the
% curvature and position on opposite (vertical) sides of the pupil.

% Bottom
position_selection=3:6;
offaxis_distances=positions(position_selection);
offset=0.01;
stepsize_radius=0.01;
[radius_bottom,sensitivity_bottom]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"bottom",'offset',offset,'stepsizeradius',stepsize_radius)

% Top
position_selection=7;
offaxis_distances=positions(position_selection);
offset=0.001;
stepsize_radius=0.01;
[radius_top,sensitivity_top]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'offset',offset,'stepsize radius',stepsize_radius)

%% Verify automatic fits:


figure(1);clf; hold on;
for p=1:numel(positions)
    subplot(3,round(numel(positions)/2),p); hold on;
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
%     % Calculate offset of each circle
     offset_entrance=sensitivity_entrance*positions(p);
     offset_bottom=sensitivity_bottom*positions(p);
     offset_top=sensitivity_top*positions(p);
     
     % Draw circles
 %    viscircles(center0,radius0,'color','k')
     viscircles([0 offset_entrance],radius_entrance,'color','k','linewidth',1)
     viscircles([0 offset_bottom],radius_bottom,'color','b','linewidth',1)
     viscircles([0 offset_top],radius_top,'color','r','linewidth',1)
     
    
    xlim(2*radius_entrance*[-1 1])
    ylim(2*radius_entrance*[-1 1])
    title(positions(p))
    %axis equal
    %pause(0.5);
    
    
end


%% Calculate pupil positions and radii
% To be used in 'checkRayPassLens'
% All circle intersections where done in the entrance pupil plane.
% Each circle is a projection of an actual pupil. Here I project the
% corresponding circles back to their respective plane where they are
% centered on the optical axis.

% Distance to entrance pupil is already known by construction unless a
% wrong guess was taken. When the guess was good sensitivity_entrance
% should be basically zero.
hx= entrancepupil_distance/(1-(sensitivity_entrance))
Rpupil_entrance = radius_entrance/(1-sensitivity_entrance)

% Calculate radius of a pupil by projecting it back to its actual plane
% (where it is cented on the optical axis)
Rpupil_bottom = radius_bottom/(1-sensitivity_bottom)
Rpupil_top = radius_top/(1-sensitivity_top)


% Calculate positions of pupils relative to the input plane
hp_bottom=entrancepupil_distance/(1-sensitivity_bottom)
hp_top=entrancepupil_distance/(1-sensitivity_top)


% Information to be used for PBRT domain evaluation (FOR ZHENG)
radii = [Rpupil_entrance Rpupil_bottom Rpupil_top]
pupil_distances = [hx, hp_bottom hp_top]

%
% %%
% radii =
%
%     0.4698    4.3275    0.5991
% 
% 
% pupil_distances =
% 
% 1.1480   10.3072    0.1570
% 

%% Second Verification (to check the ebove equations)
figure;

for p=1:numel(positions)    
    subplot(2,ceil(numel(positions)/2),p); hold on;
    
        
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    % Draw entrance pupil
    sensitivity = (1-entrancepupil_distance/hx);
    dentrance=sensitivity*positions(p);
    projected_radius = abs(entrancepupil_distance/hx)*Rpupil_entrance;
    viscircles([0 dentrance],projected_radius,'color','k','linewidth',1)
    
    % Draw Bottom circle
    sensitivity = (1-entrancepupil_distance/hp_bottom);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(entrancepupil_distance/hp_bottom)*Rpupil_bottom;
    viscircles([0 dvignet],projected_radius,'color','b','linewidth',1)
    
    
    % Draw Top circle
    sensitivity = (1-entrancepupil_distance/hp_top);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(entrancepupil_distance/hp_top)*Rpupil_top;
    viscircles([0 dvignet],projected_radius,'color','r','linewidth',1)
    
    %axis equal
    ylim(2*[-1 1])
    xlim(2*[-1 1])
    title(['x = ' num2str(positions(p))])
end

