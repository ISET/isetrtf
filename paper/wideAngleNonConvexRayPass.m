%% Generate a figure demonstrating that the ray pass function becomes nonconvex so that a fitted ellipse would fail

% 2022 Thomas Goossens

%% Define RTF Parameters
clear;close all;
lensFileName= 'wideangle200deg';

% Lens thickness (distance between first and last surface)
lensThickness=14.1906;

% Input and output plane offsets
offset_output=0.01;%mm
offset_input=2.003;% mm


%% Calculate position of the input plane assuming z=0 at the surfcace closest to the scene.
inputplane_z= -lensThickness-offset_input



%% Choose the ray pass plane with an arbitrary nonzero positive distance from the input plane
raypassplane_distancefrominput_mm=  17;



%% Load the rays obtained using the zemax macro
% This dataset has a high number of samples near the edge for the purpose
% of illustrating the ray pass region is not conves.
file='./data/zemaxraytrace/wideangle200deg-primarywl1-gamma.txt'; 

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
    
    


%% Make figure showing the intersections on the ray pass plane and a bounding ellipse

colors={[0 0 0],[0.83 0 0],[0 0.83 0] };
colorpass = [0 49 90]/100;  

fig=figure(1);clf; hold on;
%fig.Position=[667 514 560 131];
count=1;
colorpassblue = [0 49 90]/100;   
% Loop only over the positions to plot
for p=[80]
    subplot(1,1,count); hold on;
 
   % Plot collected intersections on the ray pass plane
    Ptrace=pupilshapeOnRayPassPlane(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    hscatter=scatter(Ptrace(1,:),Ptrace(2,:),'o');
    hscatter.CData = colorpassblue;
    hscatter.SizeData=80
    hscatter.MarkerFaceColor= colorpassblue;

    Ptrace(:,isnan(Ptrace(1,:)))=[];
     
   
  
   % Draw allipse arround data for illustrative purposes only. Because the
   % minbound ellipse algorithm does not give the right result.
   radii(1)=1.2*abs(max(Ptrace(1,:))-center(1));
   radii(2)=1.2*abs(max(Ptrace(2,:))-center(2));
    
    hellipse=ellipse(radii(1),radii(2),0,center(1),center(2),[0.83 0 0])
 hellipse.LineWidth=2
   % Hide axis but place limits
    axis off
    xlim([-1 1]*5.5)
 

    legh=legend([hscatter,hellipse],'Ray Pass Region','Ellipse approximation')
    legh.Box='off'
    legh.Position=[0.3474 0.5382 0.3419 0.0945];
    
    
    
     count=count+1;
     
    
end

set(findall(gcf,'-property','FontSize'),'FontSize',15);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

exportgraphics(gcf,'fig/wideangle200deg-nonconvexraypass.pdf')