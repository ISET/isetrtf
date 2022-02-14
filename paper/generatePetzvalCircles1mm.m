%% Calculate intersecting circles for the raypass function
% Petzval Lens from zemax sample library
%
% 2022 Thomas Goossens

%% Define RTF Parameters
clear;close all;
lensFileName= 'petzval';

% Lens thickness (distance between first and last surface)
lensThickness=143.88312;

% Input and output plane offsets
offset_output=0.01;%mm
offset_input=0.01;% mm


%% Calculate position of the input plane assuming z=0 at the surfcace closest to the scene.
inputplane_z= -lensThickness-offset_input


%% Choose the ray pass plane with an arbitrary nonzero positive distance from the input plane
raypassplane_distancefrominput_mm=  17;



%% Load the rays obtained using the zemax macro for the petzval lens.
file='./data/zemaxraytrace/petzval_primarywl1.txt';
% Note to user: It turns out the circles vary more smoothly when placing the inputoutput planes at an
% offset of 5 mm instead of 0.01 mm. This makes it easier to find the
% interpolating circles.


X=dlmread(file,'\s',1);

Xnonan=X(~isnan(X(:,1)),:);

% Make separate matrices for input rays and output rays
iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);


%% Project all rays onto the ray pass plane to obtain convex shapes.
% We first collect all rays that originate at the same position on the
% input plane
positions=unique(iRays(:,1));

% Pre-allocate array containing the intersection on the ray pass plane.
% 3 coordinates  x number of unique positions  x 1 
% The last dimension will change depending on the number of rays
pupilshapeOnRayPassPlane = nan(3,numel(positions),1);
      
for p=1:numel(positions)
        disp(['positions: ' num2str(p)])

        % Collect all rays at same origin
        iRaysAtPos=iRays((iRays(:,1)==positions(p)),:);
        origin=[0 iRaysAtPos(1,1) inputplane_z];

        % Initialize loop
        clear pupil;count=1;
        for i=1:size(iRaysAtPos,1)
            % Calculate direction vector
            directions=iRaysAtPos(i,2:3); directions(3)=sqrt(1-sum(directions(1:2).^2));
            
            % Project ray onto the raypass plane
            pointOnPupil = origin+(raypassplane_distancefrominput_mm/(directions(3))).*directions;
                    
            % Record in temporary array
            pupilshapeOnRayPassPlane(:,p,count)=  pointOnPupil;
            count=count+1;
        end
         % Record all points of intersection per originating position p

        

end
    
    






%% Estimate circle 1 ( this one corresponds to the exit pupil , but projected to the ray pass plane)
position_selection=[26]; %% Choose off axis position of interest.
offaxis_distances=positions(position_selection);
pupils=pupilshapeOnRayPassPlane(1:2,position_selection,:)

% Tuning parameters
offset=0.01; stepsize_radius=0.01;

% Find radius and sensitivity of the tangent circle on the bottom
[radius_1,sensitivity_1]=findCuttingCircleEdge(pupils,offaxis_distances,"bottom",'offset',offset,'stepsizeradius',stepsize_radius)
%% Estimate circle 2
position_selection=[23]; % Choose the positions for which the top circle is unaffected by vignetting.
offaxis_distances=positions(position_selection);
pupils=pupilshapeOnRayPassPlane(1:2,position_selection,:)

% Tuning parameters
offset=0.05;stepsize_radius=0.01;

% Find radius and sensitivity of the tangent circle on the top ( where it
% cuts)
[radius_top_2,sensitivity_top_2]=findCuttingCircleEdge(pupils,offaxis_distances,"top",'offset',offset,'stepsizeradius',stepsize_radius)


%% Estimate circle 3
position_selection=[25 29]; % Choose the positions for which the top circle is unaffected by vignetting.
offaxis_distances=positions(position_selection);
pupils=pupilshapeOnRayPassPlane(1:2,position_selection,:);

% Tuning parameters
offset=0.05; stepsize_radius=0.01;
% Find radius and sensitivity of the tangent circle on the top (where it
% cuts)
[radius_top_3,sensitivity_top_3]=findCuttingCircleEdge(pupils,offaxis_distances,"top",'offset',offset,'stepsizeradius',stepsize_radius)


%% Collect all radii and sensitivities in arrays

radii = [radius_1 radius_top_3 radius_top_2]
sensitivities = [sensitivity_1 sensitivity_top_3 sensitivity_top_2]


%% Make figure for paper showing the circle intersection 

colors={[0 0 0],[0.83 0 0],[0 0.83 0] };
colorpass = [0 49 90]/100;  

fig=figure(1);clf; hold on;
fig.Position=[667 514 560 131];
count=1;

% Loop only over the positions to plot
for p=[1 80 81 82]
    subplot(1,4,count); hold on;
 
   % Plot collected intersections on the ray pass plane
    Ptrace=pupilshapeOnRayPassPlane(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    hscatter=scatter(Ptrace(1,:),Ptrace(2,:),'.')
    hscatter.CData = colorpass;
          
     % Draw circles
     for r=1:numel(radii)
       offset(r)=sensitivities(r)*positions(p);
       viscircles([0 offset(r)],radii(r),'color',colors{r},'linewidth',1.5)
     end
     
 
   % Hide axis but place limits
    axis off
    xlim([-10 10])
    ylim([-10 10]+offset(1)) %Add offset to keep circles centered in figure
    title(['$\hat{y}=$' num2str(positions(p))]) % Add off axis position on input plane
    

    
     count=count+1;
    
end

set(findall(gcf,'-property','FontSize'),'FontSize',11);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

exportgraphics(gcf,'fig/petzval-0.01mm-circles.pdf')


