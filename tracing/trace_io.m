function [out_pos,out_direction]  = trace_io(lens,origin,direction)
% Trace a ray from input to output through lens
% Define iset ray and trace using the modified tracer
% 'rtThroughLens_output', which generates no figures and produces output
% vectors.
% The reason that I encapsulate this in the function 'trace_io' is twofold. 
% First, because I think it is very likely that the actual implementation
% will be updated as the raytrace code is quite messy.
% Second, because this function offers an easy minimal ray trace example
% for a single ray.

rays = rayC('origin',origin,'direction', direction, 'waveIndex', 1, 'wave', lens.wave);
[out_pos, out_direction]=lens.rtThroughLens_output(rays,1);

end