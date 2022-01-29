function pass = doesRayPassPupils(ray_origin,ray_direction, pupil_distances,pupil_radii)
% pass = checkRayPassLens(ray_origin,ray_direction, pupil_positions,pupil_radius)
%
% INPUTS
%  ray_origin -  3D vector (x,y,z) stating the origin of the ray
%  ray_direction -  3D direction vector (x,y,z) stating the direction of the ray
%  pupil_positions - 1xP array containing distances of pupils from the ray
%  origin plane (this is a relative distance, i.e. a pupil at origin(3)
%  would have a distance 0)
%  pupil_radii     - 1xP array of radii of pupils (paired with
%                     pupil_positions)
%
% OUTPUTS
%  pass  - true/false whether ray passes through lens system

for i=1:numel(pupil_distances)
    alpha = (pupil_distances(i))./(ray_direction(:,3));
    pointOnPupil = ray_origin+alpha.*ray_direction;
    passpupil(:,i)= sum(pointOnPupil(:,1:2).^2,2)<=pupil_radii(i).^2;
end
pass = prod(passpupil,2); % boolean AND operation, ray needs to pass through all
end

