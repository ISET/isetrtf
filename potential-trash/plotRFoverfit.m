clear;
xscale={};
paths={};
imageheights = {};
filmdistance_mm={};
receptiveFieldDistanceFromFilm_mm={};
gridpoints={};
gridsize_mm={};
degrees={}



%{
paths{end+1}= 'dgauss28deg'; 
imageheights{end+1} = [0 10 15 ];
filmdistance_mm{end+1}=80; 
receptiveFieldDistanceFromFilm_mm{end+1}=615.67388;
gridpoints{end+1}=100;
gridsize_mm{end+1}=30;
degrees{end+1}=[1 2 3 4 5 6 7 8];
%}

paths{end+1}= 'cooke40deg';
imageheights{end+1} = [0 5 10 12 ]
filmdistance_mm{end+1}=50;
receptiveFieldDistanceFromFilm_mm{end+1}=417.96897
gridpoints{end+1}=400
gridsize_mm{end+1}=30
degrees{end+1}=[5 6 7 8 9 ]



delta=200


%%
colors = hot;
fig=figure(1);clf; hold on
fig.Position=[680 643 930 335];
for p=1:numel(paths)
zemaxlsf_file=fullfile(paths{p},'zemax-lsf.mat');

rtfName=[paths{p} '-undersample-zemax-delta' num2str(delta)];

receptivefieldFigure(zemaxlsf_file,rtfName,imageheights{p},filmdistance_mm{p},receptiveFieldDistanceFromFilm_mm{p},gridsize_mm{p},gridpoints{p},degrees{p})




end
