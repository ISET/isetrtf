
clear



%% Double gauss lens
rtfName='dgauss28deg-zemax'

imageheights = [0 1.5 2.6];
imageheights = [0 10 15 ]


filmdistance_mm=80; receptiveFieldDistanceFromFilm_mm=615.67388;

filmdistance_mm=80; receptiveFieldDistanceFromFilm_mm=629.03559;

pixelsize_mm=1.4e-3;
gridpoints=100
gridsize_mm=30
histogrambins=50
degrees=[1 2 3 4 5 6 7]



%% Calculate RF
for i=1:numel(imageheights)
    imageheight = imageheights(i);
    disp(['Receptive fields for image height of ' num2str(imageheight) ' mm'])
    % isetlens receptivefield

    
    % RTF receptive field
    
    
    for p=1:numel(degrees)

        filename=[rtfName '-poly' num2str(degrees(p)) '-raytransfer.json'];

        disp(['- Receptive field for RTF: ' filename])
        
        [bins,counts,peaks]=receptiveField('rtf',filename,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight,'gridpoints',gridpoints,'gridsize_mm',gridsize_mm,'histogrambins',histogrambins);
        binsRTF(:,:,i,p)=bins;        countsRTF(:,:,i,p)=counts;        peaksRTF(:,i,p)=peaks;

        [bins,counts,peaks]=receptiveField('rtf',filename,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight+pixelsize_mm/2,'gridpoints',gridpoints,'gridsize_mm',gridsize_mm,'histogrambins',histogrambins);
        binsRTFPix(:,:,i,p)=bins;        countsRTFPix(:,:,i,p)=counts;        peaksRTFPix(:,i,p)=peaks;
    end
end


%% Compare LSF as function of polydegree
load('./zemax-lsf.mat','lsf')
load('./zemax-lsf-conjugate.mat','lsf')

color = hot;

fig=figure(2);clf; hold on
fig.Position= [371 462 1085 504]

% Sunselection of position indices
positionIndices=[1:numel(imageheights)];
p=1
xy=1
clear cross
for i=1:numel(positionIndices)
    isel=positionIndices(i);

 
    peakshift=peaksRTF(xy,isel,p); % Choose one to shift peaks to be centede around 0
        % Do not use the peak shift for respective lens or rtf because you would
        % remove an actual alignment mismatch
    data=binsRTF(:,xy,isel,p);
    xlimits = [min(data) max(data)]-peakshift;
    for p=1:numel(degrees)
       
        ind=sub2ind(flip([numel(positionIndices) numel(degrees)]),p,i)
        subplot(numel(positionIndices),numel(degrees),ind); hold on
        
        maxValueLens = max(countsRTF(:,xy,isel,p));

        lsfi=lsf{i};
        xzemax=lsfi(:,1); yzemax=lsfi(:,2+(2-xy));
        xrtf=binsRTF(:,xy,isel,p)-peakshift;
        yrtf=countsRTF(:,xy,isel,p)/maxValueLens;
        yrtf_resampled=interp1(xrtf,yrtf,xzemax);
        yrtf_resampled(isnan(yrtf_resampled)) = 0;
                
        hrtf=plot(xzemax,yrtf_resampled,'color',color(round(25*p),:),'linewidth',2)
        
        %hrtfpix=plot(binsRTFPix(:,xy,isel,p)-peakshift,countsRTFPix(:,xy,isel,p)/maxValueLens,'color','m','linewidth',2)        

        hzemax=plot(xzemax,yzemax,'k:','linewidth',1.5)                
        
        
        [crosstemp,lags]=crosscorr(yzemax,yrtf_resampled);
        ind_max = find(crosstemp==max(crosstemp));
        deltax = abs(xzemax(2)-xzemax(1));
        cross(p,i,[1 2])=[crosstemp(ind_max) lags(ind_max)*deltax];
        
        
        % pixelsize ( use xy=2) dimension to calculate estimate
        %line([1 1]*(peaksRTFPix(2,isel)-peaksRTF(2,isel)),[0 1],'color','k','linestyle',':')
        %line(-[1 1]*(peaksRTFPix(2,isel)-peaksRTF(2,isel)),[0 1],'color','k','linestyle',':')

        if(i==1)
            title({['\textbf{Degree} $\mathbf{' num2str(degrees(p)) '}$'],['$\mathbf{h=' num2str(imageheights(isel)) '}$ \textbf{mm}']})
        else
            title(['$\mathbf{h=' num2str(imageheights(isel)) '}$ \textbf{mm}'])
        end
        
        % Only show units on bottom subfig for less mess
        if(i==3)
            xlabel('Micron')
        end
        if(~isnan(xlimits))
            %xlim(xlimits)
        end
        
        ax=gca;
        ax.Position(3:4)=[0.0844 0.1856]
        
    end
end
legh=legend([hzemax(1) hrtf(1) ],'ZEMAX Ground Truth','RTF')
legh.Box='off'
legh.Orientation='horizontal'
legh.Position=[0.4222 0.9625 0.1725 0.0333]
% Formatting
set(findall(gcf,'-property','FontSize'),'FontSize',8);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');


exportgraphics(gcf,'./fig/dgauss28-receptivefield.pdf')


%% Crosscorrelation metric
figure; 
subplot(211)
plot(degrees,cross(:,:,1));
title('Peak Correlation')
subplot(212)
plot(degrees,cross(:,:,2))
title('Shift')
ylabel('Micron')
