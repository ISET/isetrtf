clear; close all
xscale={};
paths={};
imageheights = {};
filmdistance_mm={};
receptiveFieldDistanceFromFilm_mm={};
gridpoints={};
gridsize_mm={};
degrees={}




%%
paths{end+1}= 'tessar-notsparse';
imageheights{end+1} = [0 5 8 ];
filmdistance_mm{end+1}=100; thickness=16.4
%receptiveFieldDistanceFromFilm_mm{end+1}=100+16.4+1250
receptiveFieldDistanceFromFilm_mm{end+1}=1383.78413;
gridpoints{end+1}=200;
gridsize_mm{end+1}=20;
degrees{end+1}=[5:18];


paths{end+1}= 'wideangle200deg-circle';
imageheights{end+1} = [0 0.5 0.6 ]
filmdistance_mm{end+1}=2.13; 
%receptiveFieldDistanceFromFilm_mm{end+1}=18.19357
receptiveFieldDistanceFromFilm_mm{end+1}=18.51843
gridpoints{end+1}=400
gridsize_mm{end+1}=4
degrees{end+1}=[4:13]

paths{end+1}= 'petzval';
imageheights{end+1} = [0 10 15 ]
filmdistance_mm{end+1}=20;
%receptiveFieldDistanceFromFilm_mm{end+1}=2313.88312;
receptiveFieldDistanceFromFilm_mm{end+1}=2365.78060
gridpoints{end+1}=200
gridsize_mm{end+1}=30
degrees{end+1}=[2 3 4 5 6 7 8 10 11 12]




paths{end+1}= 'cooke40deg';
imageheights{end+1} = [0 5 10 ]
filmdistance_mm{end+1}=50;
%receptiveFieldDistanceFromFilm_mm{end+1}=417.96897
receptiveFieldDistanceFromFilm_mm{end+1}=434.25819
gridpoints{end+1}=100
gridsize_mm{end+1}=30
degrees{end+1}=[2 3 4 5 6 7 8 9 10 11 12]



paths{end+1}= 'dgauss28deg'; 
imageheights{end+1} = [0 10 15 ];
filmdistance_mm{end+1}=80; 
receptiveFieldDistanceFromFilm_mm{end+1}=615.67388;
gridpoints{end+1}=100;
gridsize_mm{end+1}=30;
degrees{end+1}=[2 3 4 5 6 7];


paths{end+1}= 'inversetelephoto';
imageheights{end+1} = [0 0.1 0.2 ]
filmdistance_mm{end+1}=1.5;
%receptiveFieldDistanceFromFilm_mm{end+1}=5.80140
receptiveFieldDistanceFromFilm_mm{end+1}=5.71782;
gridpoints{end+1}=300
gridsize_mm{end+1}=1
degrees{end+1}=[2 3 4 5 6 7 8]





paths{end+1}= 'tessar-moredata';
imageheights{end+1} = [0 5 8 ];
filmdistance_mm{end+1}=100; thickness=16.4
%receptiveFieldDistanceFromFilm_mm{end+1}=100+16.4+1250
receptiveFieldDistanceFromFilm_mm{end+1}=1383.78413;
gridpoints{end+1}=200;
gridsize_mm{end+1}=20;
degrees{end+1}=[5:13];


paths{end+1}= 'wideangle200deg-circle';
imageheights{end+1} = [0 0.5 0.6 ]
filmdistance_mm{end+1}=2.13; 
%receptiveFieldDistanceFromFilm_mm{end+1}=18.19357
receptiveFieldDistanceFromFilm_mm{end+1}=18.51843
gridpoints{end+1}=400
gridsize_mm{end+1}=4
degrees{end+1}=[4:13]



paths{end+1}= 'wideangle200deg-closeinput-circle';
imageheights{end+1} = [0 0.5 0.6 1]
filmdistance_mm{end+1}=2.13; 
receptiveFieldDistanceFromFilm_mm{end+1}=18.19357
gridpoints{end+1}=400
gridsize_mm{end+1}=4
degrees{end+1}=[4:9]


