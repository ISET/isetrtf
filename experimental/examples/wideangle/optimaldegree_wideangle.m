%%
ieInit;

%%

lensName = 'wide.56deg.3.0mm.json'
%% Generate ray pairs
maxRadius = 6;
minRadius = 0;
offset=0.1;

[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', true,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset));





%% Polynomial fit
polyDeg = 5

degrees=1:7;
for p=1:numel(degrees)

    polyDeg=degrees(p);
% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

circleRadii =[    1.2700    1.3500   10.0000]
circleSensitivities =[   -1.6628    0.8298  -15.6821]
circlePlaneZ = 3;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'plane offset',offset,...
    'pupil radii', pupilRadii,...
    'circle radii',circleRadii,...
    'circle sensitivities',circleSensitivities,...
    'circle plane z',circlePlaneZ,...
    'lensthickness',lensThickness);

for i=1:(numel(polyModel)-1)
    E(p,i)=polyModel{i}.RMSE;
end

end

%%
figure(2);clf;
subplot(211)
title(['Optimal Degree - ' lensName])
plot(degrees,E,'.-','markersize',10)
xlabel('Polynomial Degree')
ylabel('Abolute RMSE')
legh=legend('$x$','$y$','$z$','$d_x$','$d_y$')
legh.Box='off'
subplot(212)
plot(degrees,E./E(1,:),'.-','markersize',10)
ylabel('RMSE  / REMSE (degree=1)')
xlabel('Polynomial Degree')


 pause(1);   
 set(findall(gcf,'-property','FontSize'),'FontSize',13);
 set(findall(gcf,'-property','interpreter'),'interpreter','latex');
 