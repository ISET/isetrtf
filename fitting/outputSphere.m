function [fn] = outputSphere(sphericalradius,sphericaloffset)


    fn = @addFinalSurface;
    function newlens =  addFinalSurface(lens)
        %% Lens add additional lens surface for final ray trace (HACK)
        %The script as I found it only traces until the last lens surface.
        % I added an additional flat surface behind the lens which acts as the "output plane".
        % This is a hack such  that the ray tracer continues until final surface.
        
        
        
        % % % Curved
        radiusfinal=-abs(sphericalradius);
        offset=sphericaloffset; diameter=2*abs(radiusfinal); % works well
        
        finalsurface= surfaceC('sCenter', [0 0 radiusfinal+offset], 'sRadius',radiusfinal);
        finalsurface.apertureD=diameter;
        
        
        lens.surfaceArray(numel(lens.surfaceArray)+1)=finalsurface;
        
        
        % TODO I want this to be a new object not a change of state
        newlens = lens;
    end
end

