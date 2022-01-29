function [coefficientValues,coefficientNames] = fitRadiusPolynomial(offAxisDistances,radii,polynomialString)
%FITSENSITIVITYPOLYNOMIAL Summary of this function goes here
%   Detailed explanation goes here

% [xData, yData] = prepareCurveData( offAxisDistances, radii./radii(1) );
% ft = fittype( polynomialString, 'independent', 'x', 'dependent', 'y' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% 
% 
% 
% [fitresult, gof] = fit( xData, yData, ft, opts );
% coefficientValues=coeffvalues(fitresult);
% coefficientNames=coeffnames(fitresult);


coefficientValues=polyfit(,radii/radii(1)-1,6)
end

