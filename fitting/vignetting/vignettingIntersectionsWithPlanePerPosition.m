function [pupilPointClouds,positions,circleplanedistance] = vignettingIntersectionsWithPlanePerPosition(iRays,inputplaneZ,varargin)
%vignettingIntersectionsWithPlanePerPosition Determine for each off-axis
%position the intersections of the rays at with a specific circle plane
%(optional argument)
%
% Inputs Required
%     iRays - (Nx3) input rays (r,dx,dy)
%     inputPlaneZ - Z coordinate of input plane (where rays originate)
%
% Inputs Optional
%     circleplanedistance - Choose the distance of the intersection plane
%     from the input plane. Default = 10 mm
%
% Outputs
%     pupilPointClouds - Cell array containing for each off-axis positions
%     positions - all unique off-axis/radial positions (unique(iRays(:,1))


varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('inputrays', @isnumeric);
p.addRequired('inputplaneZ', @isnumeric);
p.addParameter('circleplanedistance', 10, @isnumeric);

    
p.parse(iRays,inputplaneZ,varargin{:});
circleplanedistance= p.Results.circleplanedistance;


% Determine all unique positions 
positions=unique(iRays(:,1));


pupilPointClouds = {};

% For each position, determine the subset of rays that pass and find their
% intersection on the circle plane
for p=1:numel(positions)
    
        % Get the subset of rays that originate at the same position
        iRaysAtPos=iRays((iRays(:,1)==positions(p)),:);
        % By constructin all rays originate at
        origin=[0 iRaysAtPos(1,1) inputplaneZ];
        clear temp;
        for i=1:size(iRaysAtPos,1)
            directions=iRaysAtPos(i,2:3);
            directions(3)=sqrt(1-sum(directions(1:2).^2));
            
            % Find intersection
            pointOnPupil = origin+(circleplanedistance/(directions(3))).*directions;
            temp(:,i)=  pointOnPupil;
        end
        pupilPointClouds{p}=temp;

end

end