
%% Calculate pupil from ray tracing
% This scripts create a figure showing the concept of circle sampling, it does not actually
% generate the 
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.50.0mm_aperture6.0.json');

exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)


lens=lensReverse(lensFileName);
disp('CHeck whether using reverse or forward lens')
lens.draw


    
%Set diaphraghm diameter. Should be smaller than 9  to find the exit pupil
%in this case
diaphragm_diameter= 7;
lens.surfaceArray(6).apertureD=diaphragm_diameter;
lens.apertureMiddleD=diaphragm_diameter;

%% INput plane

firstEle=lens.surfaceArray(1); % First lens element
firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    
offset_inputplane=0.01;%mm
inputplane_z= firstsurface_z-offset_inputplane

%% Choose entrance pupil position w.r.t. input plane
% Ideally this distance is chosen in the plane in which the entrance pupil
% doesn't shift.  
% This is the best guess. In principle the algorithm can handle  an unknown
% entrancepupil distance

% Good guess:
entrancepupil_distance =  17;

% Bad guess: , 
%entrancepupil_distance =  3;
%entrancepupil_distance=  0.5;





%% Run ray trace, and log which rays can pass
clear p;

flag_runraytrace=true;
     
 
 % Lens reverse
positions =[0    1.0000    2.0000    3.0000    4.0000    5.0000    6.0000    7.0000    8.0000    9.0000   10.0000   10.1000   10.2000 10.3000   10.4000   10.5000];
 
 

    
    % Initiate the arrays as NaNs, else the zeros will be interpreted at a
    % position for which a ray passed
    nbThetas=50;
    nbPhis=50;
    pupilshape_trace = nan(3,numel(positions),nbThetas,nbPhis);
    pupilshape_vignetted= nan(3,numel(positions),nbThetas,nbPhis);
    
    
    
    for p=1:numel(positions)
        disp(['positions: ' num2str(p)])
        maxTheta=40;
        nbPhis=nbThetas;
        thetas = linspace(-maxTheta,maxTheta,nbThetas);
        phis = linspace(0,359,nbPhis);

        
        count=1;
        for ph=1:numel(phis)
                        
            for t=1:numel(thetas)
                
                % Origin of ray
                origins(count,:) = [0;positions(p);inputplane_z];
                
                
                % Direction vector of ray
                phi=phis(ph);
                theta=thetas(t);
                
                
                directions(count,:) = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
                
                count=count+1;
            end
        end
        
        
                % Trace ray with isetlens
                
                 waveIndices=1*ones(1, size(origins, 1));
                rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
                [~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);
                
                pass_trace = not(isnan(prod(pOut,2)));    
    
                % If the ray passes the lens, save at which coordinate it
                % intersected with the chosen pupil plane.
                
                count=1;
                countVignetted=1;
                for i=1:numel(pass_trace)
                    if(pass_trace(i))
                    % Linear extrapolation from origin to find intersection
                    % with entrance_pupil plane
                    pointOnPupil = origins(i,:)+(entrancepupil_distance/(directions(i,3)))*directions(i,:);
                    
                    pupilshape_trace(:,p,count)=  pointOnPupil;
                    count=count+1;
                    else
                      pointOnPupil = origins(i,:)+(entrancepupil_distance/(directions(i,3)))*directions(i,:);
                      pupilshape_vignetted(:,p,countVignetted)=  pointOnPupil;
                      countVignetted=countVignetted+1;
                    end
                end
                
            end
        
    
    
    % Save the ray trace, because hey, it takes a long time!
    close all;
    



    
    
 %% Visualisze traces
circlePlaneZ=inputplane_z+   entrancepupil_distance;
 p=10
 Ptrace=pupilshape_trace(1:3,p,:);
 Pvignet=pupilshape_vignetted(1:3,p,:);
 
 figure(1);clf
 hold on;


 
% Draw Circle plane
 planeSide=24;
 x=planeSide*[-1 1 1 -1 -1];
 y=planeSide*[-1 -1 1 1 -1];
 z= circlePlaneZ*[1 1 1 1 1];
hplane=plot3(x, y, z, 'k');

htext=text(10,-10,circlePlaneZ,'Circle plane') 
 
% Draw Input plane
 planeSide=24;
 x=planeSide*[-1 1 1 -1 -1];
 y=planeSide*[-1 -1 1 1 -1];
 z= inputplane_z*[1 1 1 1 1];
hplane=plot3(x, y, z, 'k');


%htext=text(10,-10,inputplane_z,'Input plane') 
 
 % Draw Scatter plot of intersections on input plane
 htrace=scatter3(Ptrace(1,:),Ptrace(2,:),Ptrace(3,:),'.')
 htrace.CData=[0    0.4470    0.7410];
 hvignet=scatter3(Pvignet(1,:),Pvignet(2,:),Pvignet(3,:),'.')
 hvignet.CData=[0.9 0.4 0.4]
 

 % Label origin
 origin=[0;positions(p);inputplane_z];
 htext=text(-10,origin(2),origin(3),'Point on input plane')
 
% Draw a   subset of rays for visual effect
for c=1:1:size(Ptrace,3)
 line([origin(1) Ptrace(1,c)],[origin(2) Ptrace(2,c)],[origin(3) Ptrace(3,c)],'color',htrace.CData)
end 
   
for c=1:20:size(Pvignet,3)
 line([origin(1) Pvignet(1,c)],[origin(2) Pvignet(2,c)],[origin(3) Pvignet(3,c)],'color',hvignet.CData)
end 


 view(-27,18)
 
xlim([-24 24])
ylim([-24 24])
legh=legend([htrace hvignet],'Rays that reach film','Rays that do not pass')
legh.Box='off'
legh.Position=[[0.5690 0.5000 0.3250 0.0821]];

ax=gca;
ax.XAxis.Visible='off'
ax.YAxis.Visible='off'
ax.ZAxis.Visible='off'


exportgraphics(gca,'visualizeVignetCircleMethod.eps')
exportgraphics(gca,'visualizeVignetCircleMethod.png')



 
 
 