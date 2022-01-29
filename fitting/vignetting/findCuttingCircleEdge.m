function [radius,sensitivity] = findCuttingCircleEdge(points,offaxis_distances,side, varargin)
%findCuttingCircleEdge Estimate the circles that cut off the entrance pupil
%
%  Algorithm works by choosing either the furthest (top or bottom) vertex
%  and finding the circle with minimal radius that encloses all points at
%  all off-axis distances. 
%  From this the radius and sensitivity (how much it moves with off axis
%  distance) can be estimated. One has to play with tolerances here and
%  there to get a satisfactory fit.
%
%
%
%  INPUTS
%      points - 2xPxN  (X,Y) x  (pupil positions)  x points
%      offaxis_distances - 1xP   radial off-axis distances
%
%      Varargin:
%      "offset" - A small offset added to the furthest vertex distance
%                      this helps with enclosing all points correctly when
%                      the pupil is not perfectly sampled.
%                 Should not be used in combination with "extremepoints"
%      "extremepoints" - 1xP list of furthest vertices obtained in
%      preprocessing. This will override the "offset" setting.
%                       perfectly circular.  It is therefore a tuning parameter.
%      "stepsize radius" - Determines the increments in radius to be tried.
%      "maxiterations"  - Maximal number of iterations to ensure the
%                       algorithm ends
%  OUTPUTS
%     - radius - Radius of the circle
%     - sensitivity - Defined as displacement_of_center =
%                      sensitivity*offaxis_distances
%
% Thomas Goossens

%}
%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('maxiterations', 5000, @isnumeric);
p.addParameter('stepsizeradius', 0.001, @isnumeric);
p.addParameter('offset',0.1,@isnumeric);
p.addParameter('extremepoints',NaN,@isnumeric);
p.parse(varargin{:});
maxiterations = p.Results.maxiterations;
stepsize_radius = p.Results.stepsizeradius;
offset_vertex = p.Results.offset;
extremepoints = p.Results.extremepoints;


%% Sign convention bottom or up

% Depending on which side of the pupil we are fitting a circle
% some alterations are needed in the equations. In this decision tree the
% sign conventions are fixed so we need to check this only once.
if(side=="bottom")
    flipXY = @(x)x; % no flipping
    sign=1;
    extreme =  @(x) min(x(2,:)); %"lowest" poin
elseif(side=="top")
    flipXY = @(x)x; % no flipping
    sign=-1;
    extreme =  @(x) max(x(2,:)); %"highest" point
elseif(side=="left")
    flipXY = @flip;
    sign=1;
    extreme =  @(x) min(x(1,:)); %"highest" point
elseif(side=="right")    
    flipXY = @flip;
    sign=-1;
    extreme =  @(x) max(x(1,:)); %"highest" point
end


%% Initialization
stopcondition=0;
Rest=0;


%% Find enclosing radius
iterations=0;
while(and(not(prod(stopcondition)),(iterations<maxiterations)))
    for p=1:numel(offaxis_distances)
        Ptrace=points(1:2,p,:);
        
        NaNCols = any(isnan(Ptrace)); % Ignore untraced rays (NAN)
        Pnan = Ptrace(:,~NaNCols);
        ZeroCols = any(Pnan(:,:)==[0;0]); % ingore rays through center (PATCH FOR UNSOLVED BUG)
        Pnan = Pnan(:,~ZeroCols);
        
        % Step 1: choose lowest point
        if(not(isnan(extremepoints)))
            y_extreme = extremepoints(p);
        else
            y_extreme = extreme(Pnan)-sign*offset_vertex;
        end
        stopcondition(p)=sum((sum((Pnan-flipXY([0;(y_extreme+sign*Rest)])).^2,1)<=Rest^2)==0)<1;        
    end
    Rest = Rest+stepsize_radius;

    iterations=iterations+1;
end
if((iterations>=maxiterations))
   error('Maximum number of iterations reached.');
end
radius = Rest;
ycenter=y_extreme+sign*radius;
sensitivity=ycenter/offaxis_distances(p);




end

