%% Generate all figures related to Edge Spread Functions
%
% This script is an integration test for our RTF implementation in PBRT. 
% We do this by calculating the edge spread functions (ESF) (on-axis) for several
% depths. These ESF functions are compared to the ESF obtained with the
% ZEMAX model. In all cases, for high enough polynomial degree, a near
% perfect match is obtained.
%
% Thomas Goossens
% January 2022
clear; close all
ieInit;
config={};


%% Define simulation configurations 
%%



config{end+1}=[]
config{end}.rtfname='petzval-zemax';
config{end}.distances = [3000 3500];
config{end}.scalefactors=[0.01 0.3]/1.5
config{end}.filmdistance_mm=18.667;
config{end}.filmdiagonal_mm=2*30/100;
config{end}.degrees=[1 12];
config{end}.rays=5000;
config{end}.resolution=1000;
config{end}.zemaxfileESF='data/ESF/esf-petzval.mat';


%%
config{end+1}=[]
config{end}.rtfname='inversetelephoto-zemax';
config{end}.distances = [3000 40];
config{end}.scalefactors=[0.05 0.2]
config{end}.filmdistance_mm=1.195;
config{end}.filmdiagonal_mm=2*1/100;
config{end}.degrees=[1:8];
config{end}.rays=2000;
config{end}.resolution=2000;
config{end}.zemaxfileESF='data/ESF/esf-inversetelephoto.mat';

%%
config{end+1}=[]
config{end}.rtfname='dgauss28deg-zemax';
config{end}.distances = [1000 1200]
config{end}.scalefactors=[0.03 0.3]
config{end}.filmdistance_mm=67.768;
config{end}.filmdiagonal_mm=150/100;
config{end}.degrees=[1:7];
config{end}.rays=4000;
config{end}.resolution=1000;
config{end}.zemaxfileESF='data/ESF/esf-dgauss28deg.mat';



%%
config{end+1}=[]
config{end}.rtfname='wideangle200deg-circle-zemax';
config{end}.distances = [3000 100]; % Distance of object as measured from lens front vertex (mm)
config{end}.scalefactors=[0.6 0.4] % Scale the size of the chart accorrdingly to get enough resolution (make small avoid smoothing)
config{end}.filmdistance_mm=2.010; % Distance of sensor from rear vertex
config{end}.filmdiagonal_mm=2*1.23/100; 
config{end}.degrees=[1:13]; % Polynomial degrees to try
config{end}.rays=2000; % Number of rays per film pixel to trace
config{end}.resolution=2000; % Number of pixels (horizontally)
config{end}.zemaxfileESF='data/ESF/esf-wideangle200deg.mat'; % Where to find the ZEMAX file with ESF and LSF data






%%
config{end+1}=[]
config{end}.rtfname='tessar-zemax';
config{end}.distances = [1267.384 2000]
config{end}.scalefactors=[0.1 0.3]
config{end}.filmdistance_mm=100;
config{end}.filmdiagonal_mm=2*50.5/100;
config{end}.degrees=[1:16];
config{end}.rays=2000;
config{end}.resolution=1000;
config{end}.zemaxfileESF='data/ESF/esf-tessar.mat';



%%
config{end+1}=[]
config{end}.rtfname='cooke40deg-zemax';
config{end}.distances = [300 500]
config{end}.scalefactors=[0.03 0.4]
config{end}.filmdistance_mm=51.915;
config{end}.filmdiagonal_mm=2.4;
config{end}.degrees=[1:12];
config{end}.rays=2000;
config{end}.resolution=1000;
config{end}.zemaxfileESF='data/ESF/esf-cooke40deg.mat';





%% Generate ESF
for i=1:numel(config)
    c=config{i};
    disp(['Generate ESF for ' c.rtfname])
    [esf,pixels,noisefloorTemp]=generateESF('rtfName',c.rtfname,'distances',c.distances,...
        'scalefactors',c.scalefactors,'filmdistance',c.filmdistance_mm,'filmdiagonal',c.filmdiagonal_mm,...
        'rays',c.rays,'degrees',c.degrees,'resolution',c.resolution);

    esfPBRT{i}=esf;
    noisefloor{i}=noisefloorTemp;
    pixelsPBRT{i}=pixels;
    

end


%% Make Plots of RMS Error 
for i=1:numel(config)
    c=config{i};
    disp(['Generate Error Plots for ' c.rtfname])

    % Load Zemax ESF File
    esfZemax= load(c.zemaxfileESF);esfZemax=esfZemax.lsf;

    % Plots
    fig=figure(i);clf;
    plotESFerror(c.degrees,pixelsPBRT{i},c.distances,esfPBRT{i},noisefloor{i},esfZemax)
    set(gca,'Yscale','linear')
    exportgraphics(gcf,['./fig/ESF/esf-error-' c.rtfname '.pdf'])
    set(gca,'Yscale','log')
        if(c.rtfname == "dgauss28deg-zemax")
       % Add label for rendering noise level
       text(0.1,1.8e-3,sprintf('RMS Rendering Noise'),'interpreter','latex','fontsize',9)
    end
    exportgraphics(gcf,['./fig/ESF/esf-logerror-' c.rtfname '.pdf'])

        
end


%% Make Plots ESF 

for i=1:numel(config)
    c=config{i};
    disp(['Generate ESF Plots for ' c.rtfname])

    % Load Zemax ESF File
    esfZemax= load(c.zemaxfileESF);esfZemax=esfZemax.lsf;

    % Plots
    figure(i);clf; hold on
    
   % Add zemax legend on double gauss lens
    if(i==5)
        line([17 220] , 0.9*[1 1],'linestyle','-.','color','k','linewidth',2)
        text(220,0.9,'Zemax')
    end
    plotESF(c.degrees,pixelsPBRT{i},c.distances,esfPBRT{i},esfZemax)
    if(i==4)        xlim([-100 100]),    end
    if(i==6)        xlim([-50 50]),    end
    exportgraphics(gcf,['./fig/ESF/esf-' c.rtfname '.pdf'])
    
  
end

