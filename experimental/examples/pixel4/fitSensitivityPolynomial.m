function [coefficientValues,coefficientNames] = fitSensitivityPolynomial(offAxisDistances,circleCenters,polynomialString)
%FITSENSITIVITYPOLYNOMIAL Summary of this function goes here
%   Detailed explanation goes here

[xData, yData] = prepareCurveData( offAxisDistances, circleCenters );
ft = fittype( polynomialString, 'independent', 'x', 'dependent', 'y' );opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
[fitresult, gof] = fit( xData, yData, ft, opts );
coefficientValues=coeffvalues(fitresult);
coefficientNames=coeffnames(fitresult);

end

