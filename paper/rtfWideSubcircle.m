%% Generate all ray transfer functions using txt file from ZEMAX macro
% 2022 Thomas Goossens

clear; close all;
outputDir = fullfile(piRootPath, 'data/lens/RTF');
%outputDir = fullfile('data/rtf/');


% Configuration variables 
% each lens has its own requirements and configurations
zemaxDataFile={};
lensName={};
offset_sensorside={};
offset_objectside={};
lensThickness={};
disable_dz_polynomial={}; % Set to true for planar surfaces, false for spherical surfaces
polynomialDegrees={};% Polynomial degrees to fit for this lens








%%




%% Wide angle lens 200deg  with spherical output surface WIDE RANGE for vignetting
lensName{end+1}='wideangle200deg-limitcircle-zemax'
zemaxDataFile{end+1}='./data/zemaxraytrace/wideangle200deg-primaryWL1.txt';
offset_sensorside{end+1}=2.003;
offset_objectside{end+1}=2; %%mm
lensThickness{end+1}=14.19057;
disable_dz_polynomial{end+1}=false;
polynomialDegrees{end+1}=[1:13];  




%% Loop over all configurations  and RTF JSON files

for i=1:numel(lensName)
    % Load input output rays
    X=dlmread([zemaxDataFile{i}],'\s',1);
    
    
    % Extract input and output rays from matix
    iRays=X(:,[3 5 6]);
    oRays=X(:,[8 9 10 11 12 13]);
    
    
    %Only keep raysbelow chosen input circle
    select= iRays(:,1) < 0.8;;
    iRays=iRays(select,:);
    oRays=oRays(select,:);
    
    % By convention in our implementation,Z output values need to be
    % measured from rear vertex so we need to.
    % However it is an easy mistake to forget to set the zemax global
    % coordinate system to last vertex of the reverse lens.
    % Hence this piece of code  automatically corrects the z values accordingly
    
    if(max(oRays(:,3))==offset_objectside{i})
        % This branch assumes that the global coordinate was set at the
        % last lens surface. The Z coordinate hence should be the distance of
        % the output plane from the last surface.
        % The maximal Z value is used to account for spherical output surfaces
        oRays(:,3)= oRays(:,3); % No correction needed
    else
        % We apply this translation to put the coordinate axis at the last lens
        % surface.
        oRays(:,3)= oRays(:,3) +(offset_objectside{i}-max(oRays(:,3)));
        
    end
    
    % Generate RTF for multiple polynomial degrees
    for polyDeg = polynomialDegrees{i}
        rtfName = [lensName{i} '-poly' num2str(polyDeg) '-raytransfer'];
        disp(['RTF Generation: ' rtfName])
        rtf=generateRTFfromIO(lensName{i},rtfName,iRays,oRays,offset_sensorside{i},offset_objectside{i},lensThickness{i},...
            'outputdir',outputDir,'visualize',true,'polynomialdegree',polyDeg,...
            'intersectionplanedistance',17);
        % Intersection plane sdistance  is the distance fron the input
        % plane to the plane where the raypass function (ellipses) are
        % calculated. This is an arbitrary choice.
    end
    
end



