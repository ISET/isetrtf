function [arrival_pos,arrival_dir] = rayTraceSingleRay(lens,origin,direction,varargin)
% Coordinate defination
%{
^ (y axis)
|
|
| ---> (z axis)
|
|
(inside plane - x axis)
%}
%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('maxradius', 0, @isnumeric);
p.addParameter('minradius', 0, @isnumeric);
p.addParameter('visualize', true, @islogical);
p.addParameter('waveindex', ones(1, size(origin, 1)), @isnumeric);

p.parse(varargin{:});
vis = p.Results.visualize;
waveIndex = p.Results.waveindex;


rays = rayC('origin',origin,'direction', direction, 'waveIndex',waveIndex, 'wave', lens.wave);
[~, ~, arrival_pos, arrival_dir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', vis);
end


