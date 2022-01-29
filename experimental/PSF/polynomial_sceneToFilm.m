%%
ieInit;

%%
lensName = 'dgauss.22deg.3.0mm.json';
%% Generate ray pairs
maxRadius = 0.6;
minRadius = 0;
offset=0.1;
reverse = false
[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', reverse,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset));


%% Save dataset for google
clear inputs
inputs(:,2) = iRays(:,1);
inputs(:,1) = 0;
inputs(:,3) = -offset;
inputs(:,4) = iRays(:,2); % dx
inputs(:,5) = iRays(:,3); % dy
inputs(:,6) = sqrt(1-iRays(:,2).^2-iRays(:,3).^2);


%% Polynomial fit
polyDeg = 5

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModelSceneToFilm] = lensPolyFit(iRays, oRays,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'plane offset',offset,...
    'lensthickness',lensThickness);


save('polySceneToFilm.mat','polyModelSceneToFilm','planes')