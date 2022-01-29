
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
    
    






%% Step 1: Automatic entrance puil LINEAR
% When the exit pupil distance is not exactly known, we also need to
% estimate a sensitivity for the entrance pupil as it will not remaind
% stationairy.
% The top part is used because (at least for dgauss) this is the last
% surface to be cut off

% Top
position_selection=[10]; % Choose the positions for which the top circle is unaffected by vignetting.
offaxis_distances=positions(position_selection);


offset=0.01;
stepsize_radius=0.01;
[radius_entrance,sensitivity_entrance]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'offset',offset,'stepsizeradius',stepsize_radius)







%%  Show nonlinearity
clear centers radii
for p=1:numel(positions)
Ptrace=pupilshape_trace(1:2,p,:);
Ptrace=Ptrace(1:2,:);

NaNCols = any(isnan(Ptrace));
Pnan = Ptrace(:,~NaNCols);
ZeroCols = any(Pnan(:,:)==[0;0]);
Pnan = Pnan(:,~ZeroCols);

[center0,radius0] = minboundcircle(Pnan(1,:)',Pnan(2,:)')

radii(p)=radius0;
centers(:,p)=center0;

end

figure(2);clf
subplot(211); hold on;
plot(positions,radii)

[radiusPolynomial,varNames] =fitRadiusPolynomial(positions,radii,'a*x^6+b*x^4+c*x^3+d*x^2+1');
radiusPolynomial = [radiusPolynomial 1]
%plot(positions,radii(1)*(1+polyvaln(polyradius,positions)),'r--')
plot(positions,radii(1)*polyval(radiusPolynomial,positions),'r--')
legend('Simulated','Polynomial fit','location','best')
title('Radius')
subplot(212); hold on;
plot(positions,centers(2,:))
plot(positions,sensitivity_entrance*positions,'k--')

% Force this linear coefficient, this seens to be crucial to be
% investigated
[coefficientValues] = fitSensitivityPolynomial(positions,centers(2,:),'a*x^3+b*x^2+0.0522*x')
sensitivityPolynomial= [coefficientValues 0.0522 ];


plot(positions,positions.*polyval(sensitivityPolynomial,positions),'r--')
legend('Center Y position','Linear approximation','Polynomial approx','location','best')

title('Center')




%% Verify automatic fits:
colors={'k' 'r' 'g' 'b' 'm' [0.9 0.5 0.9] };

figure(1);clf; hold on;
for p=1:numel(positions)
        subplot(3,ceil(numel(positions)/3),p); hold on;
 
       % Collected points
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    
    
    

   %  viscircles(centers(:,p)',radii(p),'color','k','linewidth',1)

    
     offset=sensitivity_entrance*positions(p);
          
     % Draw circles
     
     %viscircles([0 offset],radius_entrance,'color','k','linewidth',1)
     
     % Nonlinear circle change
     radius_nonlin=1+polyvaln(polyradius,positions(p)); 
     offset_nonlin=polyvaln(polycenterY,positions(p)); 
     viscircles([0 offset_nonlin],radius_nonlin*radii(1),'color','m','linewidth',1)
     
      
     % Draw off axis position
     scatter(0,positions(p))
     
 
     
     
    xlim([-1 1])
    ylim([-0.5 2.5])
    title(positions(p))
    axis equal
    %pause(0.5);
    
 
    
end



return
%% Calculate pupil positions and radii
% To be used in 'checkRayPassLens'
% All circle intersections where done in the entrance pupil plane.
% Each circle is a projection of an actual pupil. Here I project the
% corresponding circles back to their respective plane where they are
% centered on the optical axis.

% Distance to entrance pupil is already known by construction unless a
% wrong guess was taken. When the guess was good sensitivity_entrance
% should be basically zero.
hx= exitpupil_distance_guess/(1-(sensitivity_entrance))
Rpupil_entrance = radius_entrance/(1-sensitivity_entrance)

% Calculate radius of a pupil by projecting it back to its actual plane
% (where it is cented on the optical axis)
Rpupil_bottom = radius_bottom/(1-sensitivity_bottom)
Rpupil_top = radius_top/(1-sensitivity_top)


% Calculate positions of pupils relative to the input plane
hp_bottom=exitpupil_distance_guess/(1-sensitivity_bottom)
hp_top=exitpupil_distance_guess/(1-sensitivity_top)


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
fig=figure(10);clf

fig.Position(3:4)=[938 362]

for p=1:numel(positions)    
    subplot(3,ceil(numel(positions)/3),p); hold on;
    
        
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    lw=2; %Linewidth
    
    % Draw entrance pupil
    sensitivity = (1-exitpupil_distance_guess/hx);
    dentrance=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hx)*Rpupil_entrance;
    viscircles([0 dentrance],projected_radius,'color','k','linewidth',lw)
    
    % Draw Bottom circle
    sensitivity = (1-exitpupil_distance_guess/hp_bottom);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hp_bottom)*Rpupil_bottom;
    viscircles([0 dvignet],projected_radius,'color',[0 0 0.8],'linewidth',lw)
    
    
    % Draw Top circle
    sensitivity = (1-exitpupil_distance_guess/hp_top);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hp_top)*Rpupil_top;
    viscircles([0 dvignet],projected_radius,'color',[0.8 0 0 ],'linewidth',lw)
    
    
    %axis equal
    ylim(20*[-1 1])
    xlim(20*[-1 1])
    
   
    ax=gca;
    ax.XAxis.Visible='off';
    ax.YAxis.Visible='off'; 
    
    
    title(['p = ' num2str(positions(p)) ' mm'])
end

saveas(gcf,'dgauss_threecircles.eps','epsc')



%%%

%% Check pass
% Ray trace sampling parameters
nbThetas=40;
nbPhis=nbThetas;
thetas = linspace(-40,40,nbThetas);
phis = linspace(0,359,nbPhis);

counter=1;
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
            pass_circle =checkRayPassLens(origin,direction, pupil_distances,radii);
            
            comparison(counter,1:2) = [pass_trace pass_circle];
            
            counter=counter+1;
        end
    end
end


%% Calculate Pass/Fail accuracy
% Depending on sampling it gets about 99 % correct  Realize this is heavily
% skewed if you are sampling far from the edges of the aperture anyway. But
% as long we consistently compare different passray functions we should be
% fine.

passratio=sum((comparison(:,1)==comparison(:,2)))/size(comparison,1)


%% Convex hull for each position

figure(1);clf;

for p=1:numel(positions)
    subplot(2,numel(positions)/2,p); hold on;
    points=squeeze(pupilshape_trace(1:2,p,:));
    points(:,isnan(points(1,:)))=[];
    [k,av]=convhull(points')
    hull{p}=points(:,k);
    
    
    plot(points(1,k),points(2,k))

    axis equal
        
    % random points check
    X=randn(2,100); 
    h1=hull{p};
     in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');
    plot(X(1,in),X(2,in),'g+') % points inside
    plot(X(1,~in),X(2,~in),'r+') % points outside
    
    ylim([-2 2])
    xlim([-2 2])
    
end
%%
h1=hull{1}
x_test=0;
y_test=0;
tic; in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');toc
tic; IN = inhull(X',h1');toc
