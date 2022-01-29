function meritfunction =  rationalPolyMerit(modelterms,polyNumerator,polyDenominator,indepvariables,targetOutput)


meritfunction = @func;

    function cost = func(variables)        

        % First part is numerator second part denominator coefficients
        polyNumerator=variables(1:numel(polyNumerator));
        polyDenominator=variables(numel(polyNumerator)+[1:numel(polyDenominator)]);
        
        pred = rationalPoly(modelterms,polyNumerator,polyDenominator,indepvariables);
        
        % It can be nan if division by zero happens, should be avoided some
        % way, ignor efor now
        
        useSelection=~isnan(pred); % only NOT NAN values
        
        cost=norm(pred(useSelection)-targetOutput(useSelection));
        
    end

end

