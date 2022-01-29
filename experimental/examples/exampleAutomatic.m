  
%% Generate vignetting functions
  % Prepare positions in struct to interface to vignettingFitEllipses
  for p=1:numel(positions)
      pointsPerPosition{p}=squeeze(pupilshape_trace([1 2],p,:));
  end
  
  [radii,centers,rotations]=vignettingFitEllipses(pointsPerPosition);
  

  