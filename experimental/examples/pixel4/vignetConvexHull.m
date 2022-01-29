
%% Calculate pupil from ray tracing
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName ='pixel4a-rear';

%% INput plane




lensThickness=4.827;

firstsurface_z=-lensThickness;

offset_output=1.48002192;%mm
offset_input=0.464135918;% mm
inputplane_z= firstsurface_z-offset_input


%% Choose entrance pupil position w.r.t. input plane

%% Best guess
exitpupil_distance_guess =  2.5893;





%% Get ZEMAX rays
X=dlmread('Gout-P4Ra_20111103.txt','\s',1);

Xnonan=X(~isnan(X(:,1)),:);

iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);


%% Run ray trace, and log which rays can pass
clear p;

positions=unique(iRays(:,1));



pupilshape_trace = nan(3,numel(positions),1);
       
for p=1:numel(positions)
        disp(['positions: ' num2str(p)])
        
        iRaysAtPos=iRays((iRays(:,1)==positions(p)),:);
        count=1;
        z=0; %????
        origin=[0 iRaysAtPos(1,1) inputplane_z];
        for i=1:size(iRaysAtPos,1)
            directions=iRaysAtPos(i,2:3);
            directions(3)=sqrt(1-sum(directions(1:2).^2));
            pointOnPupil = origin+(exitpupil_distance_guess/(directions(3))).*directions;
                    
            pupilshape_trace(:,p,count)=  pointOnPupil;
            count=count+1;
        end
        count

end
    
   

%% Calculate Pass/Fail accuracy
% Depending on sampling it gets about 99 % correct  Realize this is heavily
% skewed if you are sampling far from the edges of the aperture anyway. But
% as long we consistently compare different passray functions we should be
% fine.


%% Convex hull for each position

figure(1);clf;

numberPointsOnHull=100;

for p=1:numel(positions)
    subplot(5,ceil(numel(positions)/5),p); hold on;
    points=squeeze(pupilshape_trace(1:2,p,:));
    points(:,isnan(points(1,:)))=[];
    [k,av]=convhull(points')
    
    % Prune
    k=k(round(linspace(1,numel(k),numberPointsOnHull)));
    
    hull{p}=points(1:2,k);
    % Plot hull
    scatter(points(1,k),points(2,k),'.')

    axis equal
        
    % random points check
    X=0.5*randn(2,1000); 
    h1=hull{p};
     in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');
    plot(X(1,in),X(2,in),'g.') % points inside
    plot(X(1,~in),X(2,~in),'r.') % points outside
    
    ylim([-2 2])
    xlim([-2 2])
    
end



%% Whcih method of evaluation of hull is faster?
h1=hull{1}
for t=1:1000
x_test=rand(1);y_test=rand(1);
tic; in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)'); time_inpolygon(t)=toc;
tic; IN = inhull(X',h1');time_inhull(t)=toc;
end
figure
boxplot([time_inpolygon; time_inhull]')


  %% Minbound ellipse
  
  % Prepare positions in struct to interface to vignettingFitEllipses
  for p=1:numel(positions)
      pointsPerPosition{p}=squeeze(pupilshape_trace(:,p,:));
  end
  
  [radii,centers,rotations]=vignettingFitEllipses(pointsPerPosition);
  
  figure(11);clf
  subplot(311)
  plot(positions,radii(1,:),positions,radii(2,:))
  title('Ellipse Radii')
  subplot(312)
  plot(positions,centers')
  title('Ellipse centers')
  
  subplot(313)
  plot(positions,rotations')
  title('Rotations')



  %% Minbound ellipse
figure;  
numberPointsOnHull=100
% compare with hull for comparison
for p=1:numel(positions)
     subplot(5,ceil(numel(positions)/5),p); hold on;
     points=squeeze(pupilshape_trace(1:2,p,:));
     points(:,isnan(points(1,:)))=[];
     [k,av]=convhull(points')
     
     % Prune
     k=k(round(linspace(1,numel(k),numberPointsOnHull)));
     
     hull{p}=points(1:2,k);
  
    % random points check using convex heull
    X=randn(2,1000); 

    % Check if points are within ellipse
    in = ((X(1,:)-centers(1,p))./radii(1,p)).^2  + ((X(2,:)-centers(2,p))./radii(2,p)).^2 <= 1;
     
     
    plot(X(1,in),X(2,in),'g.') % points inside
    plot(X(1,~in),X(2,~in),'r.') % points outside
     
    points=hull{p};
    plot(points(1,:),points(2,:),'k-')
        
    ylim([-2 2.5])
    xlim([-2 2])
    
end

