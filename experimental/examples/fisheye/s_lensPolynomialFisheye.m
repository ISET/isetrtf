%%
clear;
ieInit;

%%
close all
lensName = fullfile('../lenses/fisheye.87deg.3.0mm_semiaperture1.json');
%lensName = fullfile('../lenses/fisheye.87deg.3.0mm.json');

i=1

radii = 6
offset=radii(i)/2;
centerZ = offset-radii;

    disp(['radius= ' num2str(radii(i))])
    %addSphere=outputSphere(radii(i),0.1*radii(i)/10);
    addSphere=outputSphere(radii(i),offset);
    
    newlens = addSphere(lensReverse(lensName));
    newlens.draw
    pause(1);
    
    
    
%% Trace single ray for test
lensR=newlens;


origin=[0 1 -9];thetas=70:-0.1:-70;
%origin=[0 0.5 -9];thetas=30:-0.1:-50;%thetas=10:-0.1:-10;
%origin=[0 0.5 -9];thetas=-40:0.1:40;
origin = repmat(origin,[numel(thetas) 1]);
phi=0;
u=sind(thetas');
direction=[sind(thetas').*sind(phi) sind(thetas')*cosd(phi) cosd(thetas')]

[arrival_pos,arrival_dir]=rayTraceSingleRay(lensR,origin,direction)
ylim([-radii radii])




outputs = [arrival_pos arrival_dir]
x =outputs(:,1)
y =outputs(:,2)
z =outputs(:,3)
dy =outputs(:,5)
dz =outputs(:,6)
%% fdf
clear fpoly fsym fpad pred;
degree=8
fig=figure(2);clf; hold on;

sel = [2 3  5 6]
labels = {'x', 'y','z','dx','dy','dz'}

for o=1:numel(sel)
subplot(1,numel(sel),o);hold on;
out=outputs(:,sel(o));
plot(u,out,'k.')

fpoly{o}=polyfitn(u,outputs(:,sel(o)),degree)
fsym{o}=polyn2sym(fpoly{o})
pred=polyvaln(fpoly{o},u);
%pred=myNeuralNetworkFunction(u)
%fpad{o}=pade(fsym{o},'Order',[3 3])
plot(u,pred,'r')

%fplot(fpad)
xlim(1.5*[min(u) max(u)])
ylim([min(out) max(out)])
title(labels{sel(o)})
end


%%
    %% Generate ray pairs
    maxRadius = 2;
    minRadius = 0;
    offset=0.1;
    
    [iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
        'n radius samp', 50, 'elevation max', 60,...
        'nAzSamp',100,'nElSamp',100,...
        'reverse', true,...
        'max radius', maxRadius,...
        'min radius', minRadius,...
        'inputPlaneOffset',offset,...
        'outputSurface',addSphere);
    
    
% %% Spherical coordinates for output varibles
% 
% X=oRays(:,1);
% Y=oRays(:,2);
% Z=oRays(:,3);
% 
% R = sqrt(X.^2+Y.^2+Z.^2);
% theta = atan(Z./R);
% phi= atan2(Y,X);
%    
% 
% poly1 = polyfitn(iRays,R,5); 
% poly2 = polyfitn(iRays,theta,5); 
% poly3 = polyfitn(iRays,phi,5); 



    


%%

save('iotable-fisheye.87deg.3.0mm_semiaperture1.mat','iRays','oRays')


%% Angular only, so position of output surfece is implied and known externally not part of the fit?'

x=oRays(:,1);
y=oRays(:,2);
z=oRays(:,3)-centerZ;
[TH,PHI,R] = cart2sph(x,y,z);
dx =oRays(:,4);
dy =oRays(:,5);
dz =oRays(:,6);


    
%% Poly fit
    polyDeg = 3
    
    % Make a copy that will possibly be modified
    iRaysTemp=iRays;oRaysTemp=oRays;
    
    %iRaysTemp(:,end+1) = sqrt(1-iRays(:,2).^2-iRays(:,2).^2);
    % Normalize the spatial coordinates 
    %oRaysTemp(:,3)=oRaysTemp(:,3)-centerZ;
    %oRaysTemp(:,1:3)=oRaysTemp(:,1:3)/radii;
    
    
    %iRaysTemp(:,end+1)=oRays(:,3); %Make z position on output surface part of the proble?

    % Fit in spherical coordinates
    %oRaysTemp=[TH PHI R oRays(:,4:6)];
    % Pupils for Double gaussian only. (At this moment estimating this takes a long time get
    % high quality)
    
    pupilPos=pupilPos - planes.input;
    
    % Experiment: This works, the question is now why it gets into trouble
    % for d_z
    % Try to rays with d_z < 0  theory uis they are causing the problem
    
    deleteSelection=oRays(:,end) > 0.0;
    iRaysTemp(deleteSelection,:)=[];oRaysTemp(deleteSelection,:)=[];  %Delete selection
  
    
    
%% Segement radial distance  NOT WORKING

iRaysTemp=iRays;oRaysTemp=oRays;
deleteSelection=iRays(:,1) > 0.5;
iRaysTemp(deleteSelection,:)=[];oRaysTemp(deleteSelection,:)=[];  %Delete selection

%% Segement Angular

iRaysTemp=iRays;oRaysTemp=oRays;
deleteSelection=or(iRays(:,2)>0.5,iRays(:,3)>0.5)
iRaysTemp(deleteSelection,:)=[];oRaysTemp(deleteSelection,:)=[];  %Delete selection


%% Default no changes

iRaysTemp=iRays;oRaysTemp=oRays;

%%   FIt poly  

polyDeg = 15

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRaysTemp, oRaysTemp,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'pupil radii', pupilRadii,'lensthickness',lensThickness,'planeOffset',offset);

   for j=1:(numel(polyModel))
        error(j,i) = polyModel{j}.RMSE
    end
    
    

 %%
 in=iRays;
 out=oRays(:,3);
 polyModel  = polyfitn(iRays, oRays(:,end),5)
 

    
%%
figure;clf;scatter(oRays(:,1),neuralX(iRays))
figure;clf;scatter(oRays(:,2),neuralY(iRays))
figure;clf;scatter(oRays(:,3),neuralZ(iRays))
figure;clf;scatter(oRays(:,4),neuralDX(iRays))
figure;clf;scatter(oRays(:,5),neuralDY(iRays))
figure;clf;scatter(oRays(:,6),neuralDZ(iRays))
    