%%
colors = hot;
fig=figure(1);clf; hold on
fig.Position=[680 643 930 335];
for p=1:numel(paths)
zemaxlsf_file=fullfile(paths{p},'zemax-lsf.mat');

rtfName=[paths{p} '-zemax'];

[crosstemp,crossZero]=receptivefieldFigure(zemaxlsf_file,rtfName,imageheights{p},filmdistance_mm{p},receptiveFieldDistanceFromFilm_mm{p},gridsize_mm{p},gridpoints{p},degrees{p})
crossMax{p}=crosstemp;
crossAtZeroLag{p}=crossZero;

figure;

subplot(311)
plot(degrees{p},crosstemp(:,:,1));
title(['Peak Correlation  ' rtfName])
ylim([0 1])
subplot(312)
plot(degrees{p},crosstemp(:,:,2))
title('Shift')
xlabel('Degrees')
ylabel('Micron')

subplot(313)
plot(degrees{p},crossZero(:,:,1));
title(['Correlation at Zero Lag' rtfName])
ylim([0 1])

pause(1)
exportgraphics(gcf,['./fig/crosscorr-' rtfName  '.pdf'])
%  Save crosscorrelation data, do every iteration for backup purpoes
lastPathIndex=p; % Information  For manual recovery from crash
save('crosscorr-data.mat','paths','crossMax','crossAtZeroLag','lastPathIndex')


return;
end





%% Generate table Cross Corre table
    figure
%%  Crosscorr and shift
colors = hot;

ylabels = {'Peak Correlation','Shift (micron)'}

%fig=figure(f);clf; hold on
%fig.Position=[680 643 930 335];
%fig.Position=[513 493 1121 181];

for p=1:numel(paths)
    fig=figure; hold on
    fig.Position=[680 757 184 209]
    
for f=[1 2]    
    subplot(2,1,f); hold on
    rtfName=[paths{p} '-zemax'];
         
    for i=1:numel(imageheights{p})
        c= crossMax{p}(:,i,f);
        plot(degrees{p}',c,'color',colors(round(255/6)*i,:),'linewidth',2);
    end
        
    % Size of subplots
    %ax=gca; ax.Position(2:4)=[0.25 0.0996 0.5176]
    if(f==2)
        xlabel('Degree')
    end
    %title(paths{p})
    title(ylabels{f})
    deg=degrees{p};
    xticks(deg(1:1:end))

    if(p==1)
      %  ylabel(ylabels{f});
    end
    if(f==1)
        ylim([0 1])
    end
    
    

    
end
%exportgraphics(gcf,['./fig/crosscorrelations-' ylabels{f} '-' rtfName '.pdf'])
exportgraphics(gcf,['./fig/LSF/crosscorrelations-' rtfName '.pdf'])

end

%%
%% 
colors = hot;

ylabels = {'Correlation at Zero Lag'}
for f=[1]
fig=figure(f);clf; hold on
%fig.Position=[680 643 930 335];
fig.Position=[513 493 1121 181];

for p=1:numel(paths)
    
    subplot(2,numel(paths),p); hold on
    rtfName=[paths{p} '-zemax'];


         
    for i=1:numel(imageheights{p})
        c= crossAtZeroLag{p}(:,i,f);
        plot(degrees{p}',c,'color',colors(round(255/6)*i,:),'linewidth',2);
    end
        
    % Size of subplots
    ax=gca; ax.Position(2:4)=[0.25 0.0996 0.5176]
    xlabel('Degree')
    title(paths{p})
    deg=degrees{p};
    xticks(deg(1:end))

    if(p==1)
        ylabel(ylabels{f});
    end
    if(f==1)
        ylim([0 1])
    end
    
    exportgraphics(gcf,['./fig/crosscorrelations_zerolag-' ylabels{f} '.pdf'])

    
end
exportgraphics(gcf,['./fig/crosscorrelations_zerolag-' ylabels{f} '.pdf'])
end