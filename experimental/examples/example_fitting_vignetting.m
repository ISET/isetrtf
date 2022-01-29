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
%lensFileName = '2el.XXdeg.6.0mm.json'
% lensFileName = 'wide.56deg.3.0mm.json';
%lensR = reverselens(lensFileName);
% exist(lensFileName,'file');
lensR = lensC('fileName', lensFileName);
wave = lensR.get('wave');

%% Sampling options 
spatial_nbSamples = 10; % Spatial sampling of [0,radius] domain
phi_nbSamples = 10; % Uniform sampling of the azimuth angle 
theta_max = 40; % maximal polar angle of incident ray
theta_nbSamples = 40; %uniform sampling polar angle range

%% Choose input output plane
% Offset describes the distance in front of the first lens surface and the
% distance behind the last lens surface
offset=0.1; % mm

%% Fitting options
% A polynomial degree of 4 seems to be the minimum required to get a
% reasonable
% fit. TODO: find a physical reason for this.
polynomial_degree=7; 

%% Generate lookup table
% Bringing direction on z axis back just in case it will be used in the
% future. The polynomial fitting indicates z direction can be ignored.

% This generate a lookup table between (x,u,v,w) (input plane) and
% (x,y,u,v,w) in the output plane.
% Because of rotational symmetry we only sample points on the x-axis.
% A rotation matrix can always be used to rotate an arbitrary coordinate to
% the position such that the y coordinate is zero.

[input,output,planes] = raytracelookuptable_rotational(lensR,spatial_nbSamples,...
        theta_max,theta_nbSamples,phi_nbSamples,offset, 'visualize', true,'radiusproportion',1);

%{
% Save the input and output rays 
fName = 'rayIO.mat';
savePath = fullfile(ilensRootPath, 'local', fName);
save(savePath, 'input', 'output', 'planes');
%}

%% Fit polynomial
% Each output variable will be predicted
% by a multivariate polynomial with three variables: x,u,v.
% Each fitted polynomial is a struct containing all information about the quality of the fit, powers and coefficients.
%
% An analytical expression can be generated using 'polyn2sym(poly{i})'


% % Full sampling set
% inputP = input(1:3,:,:,:);
% I = inputP(:,:)';
% O = output(:,:)';
% 
% % Training set 
% I_train = inputP(:,1:2:end)';
% O_train = output(:,1:2:end)';

I_train = input(1:end,1:3);
O_train = output(1:end,:);
for i=1:size(O_train,2)
    poly{i} = polyfitn(I_train, O_train(:,i),polynomial_degree);
    poly{i}.VarNames={'x','u','v'};
    
    % save information about position of input output planes
    poly{i}.planes =planes;
end

    
%% Save polynomial to file
fPath = fullfile(ilensRootPath, 'local', 'poly.mat');
save(fPath,'poly')

%% Fit rational functions

%%  Visualize polynomial fit 
labels = {'x','y','u','v','w'};
fig=figure(6);clf;
fig.Position=[231 386 1419 311];
pred = zeros(size(input, 1), 5);

for i=1:5
    pred(:,i)= polyvaln(poly{i},input(:,1:3));
    
    subplot(1,5,i); hold on;
    h = scatter(pred(:,i),output(:,i),'Marker','.','MarkerEdgeColor','r');
    plot(max(abs(output(:,i)))*[-1 1],max(abs(output(:,i)))*[-1 1],'k','linewidth',1)
    xlim([min(output(:,i)) max(output(:,i))])
    title(labels{i})
    xlabel('Polynomial')
    ylabel('Ray trace')
end

%% Plot relative error

ind = find(~isnan(output));
err = mean(abs(pred(ind) - output(ind)), 1);


