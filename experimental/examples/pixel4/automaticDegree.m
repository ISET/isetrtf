clear; close all;



lensName='pixel4a-rearcamera'

filmdistance_mm=0.464135918
offset_sensorside=filmdistance_mm;
offset_objectside=1.48002192; %%mm

lensThickness=4.827;

frontvertex_z=-lensThickness;
planes.input=frontvertex_z-offset_sensorside;
planes.output=offset_objectside;



%% Dataset for fitting
X=dlmread('Gout-P4Ra_20111103.txt','\s',1);

Xnonan=X(~isnan(X(:,1)),:);

iRays2=Xnonan(:,[3 5 6]);
oRays2=Xnonan(:,[8 9 10 11 12 13]);


%% Dataset for crossvalidation
X=dlmread('/usr/local/scratch/thomas42/MATLAB/libs/isetlens/local/Gout-P4Rb183050_20211115.txt','\s',1);

Xnonan=X(~isnan(X(:,1)),:);

iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);




%% Fit polynomials
degrees = [1 2 3 4 5 6 7 8];

for i =1:numel(degrees)
    polyModel{i}= lensPolyFit(iRays, oRays,...
        'visualize', false,...
        'maxdegree', degrees(i),...
        'sparsitytolerance',0);
    
    poly = polyModel{i};
    nonanVals = ~isnan(oRays2(:,1));
    removeNans = @(x) x(nonanVals,:);
    for p=1:numel(poly)
        estimate(:,p)=polyvaln(poly{p},iRays2);
       relerror(i,p)=norm(removeNans(oRays2(:,p)-estimate(:,p)))/norm(removeNans(oRays2(:,p)))
       allrelerr(:,i,p)=abs((oRays2(:,p)-estimate(:,p)))./abs((oRays2(:,p)));
    end
    
end

%% Plot errors

nbDecimalPlaces = 6-1;

labels ={'x','y','z','dx','dy','dz'};
figure;
subplot(211); hold on
semilogy(degrees,relerror,'.-','markersize',10)
line([1 numel(degrees)],10^(-nbDecimalPlaces)*[1 1],'color','k','linestyle','--')
ylim([1e-7 1])
set(gca,'YScale','log')
legend(labels)
xlabel('Polynomialdegree')
title('Relative Error')
subplot(212)
title('Median Error')
%semilogy(degrees,medianerror,'.-','markersize',10)
all = permute(allrelerr,[1 3 2]);

group =kron(1:numel(degrees),[ 1 1 1 1 1 1]);
boxplot(all(:,:),group,'symbol','+')
line([1 numel(degrees)],10^(-nbDecimalPlaces)*[1 1],'color','k','linestyle','--')
set(gca,'YScale','log')
ylim([1e-7 10])


%% Plot all input rays rays that give large errors
%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
intersectionPlaneDistance=2.5893;
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(iRays,-lensThickness-offset_sensorside,'circleplanedistance',intersectionPlaneDistance);

[radii,centers] = vignettingFitEllipses(pupilShapes);

%% Subselection of large errors
clear planeIntersections

degree=7;
outputvars=4
largeErrors=any(squeeze(allrelerr(:,degree,outputvars))<1e-3,2);
percentage=sum(largeErrors)/size(iRays2,1)*100
iRays2LargeErr = iRays2(largeErrors,:);

directions = [iRays2LargeErr(:,2:3) sqrt(1-sum(iRays2LargeErr(:,2:3).^2,2))];
origins=[zeros(size(iRays2LargeErr,1),1) iRays2LargeErr(:,1) zeros(size(iRays2LargeErr,1),1)];

alpha = intersectionPlaneDistance./directions(:,3);
    
planeIntersections(:,1:3) = origins+alpha.*directions;

%%

figure(4);clf
hold on;
% Determine all unique positions 
positionsErr=unique(iRays(:,1));
 nbPos = numel(positionsErr);
% Draw a   subset of rays for visual effect
for p=1:size(positionsErr)
    subplot(round(sqrt(nbPos)),ceil(sqrt(nbPos)),p); hold on

    % Plot ray intersections
    indices=iRays2LargeErr(:,1)==positions(p);
     data=planeIntersections(indices,:);
     scatter(data(:,1),data(:,2),'.');
     
    % Plot ellipse on top
    radiiInterp = interp1(positions,radii',positionsErr(p));
    centerInterp = interp1(positions,centers',positionsErr(p));
    h = drawellipse('Center',centerInterp,'SemiAxes',radiiInterp,'color','r');
end 


%% Compare relative sizes of the output variables
figure;
labels={'x' 'y' 'z' 'dx' 'dy' 'dz'};

h=boxplot(oRays2,'Labels',labels)
set(gca,'YScale','log')
ylabel('')
