function fig = plotESF(degrees,pixels,distances,esfPBRT,esfZemax,addzemaxtolegend)
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
   %edgeResampled = edgeResampled/max((edgeResampled));
   
   
   % Plot the ESF in different colors
   colorpassblue = [0 49 90]/100;    
   color =[0.833 0 0 ; colorpassblue]
   hrtf(i)=plot(pixelsZemax,edgeResampled,'color',color(i,:),'linewidth',2)
      
   
   % Plot ESF ZEMAX
   hzemax=plot(pixelsZemax,edgeZemax,'k-.','linewidth',2)
   
      end
end


%% Figure Formatting
box on
roundedDistanceMeter= round(distances(2)/1000,1);
if(roundedDistanceMeter ==0)
   textLeg={['' sprintf('%0.1f',distances(1)/1000) ' m'],['' sprintf('%0.1f',distances(2)/10) ' cm'],'Zemax'};
else
    textLeg={['' sprintf('%0.1f',distances(1)/1000) ' m'],['' sprintf('%0.1f',distances(2)/1000) ' m'],'Zemax'};
end

if(addzemaxtolegend)
    [legh,icons]=legend([hrtf(1) hrtf(2) hzemax],textLeg);
else
    [legh,icons]=legend([hrtf(1) hrtf(2)],textLeg{1:2});
end
% Legend formatting
legh.Box = 'on' ;
%legh.Color='w'
legh.EdgeColor='none';
set(legh,'color','none');
%legh.Orientation= 'horizontal' ;
legh.Position= [0.4559 0.7 0.4422 0.1746]

 textobj = findobj(icons, 'type', 'text');
 for t=1:numel(textobj)
  set(textobj(t), 'Interpreter', 'latex');
  set(textobj(t), 'Fontsize', 10);
 end

 %Adjust sizes of line segments in legend
lineobj = findobj(icons, 'type', 'line');
for t=1:numel(lineobj)
 lineXData = get(lineobj(t), 'XData');
 lineXData(1:2) = [0.3 0.453];  % Change this line to give you the x coordinates you want
  set(lineobj(t), 'XData', lineXData);
% end

xlabel('Distance ($\mu$m)')

set(findall(gcf,'-property','FontSize'),'FontSize',10);
legh.FontSize=9
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

end

