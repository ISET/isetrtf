clear; close all
load cache/dgauss.22deg.3.0mm.json-May-14-2021_5-42PM.mat;              
  



%% Bottom Circle
position_selection=5
P=pupilshape_trace(1:2,position_selection,:) ;

figure(1);clf;
h=plot(P(1,:),P(2,:))
axis equal


% Most bottom edge
ybottom=min(P(2,:))
nCircles = 5;
radii =linspace(0,1.3,nCircles)
for r=1:numel(radii)
    radius = radii(r);
    centerY = ybottom+radius;
    hcirc=viscircles([0 centerY],radius)
    hcirc.Children(1).Color=[0.8 0 0 r/(nCircles)]
end
 
ax=gca;
ax.XAxis.Visible='off';
ax.YAxis.Visible='off';
saveas(gcf,'bottomcircle.eps','epsc')


xlimits = xlim
ylimits = ylim
%% Bottom circle
position_selection=8
P=pupilshape_trace(1:2,position_selection,:) ;
figure(2);clf;
h=plot(P(1,:),P(2,:))
axis equal


% Most bottom edge
ytop=max(P(2,:))
nCircles = 5;
radii = [1 2 3 5 8]
for r=1:numel(radii)
    radius = radii(r);
    centerY = ytop-radius;
    hcirc=viscircles([0 centerY],radius)
    hcirc.Children(1).Color=[0.8 0 0 r/(nCircles)]
end

xlim(xlimits)
ylim([  -1.9896    0.6104])
ax=gca;
ax.XAxis.Visible='off';
ax.YAxis.Visible='off';
saveas(gcf,'topcircle.eps','epsc')
