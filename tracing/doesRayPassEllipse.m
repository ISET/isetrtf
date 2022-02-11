function pass = doesRayPassEllipse(rotatedOrigins,rotatedDirections,positions,radii,centers,distanceToRayPassPlane)
% Check that a ray makes it through the lens
%
% INPUTS
%  rotatedOrigins -  Nx3 vector (x,y,z) stating the origin of the
%                    ray on the input plane after applying the rotation
%                    matrix. N is the number of rays to process
%                    simultaneously.
%
%  rotatedDirections - Nx3 direction vectors after applying the rotation
%                      matrix.
%
%  positions - Nx1 vector containing all the input plane positions (distance from the center) at which the
%              ellipses are defined. 
%  radii - Nx2 matrix containing the radii (x,y) of the ellipses defined at
%           each position
%  centers - Nx2 matrix containing the centers (x,y) of the ellipses defined at
%           each position
%  distanceToRayPassPlane - Distance of ray pass plane from input plane.
%                          The ray pass plane is the plane where the ellipses are defined
%
% Syntax:
%   pass =doesRayPassEllipse(ray_origins_oninputplane,ray_directions,positions,radii,centers) 
%
% Author:  Thomas Goossens
  
% Interpolated ellipse parameters
offaxisDistanceOnInputPlane=rotatedOrigins(:,2); % By construction only this value is nonzero
radius=interp1(positions,radii,offaxisDistanceOnInputPlane);
center=interp1(positions,centers,offaxisDistanceOnInputPlane);

% Project to circle plane
alpha = (distanceToRayPassPlane)./(rotatedDirections(:,3));
pointOnRayPassPlane = rotatedOrigins + alpha.*rotatedDirections; 

% All points projected to the raypassplane 
pass = pointInEllipse(radius,center,pointOnRayPassPlane(:,1),pointOnRayPassPlane(:,2));


% Boolean AND operation, ray needs to pass through all
    function pass = pointInEllipse(radius,center,x,y)
               distX = (x-center(:,1));
               distY = (y-center(:,2));
               pass = (distX./radius(:,1)).^2 + (distY./radius(:,2)).^2 <= 1;
    end
end

