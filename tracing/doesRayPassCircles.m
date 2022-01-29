function pass = doesRayPassCircles(ray_origins_oninputplane,ray_directions,circleRadii,circleSensitivities,circlePlaneZ)
% Check that a ray makes it through the lens
%
% Syntax:
%   pass = doesRayPassCircles(ray_origin,ray_direction, pupil_positions,pupil_radius)
%
% INPUTS
%  ray_origins_oninputplane -  Nx3 vector (x,y,z) stating the origin of the
%    ray on the input plane. 
%  ray_directions:  Nx3 3D direction vectors (x,y,z) 
%  circleRadii:     1xP array of radii of pupils (paired with
%                   pupil_positions projected onto circlePlaneZ) would
%                   have a distance 0  
%  circleSensitivities:
%  circlePlaneZ:    The projection plane, measured from the position
%                   of the input plane (origins_oninputplane(3)).
%
% OUTPUTS
%  pass  - true/false whether ray passes through lens system
%
% Description:
%  
%
% Author:  TG
%
% SEE ALSO
%   rtfTraceObjectToFilm
%

% Project to circle plane
alpha = (circlePlaneZ)./(ray_directions(:,3));
pointOnCirclePlane = ray_origins_oninputplane + alpha.*ray_directions; 


% The off-axis distance (in the direction 'offaxis_unitdirection')
rho = sqrt(sum(ray_origins_oninputplane(:,1:2).^2,2));

% Circles move along the same direction as the off-axis direction. So we
% need to calculate the unit vector pointing in this direction
if ~isequal(rho,0)
    offaxis_unitdirection = ray_origins_oninputplane(:,1:2)./rho; % Unit vector
else
    % Avoid division by zero.  If rho is zero the value is irrelevant.
    % (see below)
    offaxis_unitdirection = 0;
end
    

% All points projected to the circle plane must be within the radius
% of each circle 
passpupil = zeros(size(ray_directions,1),numel(circleSensitivities));
for i=1:numel(circleSensitivities)
    passpupil(:,i)= sum( (pointOnCirclePlane(:,1:2)- circleSensitivities(i)*rho.*offaxis_unitdirection).^2,2) <=circleRadii(i).^2;
end

% Boolean AND operation, ray needs to pass through all
pass = logical(prod(passpupil,2)); 

end

