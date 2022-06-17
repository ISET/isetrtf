function [rayArrivalPositions,rayArrivalDirections]= traceRTFFilmToScene(rtf,sensordistance_mm,origins,directions,objectPlaneDistanceFromRear_mm)
% Trace a collection of rays through the ray transfer function (all
% distances in mm)
%
% Syntax
%   [rayArrivalPosition,rayArrivalDirection] = traceRTFFilmToScene(rtf,filmdistance,origins,directions,objectPlaneDistanceFromRear)
%
%  We trace from left (sensor) to the right (scene):  
%  z=0 is defined as the vertex on the rear (scene) side.
% The positive z axis is pointing towards the scene.
% All distances are in mm.
%
% Inputs
%  
%  rtf  -  A struct of the ray transfer function. 
%           
%  origins  - Ray origins, a location for each ray  (n x 3)
%             z must be negative and larger than the lens thickness so it
%             passes through the lens
%        
%  directions  -     Ray directions a unit vector for each ray
%                    (n x 3).  The z value should be positive, pointing
%                    towards the film 
%
%  sensordistance_mm - Distance from sensor (z=0) to the first vertex
%  (sensor side) of the lens.
%  
%  objectPlaneDistanceFromRear_mm -  The distance of the object plane
%  measured from the first vertex (object side) of the lens. 
%
% Author: Thomas Goossens
%
% See also
%

% Examples:
%{
 rtf=jsonread('dgauss28deg-zemax-poly5-raytransfer.json')
 filmdistance_mm = 67.768;
 origins = [0 0 0];
 directions = [0 0 1];
 [rayArrivalPosition,rayArrivalDirection]= traceRTFFilmToScene(rtf,filmdistance,origins,directions,objectPlaneDistanceFromRear)
%}

% z=0 at the sensor
% Trace origin to the input plane of the RTF lens (linear extrapolation)
inputplane_z = sensordistance_mm-rtf.planeoffsetinput;

alpha = inputplane_z./directions(:,3);
intersectionsOnInputPlane = origins + alpha.*directions;

% Rotate rays
[rotatedOrigins,rotatedDirections]=rotateRays(intersectionsOnInputPlane,directions);



% Account for vignetting: Rays should pass all vignetting circles
% Vectorized calculation for speed.
passnopass=rtf.polynomials.raypass;
% Determine which rays pass and which dont
if(isequal(passnopass.method,'minimalellipse'))
    centers=[passnopass.centersX passnopass.centersY];
    radii=[passnopass.radiiX passnopass.radiiY];
    pass = doesRayPassEllipse(rotatedOrigins,rotatedDirections,passnopass.positions,radii,centers,passnopass.intersectPlaneDistance);
else
    % Make backwards compatible 
        pass = (doesRayPassCircles(intersectionsOnInputPlane,directions,rtf.circleRadii,rtf.circleSensitivities,rtf.circlePlaneZ));
end


%% Convert polynomials to readable format by polyvaln
polyvalnStruct={};
polynomials=rtf.polynomials.poly;
for i=1:numel(polynomials)
        poly=polynomials(i);
        temp = struct;
        temp.Coefficients = poly.coeff';
        temp.ModelTerms = [poly.termr'; poly.termdx'; poly.termdy']';
        polyvalnStruct{i}=temp;
end

% Initializations
% Initialize as NaNs, the remaining NaNs in the end will correspond to
% vignetted rays (not traced)
rayArrivalPositions = nan(size(origins));
rayArrivalDirections = zeros(size(origins,1),3);


% Evaluate RTF for all rays 
% Parfor increases speed
parfor r=1:size(origins,1)

   % If the ray is vignetted, skip to the next candidate tray. This avoids
   % costly evaluation of the polynomial.
    if(~pass(r))
        continue; % vignetted
    end
    
    % arrivalPos is the position on the rtf output plane
    % arrivalDir is the direction it leaves the Pos
    [arrivalPosOnOutputPlaneMeasuredFromRear,arrivalDirection,arrivalPosOnOutSurface] = rtfTrace(intersectionsOnInputPlane(r,:),directions(r,:),polyvalnStruct);
    %arrivalPosOnOutputPlane(3)=rtf.planeoffsetoutput;
    
    % The following is a conversion of conventions between PBRT/ZEMAX and
    % isetlens.
    % In PBRT and ( as chosen by me in zemax), Z position is measured from the inputsurface, we subtract rtf thicknes and planeoffsetinput to get the 
    % Distance as measured rom the rear vertex ( isetlens convention)
 
    % arrivalPosOnOutputPlaneMeasuredFromRear(3)=arrivalPosOnOutSurface(3)-(rtf.thickness+rtf.planeoffsetinput);
    arrivalPosOnOutputPlaneMeasuredFromRear(3)=arrivalPosOnOutSurface(3);
    
    
    % For output surface
    alpha = abs(objectPlaneDistanceFromRear_mm - arrivalPosOnOutputPlaneMeasuredFromRear(3)) ./ arrivalDirection(3);  % Distance to film
    rayArrivalPositions(r,:) = [0 0 sensordistance_mm+rtf.thickness]+arrivalPosOnOutputPlaneMeasuredFromRear + alpha*arrivalDirection;             % 
    rayArrivalDirections(r,:) = arrivalDirection;
    
end

end

