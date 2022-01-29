
clear
close all


%% Double gauss lens
rtfName='wideangle200deg-circle-zemax'

imageheights = [0]



filmdistance_mm=2.13; 
receptiveFieldDistanceFromFilm_mm=18.19357

gridpoints=2000
gridsize_mm=4
histogrambins=50
degrees=[13]


pixelsizes = [0 1.4 2 5 10 15 20 30 50]*1e-3; %% mm
pixelsizes = [0 1.4 5 10 15 20 30]*1e-3; %% mm


%% Calculate RF
for i=1:numel(pixelsizes)
    pixelsize_mm=pixelsizes(i);
    imageheight = imageheights(1);
    disp(['Receptive fields for pixel size of ' num2str(pixelsize_mm) ' mm'])
    % isetlens receptivefield

    
    % RTF receptive field

      filename=[rtfName '-poly' num2str(degrees) '-raytransfer.json'];

      disp(['- Receptive field for RTF: ' filename])
        
      

      %  Integrate of pixels,: aggregate all positions
      allPositions = zeros(0,3);
      x = linspace(0,pixelsize_mm,20);
      
      for ix=1:numel(x)
          [~,~,~,~,positions]=receptiveField('rtf',filename,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight+x(ix),'gridpoints',gridpoints,'gridsize_mm',gridsize_mm,'histogrambins',histogrambins);
            allPositions = [allPositions; positions]; % Aggreagete
      end
      
      
% Calculate Linespread functions
% positionsOnFilm contains the coordinates of the points on the image
% plane. By making a histogram for only the X values, one effectively has
% aggregated over Y direction (summed all bins in Y direction).

maxnorm = @(x)x/max(x);
mmToMicron=1e3;
for xy=1:2
    
    [countsTemp,binsTemp]=hist(mmToMicron*allPositions(:,xy),histogrambins);
    binsRTF(:,xy,i)=binsTemp;
    countsRTF(:,xy,i)=countsTemp;
    peaksRTF(xy,i)=sum(binsTemp.*countsTemp)./sum(countsTemp);
end
end




        
%% Compare LSF as function of polydegree
color = hot;

fig=figure(2);clf; hold on
fig.Position= [715 462 741 207];

% Sunselection of position indices
positionIndices=[1:numel(imageheights)];
p=1
xy=2
clear cross
for i=1:numel(pixelsizes)
    isel=i;

 
    peakshift=peaksRTF(xy,i); % Choose one to shift peaks to be centede around 0
        % Do not use the peak shift for respective lens or rtf because you would
        % remove an actual alignment mismatch
    data=binsRTF(:,xy,1);
    xlimits = [min(data) max(data)]-peakshift;
    for p=1:numel(degrees)
       
                
        maxValueLens = max(countsRTF(:,xy,isel));
        
        
        % Sample on same grid
        xgrid = linspace(-300,300,1000);
        
        xrtf=binsRTF(:,xy,isel)-peakshift;        yrtf=countsRTF(:,xy,isel)/maxValueLens;
        yrtfNew = interp1(xrtf,countsRTF(:,xy,isel)/maxValueLens,xgrid);
        yrtfNew(isnan(yrtfNew))=0;% Replace nan by zero  
        if(i==1)
            FW=max(xrtf)-min(xrtf); % original widh before zero padding
        end
              
        colindex=round(0.7*i*size(color,1)/numel(pixelsizes));
        hrtfpix=plot(xgrid,yrtfNew,'color',color(colindex,:),'linewidth',2)        
        


% Calculate cross corre
        [xcf,lags]=xcorr(yrtfNew,yrtfNew);
      
        
        ind_max = find(xcf==max(xcf));
        deltax = abs(xgrid(2)-xgrid(1));
        cross(p,i,[1])=lags(ind_max)*deltax;
        
        
        
    end
end




% Load ZEMAX LSF


load('./zemax-lsf.mat','lsf')

% Plot zemax

lsfi=lsf{1};
xzemax=lsfi(:,1); yzemax=lsfi(:,2+(2-xy));
hrtf=plot(xzemax,yzemax,'color',color(round(25*p),:),'color','b','linewidth',2,'linestyle','--')


legh=legend(sprintfc('%.1f micron',round(pixelsizes*1e3,2)))
legh.Box='off'
pos=[221 0.98];
text(pos(1),pos(2),'Pixel Size')


%Xlimits
xlim([-300 300])
% Formatting
set(findall(gcf,'-property','FontSize'),'FontSize',8);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');


%%  Plot pixel size sweep
 figure; hold on
 plot(1e3*pixelsizes,squeeze(cross))
 line(1e3*pixelsizes([1 end]),FW/2*[1 1],'color','k','linestyle','--')
 xlabel("Pixel Size (Micron)")
 ylabel("Shift (Micron)")

exportgraphics(gcf,'./fig/pixelsize.pdf')



