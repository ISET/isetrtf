function [outputArg1,outputArg2] = fitMultivariateLegendre(inputs,output)

% input   IxN
% output  1xN

nbInputs = size(inputs,1); 

x=inputs(1,:);
y=inputs(2,:);

P =  @(n,m,p,q) legendreP(p,x).*legendreP(q,u);
% Function
fapprox = zeros(size(f));

% Projection coefficients
clear a;
for p=0:5
    for q=0:5
        [p,q]
        a(p+1,q+1) = trapz(y,trapz(x,f.*P(p,q),2),1)./ trapz(y,trapz(x,P(p,q).^2,2),1);
        fapprox= fapprox+a(p+1,q+1)*P(p,q);
    end
end


end

