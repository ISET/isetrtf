function [lensR, lensRPath] = lensReverse(lensname, varargin)
%%
% TODO: Turn this to be a lens class method
% Reverse a lens structure
% 
% Synopsis:
%   lensR = reverselens(lensname, varargin)
%
% Inputs:
%   
% Returns:
% 
% Optional:
%   
% Description:
%   
% Thomas Goossens, 2021
%
% Updates:
%   ZLY(03/15/2021): Make the code generalizable to other lens models.
%%  Reverse lens test （old code）
%{
clear;close all;
ieInit
%%
X=[1.768500	0.225600	1.670000	1.512000
5.089800	0.007200	1.000000	1.512000
1.156500	0.241500	1.670000	1.380000
2.446200	0.196500	1.699000	1.380000
0.765000	0.342300	1.000000	1.140000
0.000000	0.270000	0.000000	1.023000
-0.869700	0.070800	1.603000	1.020000
2.446200	0.363900	1.658000	1.200000
-1.223100	0.011400	1.000000	1.200000
26.223900	0.193200	1.717000	1.200000
-2.383800	0.000000	1.000000	1.200000];
X0=X;


% Reverse order
X=flip(X,1);
% Change curvature sign
X(:,1)=-X(:,1);

% Shift relative distances
X(:,2)=circshift(X(:,2),-1,1);

% shift refractive index relative to paerture

X(1:5,3)= circshift(X(1:5,3),-1);
%-------aperture remains unchanged
X(7:11,3)= circshift(X(7:11,3),-1);


[X0 X]
%}
% Examples:
%{
lensname = 'dgauss.22deg.3.0mm.json';
lensR = reverselens(lensname);
%}
%{
lensname = 'tessar.22deg.100.0mm.json';
lensR = reverselens(lensname);
%}
%% Input parser
p = inputParser;
p.addRequired('lensname', @ischar);
p.addParameter('visualize', true, @islogical);
p.parse(lensname, varargin{:});
visualize = p.Results.visualize;

%% load and modify json
lens = lensC('filename', which(lensname));
[~,f,~] = fileparts(lensname);
dataMatrix = lensMatrix(lens);

% Aperture index
apertureInd = find(dataMatrix(:,1) == 0 & dataMatrix(:,3) == 0);
% Reverse order
dataMatrix = flip(dataMatrix,1);
% Change curvature sign
dataMatrix(:,1) = -dataMatrix(:,1);
% Shift relative distances
dataMatrix(:,2)=circshift(dataMatrix(:,2),-1,1);
% shift refractive index relative to paerture
reverseApertureId=size(dataMatrix,1)-apertureInd+1; % needed for asymmetric lenses
dataMatrix(1:reverseApertureId-1,3)  = circshift(dataMatrix(1:reverseApertureId-1,3),-1);
dataMatrix(reverseApertureId + 1:end, 3) = circshift(dataMatrix(reverseApertureId + 1:end,3),-1);

% Read in as structure
J = jsonread(which(lensname));

for i = 1:size(dataMatrix,1)
    s = J.surfaces(i);
    s.radius = dataMatrix(i,1);
    s.thickness = dataMatrix(i,2);
    s.ior = dataMatrix(i,3);
    s.semi_aperture = 0.5 * dataMatrix(i,4);% Diameter -> radius
    surfaces(i) = s;
end

Jnew=J;
Jnew.name = [J.name '-reverse'];
Jnew.surfaces =surfaces;
opts.indent = ' ';
lensRPath = fullfile(ilensRootPath, 'local', strcat(f, '-reverse','.json'));
jsonwrite(lensRPath,Jnew, opts)

%% Read a lens file and create a lens
lens = lensC('filename', which(lensname));
%lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm-reverse.dat');
lensFileName = lensRPath;
lensR = lensC('fileName', lensFileName);

%%
if visualize
lens.draw; title('lens')
ax=gca;
lensR.draw; title(' rev')
ax2=gca;
ax2.XLim=ax.XLim;
ax2.Position=ax.Position;
end