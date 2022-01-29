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
   
   % Compare width of ESF
   error(d,i) = errormetric(edgeResampled(ignoreNan)-edgeZemax(ignoreNan));

      end
end


%% Plot RMSE
fig=gcf; hold on
fig.Position=[680 757 184 209]
    
color =[0.833 0 0 ; 1 0.5 0]
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


legh=legend([h(1) h(2)],['' sprintf('%0.1f',distances(1)/1000) '$\,$m'],['' sprintf('%0.1f',distances(2)/1000) '$\,$m'])
legh.Box = 'off' ;
legh.Orientation= 'vertical' ;
legh.Location='northeast'
%legh.Position= [-0.058356474187099 0.912585689373147 1.056511262772188 0.095693777622789];


set(findall(gcf,'-property','FontSize'),'FontSize',10);
set(findall(gcf,'-property','interpreter'),'interpreter','latex');

end

