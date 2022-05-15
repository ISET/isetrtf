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
   ignoreZero= ~(edgeZemax==0);
   ignoreOne = ~(edgeZemax==1);
   ignore = and(ignoreOne,and(ignoreZero,ignoreNan));

   % To normalize the saturation value, given the possible presence of rendering noise,
   % we divide by the maxmimum of a smoothed ESF.
   N=10;
   %Flip and sort to make sur we will use the N largest values for normalization.
   % Because the ESF can become exactly zero, this avoids accidental
   % divisions by zero
   edgeIgnoreNan=flip(sort(edgeResampled(ignoreNan))); 
   
   edgeResampled = edgeResampled/mean(edgeIgnoreNan(1:N)); % Smooth out some of the rendering noise to make the edge converge to one
      
   % Compare width of ESF
   error(d,i) = errormetric(edgeResampled(ignore)-edgeZemax(ignore));

      end
end


%% Plot RMSE
fig=gcf; hold on
fig.Position=[680 757 184 209]
    
colorpassblue = [0 49 90]/100;    
color =[0.833 0 0 ; colorpassblue]
for p=1:numel(distances)
    h(p)=plot(degrees,error(:,p),'linewidth',2,'color',color(p,:))
   
    %line([degrees(1) degrees(end)],[renderNoiseFloor renderNoiseFloor],'color','k','linewidth',2,'linestyle','--')
   
end
xlabel('Polynomial Degree')
ylabel('RMSE')
%xticks(degrees([1:3:end-1 end]))
xticks([1 6 11 16])
% Figure styles
box on

text(10,0.25,[num2str(round(min(error(:))*100,2)) '%'])
line([13 16],[0.2 min(error(end,:))],'color','k')


%set(findall(gcf,'-property','FontSize'),'FontSize',10);
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

