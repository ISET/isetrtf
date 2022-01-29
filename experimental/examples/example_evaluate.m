%% Example of evaluating the fitting polynomial for a rotationally symmetric lens.
% The polynomial itself was fitted for spatial sampling along the x-axis.
% This script shows how using a rotation matrix, one can bring the input
% ray to the (x,u,v) space, use the polynomial fit, and then rotate the map
% back.

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
lensFileName = fullfile(ilensRootPath, 'local', 'dgauss.22deg.3.0mm-reverse.json');
exist(lensFileName,'file');
lens = lensC('fileName', lensFileName)
wave = lens.get('wave');



%% Load polynomial
fPath = fullfile(ilensRootPath, 'local', 'poly.mat');
load(fPath)


%% add final surface for tracing (This modifies the lens!)
lens = lens_addfinalsurface(lens,poly{1}.planes.output);

%% Trace a single ray (full 3D)
entrance_z=poly{1}.planes.input;

% Ray origin on the input plane in polar coordinates (r,alpha)
% with alpha=0 representing the x-axis
alpha=40; r=0.6;
origin=[r*cosd(alpha) r*sind(alpha) entrance_z];

% Direction of the ray in spherical coordinates
theta=-10; %polar angle (>0)
phi=0; % azimuth
direction = [sind(theta).*cosd(phi)  sind(theta)*sind(phi)  cosd(theta)];

[out_pos,out_direction]=trace_io(lens,origin,direction)

%% Validation with rotationally independent polynomial
% Step 1: Define rotation matrix
% here we know alpha directly, in PBRT you will have to calculate this
% manually as alpha=atand(origin(2)/origin(1))
a= 90 - alpha; 
rot = [cosd(a) -sind(a);
       sind(a)  cosd(a)]; 
irot= inv(rot); % inverse rotation for rotating back

% Step 2: Rotate such that y-coordinate is zero (i.e alpha=0)

rho =  sqrt(origin(1).^2+origin(2).^2); % radial coordinate (=x axis after rotation)
dir_rotated=  rot*direction(1:2)';

% Step 3: Evaluate the polynomials
for i=1:numel(poly)
        in_rot = [sqrt(origin(1).^2+origin(2).^2) dir_rotated(1) dir_rotated(2)];
        output_rot(i,1)=polyvaln(poly{i},in_rot);
end
%output_rot=neural([rho dir_rotated']');

% Step 4: Rotate back (x,y) and (u,v)   
% Rotate back to original angle
output_rot(1:2,1) = irot*output_rot(1:2,1); %(x,y)
output_rot(3:4,1) = irot*output_rot(3:4,1); %(u,v)

%% Compare 3D trace and rotationally invariant trace

output_3d=[out_pos(1:2),out_direction]'

relative_error=norm(output_rot-output_3d)/norm(output_3d)

 
