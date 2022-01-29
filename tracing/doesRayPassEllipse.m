function pass = doesRayPassEllipse(rotatedOrigins,rotatedDirections,positions,radii,centers,intersectionplaneZ)
% Check that a ray makes it through the lens
%
% INPUTS
%  ray_origins_oninputplane -  Nx3 vector (x,y,z) stating the origin of the
%    ray on the input plane. 
% Syntax:
%   pass =doesRayPassEllipse(ray_origins_oninputplane,ray_directions,positions,radii,centers) 
%
% Author:  Thomas Goossens
  
% Interpolated ellipse parameters
offaxisDistanceOnInputPlane=rotatedOrigins(:,2); % By construction only this value is nonzero
radius=interp1(positions,radii,offaxisDistanceOnInputPlane);
center=interp1(positions,centers,offaxisDistanceOnInputPlane);


% Project to circle plane
alpha = (intersectionplaneZ)./(rotatedDirections(:,3));
pointOnIntersectPlane = rotatedOrigins + alpha.*rotatedDirections; 

% All points projected to the intersectionplane 

pass = pointInEllipse(radius,center,pointOnIntersectPlane(:,1),pointOnIntersectPlane(:,2));


% Boolean AND operation, ray needs to pass through all

    function pass = pointInEllipse(radius,center,x,y)
               distX = (x-center(:,1));
               distY = (y-center(:,2));
               pass = (distX./radius(:,1)).^2 + (distY./radius(:,2)).^2 <= 1;
    end
end

