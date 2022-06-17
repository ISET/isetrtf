%% Generate all figures related to Edge Spread Functions
%
% This script is an integration test for our RTF implementation in PBRT. 
% We do this by calculating the edge spread functions (ESF) (on-axis) for two distances
% of a step function chart. These ESF functions are compared to the ESF obtained with the
% ZEMAX model using zemax. In all cases, for high enough polynomial degree, a a good match is obtained.
% 
% We choose a high number of pixels (4000) to achieve submicron resolution and high number of rays per
% pixel (20000) to minimze the contribution of rendering noise.
% This is possible in reasonable amount of time because this script renders the scene for only one row
% of pixels.
%
%
% The difference between the ESF from zemax and the RTF is quantified using
% RMSE. To do this, the RTF result is resampled first onto the same grid as
% the zemax groundtruth. It is possible that some values cannot be
% interpolated (and are hence extrapolated). This produces NANS which are
% filtered. Before calculateing the RMSE we also filter out the region
% where the zemax ESF is exactly zero. This is because this would skew the
% RMSE error downwards depending on how long the zero region is taken. The
% longer the zero region, the more it pulls down the average error.


%
% Thomas Goossens
% May 2022

clear; close all
ieInit;
config={};
addpath('functions/')

%% Define simulation configurations 

%%



config{end+1}=[]
config{end}.rtfname='petzval-5mminput-zemax';
config{end}.distances = [3000 3500];
config{end}.filmdistance_mm=18.667;
config{end}.filmdiagonal_mm=2*45/100;
config{end}.degrees=[1:16];
config{end}.rays=20000;
config{end}.resolution=4000;
config{end}.zemaxfileESF='data/ESF/esf-petzval.mat';


%% Wide angle lens with smaller image circle - converges already for polynomial degree 5
config{end+1}=[]
config{end}.rtfname='wideangle200deg-limitcircle-zemax';
config{end}.distances = [3000 100]; % Distance of object as measured from lens front vertex (mm)
config{end}.filmdistance_mm=2.010; % Distance of sensor from rear vertex
config{end}.filmdiagonal_mm=2*1.23/100; 
config{end}.degrees=[1:12];
config{end}.rays=20000; % Number of rays per film pixel to trace
config{end}.resolution=4000; % Number of pixels (horizontally)
config{end}.zemaxfileESF='data/ESF/esf-wideangle200deg.mat'; % Where to find the ZEMAX file with ESF and LSF data





%%
config{end+1}=[]
config{end}.rtfname='inversetelephoto-zemax';
config{end}.distances = [3000 40];
config{end}.filmdistance_mm=1.195;
config{end}.filmdiagonal_mm=2*2/100;
config{end}.degrees=[1:16];
config{end}.rays=20000;
config{end}.resolution=4000;
config{end}.zemaxfileESF='data/ESF/esf-inversetelephoto.mat';




%%
config{end+1}=[]
config{end}.rtfname='dgauss28deg-zemax';
config{end}.distances = [1000 1200]
config{end}.filmdistance_mm=67.768;
config{end}.filmdiagonal_mm=150/100;
config{end}.degrees=[1:16]; % Polynomial degrees to try
config{end}.rays=20000;
config{end}.resolution=4000;
config{end}.zemaxfileESF='data/ESF/esf-dgauss28deg.mat';



%%
config{end+1}=[]
config{end}.rtfname='wideangle200deg-circle-zemax';
config{end}.distances = [3000 100]; % Distance of object as measured from lens front vertex (mm)
config{end}.filmdistance_mm=2.010; % Distance of sensor from rear vertex
config{end}.filmdiagonal_mm=2*1.23/100; 
config{end}.degrees=[1:16]; % Polynomial degrees to try
config{end}.rays=20000; % Number of rays per film pixel to trace
config{end}.resolution=4000; % Number of pixels (horizontally)
config{end}.zemaxfileESF='data/ESF/esf-wideangle200deg.mat'; % Where to find the ZEMAX file with ESF and LSF data




