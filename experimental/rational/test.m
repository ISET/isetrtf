
nbVars = 3;
polyDegree=5;



modelterms=buildcompletemodel(polyDegree,nbVars)
 coefNum=randn(size(modelterms,1))
 coefDenom=randn(size(modelterms,1))



% Ignore nans
selection=~isnan(sum(oRays,2));

iRaySel = iRays(selection,:);
oRaySel = oRays(selection,:);

% Evaluate rational
target=oRaySel(:,3);
func=rationalPolyMerit(modelterms,coefNum,coefDenom,iRaySel,target);



x0=[coefNum coefDenom];
[x,fval,exitflag,output] = fminunc(func,x0);




