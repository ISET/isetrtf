function fig = plotESF(degrees,pixels,distances,esfPBRT,esfZemax)
%PLOTESF Plot and compare the ESF with ZEMAX
% The current implementation just shows the RTF result for the highest
% polynomial degree. 

fig=gcf; hold on
fig.Position=[680 757 184 209]

for i=1:2 % Loop only over the first two given distances
   for d=numel(degrees) % only used last degree

   % ESF zemax
   esf=esfZemax{i};   pixelsZemax = esf(:,1);   edgeZemax=flip(esf(:,3));
   

   %Resample rtf ESF to same grid as zemax
   edgeResampled=interp1(pixels,esfPBRT(:,d,i),pixelsZemax);
   N=20;   smooth = @(x)conv(x,ones(1,N)/N,'same' )
   % To normalize the saturation value, given the possible presence of rendering noise,
   % we divide by the maxmimum of a smoothed ESF.
   edgeResampled = edgeResampled/max(smooth(edgeResampled));
   
   
   % Plot the ESF in different colors
   color =[0.8333 0 0 ; 1 0.5 0]
   hrtf(i)=plot(pixelsZemax,edgeResampled,'color',color(i,:),'linewidth',2)
      
   
   % Plot ESF ZEMAX
   hzemax=plot(pixelsZemax,edgeZemax,'k-.','linewidth',2)
   
      end
end


%% Figure Formatting
box on
roundedDistanceMeter= round(distances(2)/1000,1);
if(roundedDistanceMeter ==0)
    legh=legend([hrtf(1) hrtf(2) hzemax],['' sprintf('%0.1f',distances(1)/1000) '$\,$m'],['' sprintf('%0.1f',distances(2)/100) '$\,$cm'],'Zemax')
else
legh=legend([hrtf(1) hrtf(2) hzemax],['' sprintf('%0.1f',distances(1)/1000) '$\,$m'],['' sprintf('%0.1f',distances(2)/1000) '$\,$m'],'Zemax')
end
legh.Box = 'on' ;
legh.Location='northeast'
legh.Color='w'
legh.EdgeColor=legh.Color;
%legh.Orientation= 'horizontal' ;
legh.Position= [0.5559 0.7332 0.4422 0.1746]

xlabel('Distance ($\mu$m)')

set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

end