%%
config{end+1}=[]
config{end}.rtfname='wideangle200deg-offset0-circle-zemax';
config{end}.distances = [3000 100]; % Distance of object as measured from lens front vertex (mm)
config{end}.filmdistance_mm=2.010; % Distance of sensor from rear vertex
config{end}.filmdiagonal_mm=2*1.23/100; 
config{end}.degrees=[1:16]; % Polynomial degrees to try
config{end}.rays=20000; % Number of rays per film pixel to trace
config{end}.resolution=4000; % Number of pixels (horizontally)
config{end}.zemaxfileESF='data/ESF/esf-wideangle200deg.mat'; % Where to find the ZEMAX file with ESF and LSF data







%%
config{end+1}=[]
config{end}.rtfname='tessar-zemax';
config{end}.distances = [1267.384 2000]
config{end}.filmdistance_mm=100;
config{end}.filmdiagonal_mm=2*50.5/100;
config{end}.degrees=[1:16];
config{end}.rays=20000;
config{end}.resolution=4000;
config{end}.zemaxfileESF='data/ESF/esf-tessar.mat';






%%
config{end+1}=[]
config{end}.rtfname='cooke40deg-zemax';
config{end}.distances = [300 500]
config{end}.filmdistance_mm=51.915;
config{end}.filmdiagonal_mm=2.4;
config{end}.degrees=[1:16];
config{end}.rays=20000;
config{end}.resolution=4000;
config{end}.zemaxfileESF='data/ESF/esf-cooke40deg.mat';






%% Calculate ESF
for i=1:numel(config)
    c=config{i};
    
    disp(['Generate ESF for ' c.rtfname])
    [esf,pixels,noisefloorTemp]=calculateESF('rtfName',c.rtfname,'distances',c.distances,...
        'filmdistance',c.filmdistance_mm,'filmdiagonal',c.filmdiagonal_mm,...
        'rays',c.rays,'degrees',c.degrees,'resolution',c.resolution);

    esfPBRT{i}=esf;
    noisefloor{i}=noisefloorTemp;
    pixelsPBRT{i}=pixels;


end

%save ./data/tmp/dataESF-1to16deg.mat % Save data for later use

% Play glorious soud when ready
load handel;sound(y,Fs);




%% Make Plots of RMS Error 
for i=1:numel(config)
    c=config{i};
    disp(['Generate Error Plots for ' c.rtfname])

    % Load Zemax ESF File
    esfZemax= load(c.zemaxfileESF);esfZemax=esfZemax.lsf;

    % Plots
    fig=figure(i);clf;
    set(gca,'Yscale','log')
    plotESFerror(c.degrees,pixelsPBRT{i},c.distances,esfPBRT{i},noisefloor{i},esfZemax)
    %set(gca,'Yscale','linear')
    ylim([0 0.6])
    xlim([1 16])    
    %saveas(gcf,['./fig/ESF/esf-logerror-' c.rtfname '.png'])
    
    
    set(gca,'Yscale','linear')
    saveas(gcf,['./fig/ESF/esf-error-' c.rtfname '.png'])

        
end


%% Make Plots ESF Vs zemax

for i=1:numel(config)
    c=config{i};
    
    
    disp(['Generate ESF Plots for ' c.rtfname])

    % Load Zemax ESF File
    esfZemax= load(c.zemaxfileESF);esfZemax=esfZemax.lsf;
    
    % Plots
    figure(i);clf; hold on
    
    % Only add legend for double gauss lens
    addzemaxtolegend= false;
    if(c.rtfname=="dgauss28deg-zemax"),    addzemaxtolegend= true;        end
    
    
    plotESF(c.degrees,pixelsPBRT{i},c.distances,esfPBRT{i},esfZemax,addzemaxtolegend)
     
    exportgraphics(gcf,['./fig/ESF/esf-' c.rtfname '.png'])
    
    
end

