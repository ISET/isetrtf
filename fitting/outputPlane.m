
function [fn] = outputPlane(offset)

fn = @addFinalSurface;

    function newlens =  addFinalSurface(lens)
        
        %% Lens add additional lens surface for final ray trace (HACK)
        %The script as I found it only traces until the last lens surface.
        % I added an additional flat surface behind the lens which acts as the "output plane".
        % This is a hack such  that the ray tracer continues until final surface.
        
        
        radiusfinal=1e10; % large to make it nearly flat
        filmpos=offset;
        finalsurface = surfaceC('sCenter', [0 0 radiusfinal+filmpos], 'sRadius',radiusfinal);
        finalsurface.apertureD=200*lens.surfaceArray(end).apertureD ;
        
        
        lens.surfaceArray(numel(lens.surfaceArray)+1)=finalsurface;
        
        
        % TODO I want this to be a new object not a change of state
        newlens = lens;
    end

end

