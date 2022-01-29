function [rotatedOrigins,rotatedDirections] = rotateRays(ray_origins_oninputplane,ray_directions)
% Rotate all rays around z  such that the only y component of the origin is
% nonzero and positive.
offaxisDistanceOnInputPlane = sqrt(sum(ray_origins_oninputplane(:,1:2).^2,2));
rotatedOrigins = zeros(size(ray_origins_oninputplane));
rotatedOrigins(:,2)=offaxisDistanceOnInputPlane; % Everything rotated onto y axis
rotatedOrigins(:,3)=ray_origins_oninputplane(:,3);% z coordinate does not change when rotating around z axis

parfor r=1:size(ray_origins_oninputplane,1)
    alpha=atan2d(ray_origins_oninputplane(r,2),ray_origins_oninputplane(r,1));
    a= 90 - alpha; 
    rot = [cosd(a) -sind(a);
           sind(a)  cosd(a)]; 
    rotatedDirections(r,:) = (rot*ray_directions(r,1:2)');
end

% Z component does not change when rotating around z axis;
rotatedDirections(:,3) = ray_directions(:,3);
end  