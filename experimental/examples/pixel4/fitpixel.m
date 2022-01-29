clear; close all;

polyDeg = 8

load iodata_16sept.mat;

iRays=in(:,[2 4 5]);
oRays=out;





for j=1:size(out,2)
    polyModel{j} = polyfitn(iRays, oRays(:,j),polyDeg);
    error(j) = polyModel{j}.RMSE
end
    

%%  Visualize polynomial fit
labels = {'x','y','z','d_x','d_y','d_z'};
%     fig=figure(6);clf;
%     fig.Position=[231 386 1419 311];
pred = zeros(size(iRays, 1), 6);
ieNewGraphWin;

for i=1:size(oRays,2)
    pred(:,i)= polyvaln(polyModel{i},iRays(:,:));
    out = oRays(:,i);
    subplot(2,3,i); hold on;
    h = scatter(pred(:,i),out,'Marker','.','MarkerEdgeColor','r');
    plot(max(abs(out))*[-1 1],max(abs(out))*[-1 1],'k','linewidth',1)
    
    title([labels{i} ' - RMSE: ' num2str(error(i))])
    xlim([min(out) max(out)+0.0001])
    xlabel('Polynomial')
    ylabel('Ray trace')
end
