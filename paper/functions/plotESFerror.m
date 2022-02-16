function fig = plotESFerror(degrees,pixels,distances,esfPBRT,renderNoiseFloor,esfZemax)
%  Plot the RMSE of the ESF compared to zemax as a function of
%degree

   
   errormetric = @(x)rms(x);

   
%% Calculate RMSE
for i=1:numel(distances)
      for d=1:numel(degrees)

   % ESF zemax
   esf=esfZemax{i};   pixelsZemax = esf(:,1);   edgeZemax=flip(esf(:,3));

   %Resample rtf ESF to same grid as zemax
   edgeResampled=interp1(pixels,esfPBRT(:,d,i),pixelsZemax);
   ignoreNan = ~isnan(edgeResampled);
   

   % To normalize the saturation value, given the possible presence of rendering noise,
   % we divide by the maxmimum of a smoothed ESF.
   N=20;
   smooth = @(x)conv(x,ones(1,N)/N,'same' )
   edgeResampled = edgeResampled/max(smooth(edgeResampled));
   %edgeResampled = edgeResampled/max((edgeResampled));
   
   % Compare width of ESF
   error(d,i) = errormetric(edgeResampled(ignoreNan)-edgeZemax(ignoreNan));

      end
end


%% Plot RMSE
fig=gcf; hold on
fig.Position=[680 757 184 209]
    
colorpassblue = [0 49 90]/100;    
color =[0.833 0 0 ; colorpassblue]
for p=1:numel(distances)
    h(p)=plot(degrees,error(:,p),'linewidth',2,'color',color(p,:))
    line([degrees(1) degrees(end)],[renderNoiseFloor renderNoiseFloor],'color','k','linewidth',2,'linestyle','--')
   
end
xlabel('Polynomial Degree')
ylabel('RMSE')
if(numel(degrees)<=8)
    xticks(degrees)
else
     xticks(degrees(1:2:end))
end
% Figure styles
box on



set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');
roundedDistanceMeter= round(distances(2)/1000,1);
if(roundedDistanceMeter ==0)
   textLeg={['' sprintf('%0.1f',distances(1)/1000) ' m'],['' sprintf('%0.1f',distances(2)/10) ' cm'],'Zemax'};
else
    textLeg={['' sprintf('%0.1f',distances(1)/1000) ' m'],['' sprintf('%0.1f',distances(2)/1000) ' m'],'Zemax'};
end



[legh,icons]=legend([h(1) h(2)],textLeg)
legh.Box = 'off' ;
legh.Orientation= 'vertical' ;
legh.Location='northeast'
%legh.EdgeColor='w';
%legh.Position= [-0.058356474187099 0.912585689373147 1.056511262772188 0.095693777622789];

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
end

 



end

