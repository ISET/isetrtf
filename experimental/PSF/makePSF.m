clear; close all
load polySceneToFilm.mat
     pupilpos=[1.126633618747183,17.62632197414806,0.1798334742028881];
        pupilradii=[0.476941565269641,7.931844888366627,0.5994449140096272] ;  
        
        lensName = 'dgauss.22deg.3.0mm.json';
        lens=lensC('file',lensName);
        addOutputSurface=outputPlane(0.1)
        lens=addOutputSurface(lens)
        lens.draw
polyModelSceneToFilm = polyModelSceneToFilm(1:5)




%% Generate ray from point source
% Direction of the ray in spherical coordinates
positionPointSource=[0 0 -4];
thetas=linspace(0,20,200);
phis=linspace(0,359,100);


counter=0
for t=1:numel(thetas)
    for p=1:numel(phis)
        theta=thetas(t); %polar angle (>0)
        phi=phis(p); % azimuth
        
        
        
        direction = [sind(theta).*cosd(phi)  sind(theta)*sind(phi)  cosd(theta)];
        
        
        
        
        %% propagate from point source to input plane
        alpha = (planes.input-positionPointSource(3))/direction(3);
        origin=positionPointSource+alpha*direction;
        
        %% Propagate through RTF
        [outPos,outDir]=rtfTrace(origin,direction,polyModelSceneToFilm);
        outPos(3)=planes.output;
        outDir(3)=sqrt(1-outDir(1)^2-outDir(2)^2);
        
        %% Check vignetting
   
         pass=checkRayPassLens(outPos,outDir,pupilpos,pupilradii);
         if (not(pass))
             counter=counter+1;
             continue;
         end
         
%        %% Propagate through real lens for comparison
%        waveIndices=1;
%        rays = rayC('origin',origin,'direction', direction, 'waveIndex', waveIndices, 'wave', lens.wave);
%        [~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);
%         
%        
%        err=norm(pOut-outPos')/norm(pOut)
        %% Propagate from Output plane to plane of point source
        filmDistance = 2.167; % Distance from last vertex
        lastVertexZ = 0 ; %% By convention in lens file
        deltaDistance = filmDistance-(lastVertexZ+planes.output);
        
        % Linear interpolation
        alpha = deltaDistance/outDir(3);
        
        finalPos(:,t,p) = outPos + outDir*alpha;
    end
end


%% Visualize

X=finalPos(1,:)';
X(~(imag(X)==0))=[];
Y=finalPos(2,:)';
Y(~(imag(Y)==0))=[];
figure;

% Take uneven number of bins to allow peak to be in center [0 x 0]
hist3([X Y],'nBins',[51 51],'CDataMode','auto','FaceColor','interp');
hchild=get(gca,'children');
set(hchild,'edgecolor','none')
colorbar
view(2)
