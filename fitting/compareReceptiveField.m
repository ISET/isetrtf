
clear


%% Double gauss lens
isetlensName= 'dgauss.22deg.50.0mm_aperture6.0.json';
rtfName='dgauss.22deg.50.0mm_aperture6.0';
imageheights = [0 5 10]
filmdistance_mm=36.959;
receptiveFieldDistanceFromFilm_mm=3000;
pixelsize_mm=1.4e-3;
diaphragm_mm=7;
gridpoints=1000

%% Wide angle lens
 %{  
  imageheights = [0 5 8]
  isetlensName= 'wide.56deg.12.5mm.json';
  rtfName='wide.56deg.12.5mm';
  filmdistance_mm=6.5273+0.1;
  receptiveFieldDistanceFromFilm_mm=1552.6;
  diaphragm_mm=1.2946;
  gridpoints=1000
 %}

%% Petzval
%{
imageheights = [0 5 8]
  isetlensName= 'petzval.12deg.50.0mm.json'
  rtfName='petzval.12deg.50.0mm';
  filmdistance_mm=5.94;
  receptiveFieldDistanceFromFilm_mm=2549.5;
  diaphragm_mm=18.7143;
  gridpoints=2000
%}    


%% Calculate RF
for i=1:numel(imageheights)
    imageheight = imageheights(i);
    disp(['Receptive fields for image height of ' num2str(imageheight) ' mm'])
    % isetlens receptivefield

    disp(['- Receptive field for Lens: ' isetlensName])
    [bins,counts,peaks,lens]=receptiveField('isetlens',isetlensName,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight,'diaphragmdiameter',diaphragm_mm,'gridpoints',gridpoints);
    [binspix,countspix,peakspix]=receptiveField('isetlens',isetlensName,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight+0.5*pixelsize_mm,'diaphragmdiameter',diaphragm_mm,'gridpoints',gridpoints);
    binsLens(:,:,i)=bins;    countsLens(:,:,i)=counts;    peaksLens(:,i)=peaks;
    binsLensPix(:,:,i)=binspix;    countsLensPix(:,:,i)=countspix;    peaksLensPix(:,i)=peakspix;
    
    % RTF receptive field
    degrees=[1 2 3 4 5 6 7];
    
    for p=1:numel(degrees)

        filename=[rtfName '-poly' num2str(degrees(p)) '-diaphragm' num2str(diaphragm_mm) 'mm-raytransfer.json'];
        path= fullfile(piRootPath,'data/lens/',filename);
        disp(['- Receptive field for RTF: ' filename])
        
        [bins,counts,peaks]=receptiveField('rtf',filename,filmdistance_mm,receptiveFieldDistanceFromFilm_mm,'imageheight',imageheight,'gridpoints',gridpoints);
        binsRTF(:,:,i,p)=bins;
        countsRTF(:,:,i,p)=counts;
        peaksRTF(:,i,p)=peaks;
    end
end
%% Comparison LSF per position

fig=figure(1);clf
fig.Position= [371 592 869 374];

p=1
for i=1:numel(imageheights)
    for xy=1:2
        
        peakshift=peaksRTF(xy,i,p); % Choose one to shift peaks to be centede around 0
        % Do not use the peak shift for respective lens or rtf because you would
        % remove an actual alignment mismatch
        ind=sub2ind(flip([2 numel(imageheights)]),i,xy)
        subplot(2,numel(imageheights),ind); hold on
        plot(binsLens(:,xy,i)-peakshift,countsLens(:,xy,i),'k')
        
        plot(binsRTF(:,xy,i,p)-peakshift,countsRTF(:,xy,i,p),'r')
        if(xy==1)
            title([num2str(imageheights(i)) ' mm'])
        end
        
        xlabel('Micron')
        
        
    end
end


%% Compare LSF as function of polydegree
color = hot;

fig=figure(2);clf; hold on
fig.Position= [371 462 1085 504]

% Sunselection of position indices
positionIndices=[1 2 numel(imageheights)];
p=1
xy=2
for i=1:numel(positionIndices)
    isel=positionIndices(i);

 
    peakshift=peaksLens(xy,isel); % Choose one to shift peaks to be centede around 0
        % Do not use the peak shift for respective lens or rtf because you would
        % remove an actual alignment mismatch
    data=binsLens(:,xy,isel);
    xlimits = [min(data) max(data)]-peakshift;
    for p=1:numel(degrees)
       
        ind=sub2ind(flip([numel(positionIndices) numel(degrees)]),p,i)
        subplot(numel(positionIndices),numel(degrees),ind); hold on
        
        maxValueLens = max(countsLens(:,xy,isel));

        hlens=plot(binsLens(:,xy,isel)-peakshift,countsLens(:,xy,isel)/maxValueLens,'k-.','linewidth',2)
        %plot(binsLensPix(:,xy,i)-peakshift,countsLensPix(:,xy,i)/maxValueLens,'m--')
        line([1 1]*(peaksLensPix(xy,isel)-peakshift),[0 1],'color','k','linestyle',':')
        line(-[1 1]*(peaksLensPix(xy,isel)-peakshift),[0 1],'color','k','linestyle',':')

        hrtf=plot(binsRTF(:,xy,isel,p)-peakshift,countsRTF(:,xy,isel,p)/maxValueLens,'color',color(round(25*p),:),'linewidth',2)
        if(i==1)
            title({['\textbf{Degree} $\mathbf{' num2str(degrees(p)) '}$'],['$\mathbf{h=' num2str(imageheights(isel)) '}$ \textbf{mm}']})
        else
            title(['$\mathbf{h=' num2str(imageheights(isel)) '}$ \textbf{mm}'])
        end
        
        % Only show units on bottom subfig for less mess
        if(i==3)
            xlabel('Micron')
        end
        xlim(xlimits)
        
        ax=gca;
        ax.Position(3:4)=[0.0844 0.1856]
        
    end
end
legh=legend([hlens hrtf],'Ground truth','RTF')
legh.Box='off'
legh.Orientation='horizontal'
legh.Position=[0.4222 0.9625 0.1725 0.0333]
% Formatting
set(findall(gcf,'-property','FontSize'),'FontSize',8);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');


exportgraphics(gcf,'/scratch/thomas42/rtfpaper/dgauss-polyreceptivefield.pdf')