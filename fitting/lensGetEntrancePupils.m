function [pupil_positions,pupil_radii] = lensGetEntrancePupils(lens)
% pass = checkRayPassLens(ray_origin,ray_direction, pupil_positions,pupil_radius)
%
% INPUTS
%  lens - lencC object
%
% OUTPUTS
%  pupil_positions - 1xN array with positions of the pupils on the z-axis
%  pupil_radii - 1xN array with radiii of the pupils 


%% Find Pupils
% Optical system needs to be defined to be comptaible wich legacy code
% 'paraxFindPupils'. 
%
% TG: As far as I can see now the entrance (exit) pupil positions are defined
% with respect to the first (last) surface.
% This is an approximation I should improve on because the 

opticalsystem = lens.get('optical system'); 
entrance = paraxFindPupils(opticalsystem,'entrance'); % entrance pupils;


%% Draw diagram Entrance pupils

for i=1:numel(entrance)
    
    %% entrance pupil (with respect to first surface)
    % So to obtain the pupil positions in object space we need to do a
    % corodinate transfurm
    firstEle=lens.surfaceArray(1); % First lens element
    firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius;  % z-Position of first lens surface (furthest vertex)
    
    pupil_radii(i)=entrance{i}.diam(1,1); % Radius of the pupil
    pupil_positions(i)=firstsurface_z+entrance{i}.z_pos(1); % Coordinate transform to object space (position of first surface + relative position of pupil)

end


end

