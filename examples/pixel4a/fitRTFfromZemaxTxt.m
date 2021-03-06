%% Script to generate RTF for rear camera of  the Google Pixel4a smartphone
% This script 
%1. Configures the relevant parameters
%2. Loads dataset from zemax macro
%3. Fits RTF  for given polynomial degree and outputs JSON file to given
%directory
% 2022 Thomas Goossens
clear; close all;


%% 1. Lens name and properties
lensName='pixel4a-rearcamera-ellipse'
filmdistance_mm=0.464135918
offset_sensorside=filmdistance_mm; % the input plane was placed at the focal plane
offset_objectside=1.48002192; %%mm Position of the output plane
lensThickness=4.827; % As obtained from zemax (vertex to vertex distance)

%% 2. Load input output rays 
% load data generated by ZEMAX
X=dlmread('zemax-Gout-P4Ra_20111103.txt','\s',1);

% Extract input and output rays
iRays=X(:,[3 5 6]);
oRays=X(:,[8 9 10 11 12 13]);


%% 3.a RTF generation options
polyDeg = 5;
outputDir = '' % Produce in same folder as the script

visualize=true;

%% 4. Generate RTF and produce JSON file
rtfName = [lensName '-poly' num2str(polyDeg) '-raytransfer'];
rtf=generateRTFfromIO(lensName,rtfName,iRays,oRays,offset_sensorside,offset_objectside,lensThickness,'outputdir',outputDir,'visualize',visualize,'polynomialdegree',polyDeg)
