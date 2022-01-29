
%% Calculate pupil from ray tracing
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

%% Modifcation of lens parameters if desired


diameters = linspace(0.01,20,20);


for i = 1:numel(diameters)
    
diaphragm_diameter=diameters(i)
lens.surfaceArray(6).apertureD=diaphragm_diameter;
lens.apertureMiddleD=diaphragm_diameter;

%% INput plane

firstEle=lens.surfaceArray(1); % First lens element
firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    
offset_inputplane=0.1;%mm
inputplane_z= firstsurface_z-offset_inputplane;

%% Choose entrance pupil position w.r.t. input plane
entrancepupil_distance =  17;



%% Run ray trace, and log which rays can pass
clear p;

flag_runraytrace=true;
    % IF we don't want to redo all the ray trace, load a cached ray trace
     
    % Ray trace sampling parameters
    nbThetas=1000;
    nbPhis=1;
    thetas = linspace(-30,30,nbThetas);
    phis = linspace(0,359,nbPhis);
    
    positions=[0 ];
    
    
    % Initiate the arrays as NaNs, else the zeros will be interpreted at a
    % position for which a ray passed
    pupilshape_trace = nan(3,numel(positions),numel(thetas),numel(phis));
    
    for p=1:numel(positions)
        
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
    
    close all;



    
    % Calculate radius at normal incidence

Ptrace=pupilshape_trace(1:2,p,:);
Ptrace=Ptrace(1:2,:);


% 2D radius optical axis
radius(i)=[max(Ptrace(:))];

end
    



%% Fit: relation
sel=1:15
[xData, yData] = prepareCurveData( diameters(sel), 2*radius(sel) );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'radius vs. diameters', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'diameters diaphragm', 'Interpreter', 'none' );
ylabel( 'diameters circle', 'Interpreter', 'none' );
grid on



