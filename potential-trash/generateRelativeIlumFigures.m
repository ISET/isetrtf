%% Generate all relative Illumination  figures comparing PBRT RTF to ZEMAX
%
%  This uses the data from data/relativeillumination-pbrt/
% Thomas Goossens

clear; close all
xscale={};
paths={};

paths{end+1}= 'dgauss28deg';
paths{end+1}= 'inversetelephoto';
paths{end+1}= 'petzval';
paths{end+1}= 'cooke40deg';
paths{end+1}= 'tessar'; 
paths{end+1}= 'wideangle200deg-circle';






%% Each lens seperate figure
colors = hot;
for p=1:numel(paths)
    fig=figure(p);clf; hold on
    fig.Position=[680 811 180 155];  % Very small
    
    file=fullfile('data/relativeillumination-pbrt', [paths{p}, '-comparison.mat']);
    rel=load(file);
    xnormalisation=1
    hpbrt=plot(rel.relativeIllum.pbrt.x,rel.relativeIllum.pbrt.y,'color',colors(80,:),'linewidth',2)
    hzemax=plot(rel.relativeIllum.zemax.x,rel.relativeIllum.zemax.y,'k-.','linewidth',2,'color','k')
    xlim([0 inf])
    xlabel('Image height (mm)')

    if(p==1)    
    legh=legend([hpbrt,hzemax],'RTF','Zemax')
    legh.Box='off'
    %legh.Orientation = 'horizontal'
    legh.Position=[0.162 0.3532 0.4833 0.1097]
    end

% Figure styles
box on

set(findall(gcf,'-property','FontSize'),'FontSize',11);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');
pause(1)
exportgraphics(gcf,['./fig/relativeillumination/' paths{p} '.pdf'])
end



