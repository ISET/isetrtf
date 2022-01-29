function out = rationalPoly(modelterms,polyNumerator,polyDenominator,indepvariables)


[n,p] = size(indepvariables);  % number of data points to evaluate


numerator = evalPoly(polyNumerator,indepvariables);
denominator= evalPoly(polyDenominator,indepvariables);

if(numerator == denominator)
    out = 1
   return; 
end
out = numerator./denominator;





    function ypred = evalPoly(coefficients,indepvariables)
        % Evaluate the model
        nt = size(coefficients,1);
        ypred = zeros(n,1);
        for i = 1:nt
            t = ones(n,1);
            for j = 1:p
                t = t.*indepvariables(:,j).^modelterms(i,j);
            end
            ypred = ypred + t*coefficients(i);
        end
    end


end

