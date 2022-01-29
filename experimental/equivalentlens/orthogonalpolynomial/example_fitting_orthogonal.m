%% Example Fitting polynomials to a rotationally symmetric lens

%% Notational conventions
% A ray arriving or departing from a plane is described as (x,y,u,v,w) with
% (x,y) the coordinate in the plane and (u,v,w) the direction vector in 3D
% space.
% The coordinate system is succh that z lies on the optical axis. 
% y= is vertical, x=depth (into the screen). 

clear;close all;
ieInit

%% Read a lens file and create a lens
%lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm.json');
lensFileName = 'lenses/dgauss.22deg.3.0mm.json';
%lensFileName = 'wide.56deg.3.0mm.json';
lensR = lensReverse(lensFileName);
% exist(lensFileName,'file');
% lensR = lensC('fileName', lensFileName);
wave = lensR.get('wave');

%% Sampling options 
spatial_nbSamples = 82; % Spatial sampling of [0,radius] domain
phi_nbSamples = 1; % Uniform sampling of the azimuth angle 
theta_max = 10; % maximal polar angle of incident ray - should be saved
theta_nbSamples = 80; %uniform sampling polar angle range

%% Choose input output plane
% Offset describes the distance in front of the first lens surface and the
% distance behind the last lens surface
offset=0.1; % mm


%% Generate lookup table
% Bringing direction on z axis back just in case it will be used in the
% future. The polynomial fitting indicates z direction can be ignored.

% This generate a lookup table between (x,u,v,w) (input plane) and
% (x,y,u,v,w) in the output plane.
% Because of rotational symmetry we only sample points on the x-axis.
% A rotation matrix can always be used to rotate an arbitrary coordinate to
% the position such that the y coordinate is zero.



[input,output,planes] = raytraceLightField(lensR,spatial_nbSamples,...
        theta_max,theta_nbSamples,phi_nbSamples,offset, 'visualize', true,'maxradius',0.4,'phimin',90,'phimax',90);


%% Fit rational functions

x = linspace(0, 0.4,spatial_nbSamples)';
u=sind(linspace(0,theta_max,theta_nbSamples)); % polar angle

% translate and stretch domain to be beween -1 and 1
P = @(p,q) (legendreP(p,(x-max(x)/2)/max(x/2))).*legendreP(q,(u-0.5*max(u))/(0.5*max(u)));


counter=1;
for i=1:numel(x)
    for t=1:numel(u)
            f(i,t) = output(counter,2);
            counter=counter+1;
    end
end
%%
fapprox=zeros(size(f));
clear a;
for p=0:5
    for q=0:5
        [p,q]
        a(p+1,q+1) = trapz(u,trapz(x,f.*P(p,q),1),2)./ trapz(u,trapz(x,P(p,q).^2,1),2);
        fapprox= fapprox+a(p+1,q+1)*P(p,q);
    end
end
%%
figure(2);clf;hold on;
surf(squeeze(u),squeeze(x),f);
surf(squeeze(u),squeeze(x),fapprox);




%%

norm(f-fapprox)/norm(f)


%% Comparison

polynomial_degree=4;
I_train = input(1:end,1:3);
O_train = output(1:end, :);
for i=1:size(O_train,2)
    poly{i} = polyfitn(I_train, O_train(:,i),polynomial_degree);
    poly{i}.VarNames={'x','u','v'};
    
    % save information about position of input output planes
    poly{i}.planes =planes;
end


