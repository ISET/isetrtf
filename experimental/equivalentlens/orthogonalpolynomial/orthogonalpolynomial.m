% Test script to improve my understanding of polynomial regression with
% orthognal polynomials.

% Legende polynomials
clear;close all;

figure(1);clf;hold on;
x=linspace(-1,1,100);

for p=1:10
plot(x,legendreP(p,x))


end

%% Projecting a funciton onto Legendre polynomials
% Function
f = sin(2*pi*x);
%f= x.^2;
fapprox = zeros(size(f));
% Projection coefficients
clear a;
for p=0:20
    a(p+1) =trapz(x,f.*legendreP(p,x))./(trapz(x,legendreP(p,x).^2));
     fapprox= fapprox+a(p+1)*legendreP(p,x);
end



figure(4);clf; hold on;
plot(x,f)
plot(x,fapprox)



%% Importance of sampling grid for reducing edge effects,
% Edge effects become significant when including noise
% Function
x=linspace(-1,1,100);
xfine=linspace(-1,1,600);
f= @(x)x.^2-x.^3+x.^4;

% Initialize empty matrices
fapprox = zeros(size(f));
fapprox_fine=fapprox;

% Projection coefficients
clear a afine;
for p=0:20
    a(p+1) =trapz(x,f(x).*legendreP(p,x))./(trapz(x,legendreP(p,x).^2));
    fapprox= fapprox+a(p+1)*legendreP(p,x);
    
    afine(p+1) =trapz(xfine,f(xfine).*legendreP(p,xfine))./(trapz(xfine,legendreP(p,xfine).^2));
    fapprox_fine= fapprox_fine+afine(p+1)*legendreP(p,x);
end

figure(4);clf; hold on;
plot(x,f(x))
plot(x,fapprox,'bo')
plot(x,fapprox_fine,'ro')



%% Solving a VANDERMONDE system for case with incomplete sampling
% Function

f= @(x)sin(2*pi*x);

fapprox = zeros(size(f));
% Projection coefficients
clear a;
% for p=0:1
%         a(p+1) =trapz(x,f(x).*legendreP(p,x))./(trapz(x,legendreP(p,x).^2));
%            fapprox= fapprox+a(p+1)*legendreP(p,x);
% end

xsub = 0+linspace(-0.5,0.5,100);

pmax=10;
systemV=[];
for p=0:pmax
    systemV(:,p+1)=xsub'.^p;
end
a=systemV\f(xsub');

for p=0:pmax
      fapprox= fapprox+a(p+1)*x.^p;
end


figure(4);clf; hold on;
plot(x,f(x),'k')
plot(x,fapprox,'r.')
ylim([-1 1])

%% Solving a VANDERMONDE system for case with incomplete sampling
% Function

f= @(x)sin(2*pi*x);
f= @(x)x+1e-5*randn(size(x));
fapprox = zeros(size(f));
% Projection coefficients
clear a;
% for p=0:1
%         a(p+1) =trapz(x,f(x).*legendreP(p,x))./(trapz(x,legendreP(p,x).^2));
%            fapprox= fapprox+a(p+1)*legendreP(p,x);
% end

xsub = 0+linspace(-0.5,0.5,100);

pmax=10;
systemV=[];
for p=0:pmax
    systemV(:,p+1)=xsub'.^p;
end
a=systemV\f(xsub');

for p=0:pmax
      fapprox= fapprox+a(p+1)*x.^p;
end


figure(4);clf; hold on;
plot(x,f(x),'k')
plot(x,fapprox,'r.')
ylim([-1 1])

%% Solving a system for case with incomplete sampling
% Function

f= @(x)sin(2*pi*x);
fapprox = zeros(size(f));
% Projection coefficients
clear a;
% for p=0:1
%         a(p+1) =trapz(x,f(x).*legendreP(p,x))./(trapz(x,legendreP(p,x).^2));
%            fapprox= fapprox+a(p+1)*legendreP(p,x);
% end

xsub = 0+linspace(-0.5,0.5,100);

pmax=10;
system=[];
for p=0:pmax
system(:,p+1)=[legendreP(p,xsub')];
end
a=system\f(xsub');

for p=0:pmax
      fapprox= fapprox+a(p+1)*legendreP(p,x);
end


figure(4);clf; hold on;
plot(x,f(x),'k')
plot(x,fapprox,'r.')
ylim([-1 1])

%% Projecting a 2D function onto Legendre polynomials 
x=x;
y=x';
P =  @(p,q) legendreP(p,x).*legendreP(q,y);
% Function
f =sin(2*pi*x)+sin(2*pi*y);
fapprox = zeros(size(f));
% Projection coefficients
clear a;
for p=0:20
    for q=0:20
        [p,q]
        
        a(p+1,q+1) = trapz(y,trapz(x,f.*P(p,q),2),1)./ trapz(y,trapz(x,P(p,q).^2,2),1);
        fapprox= fapprox+a(p+1,q+1)*P(p,q);
    end
end

%%
relerr =norm(fapprox-f)/norm(f)
figure(4);clf; hold on;


surf(x,y,f-fapprox);
xlim([-1 1 ])
ylim([-1 1 ])
zlim([-2 2])
