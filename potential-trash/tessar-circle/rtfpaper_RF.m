
clear

load('zemax-lsf.mat','lsf')

%% Double gauss lens
rtfName='tessar-circle-zemax'


imageheights = [0 5 8 10 ]
imageheights = [0]


filmdistance_mm=100; receptiveFieldDistanceFromFilm_mm=1366.4+100

pixelsize_mm=1.4e-3;
gridpoints=300
gridsize_mm=20
histogrambins=50
degrees=[6 7 8 10]



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
color = hot;

fig=figure(2);clf; hold on
fig.Position= [371 462 1085 504]

% Sunselection of position indices
positionIndices=[1:numel(imageheights)];
p=1
xy=2
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

        

        hrtf=plot(binsRTF(:,xy,isel,p)-peakshift,countsRTF(:,xy,isel,p)/maxValueLens,'color',color(round(25*p),:),'linewidth',1)
        %hrtfpix=plot(binsRTFPix(:,xy,isel,p)-peakshift,countsRTFPix(:,xy,isel,p)/maxValueLens,'color','m','linewidth',2)        
        lsfi=lsf{i};
        hzemax=plot(lsfi(:,1),lsfi(:,2+(2-xy)),'k:','linewidth',1.5)        

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
      %  ax.Position(3:4)=[0.0844 0.1856]
        
    end
end
legh=legend([hrtf],'RTF')
legh.Box='off'
legh.Orientation='horizontal'
legh.Position=[0.4222 0.9625 0.1725 0.0333]
% Formatting
set(findall(gcf,'-property','FontSize'),'FontSize',8);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');


%exportgraphics(gcf,'./fig/pixel4arear-receptivefield.pdf')