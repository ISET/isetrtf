function [outputArg1,outputArg2] = rtfVsOmniPBRT(thisR,omniFileName,rtfFileName, varargin)

if ~piDockerExists, piDockerConfig; end



varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.addRequired('omniFileName',@ischar);
p.addRequired('rtfFileName',@ischar);
p.addParameter('diaphragmdiameter', NaN, @isnumeric);
p.addParameter('filmdiagonal', 20,@isnumeric);      
p.addParameter('raysperpixel', 100,@isnumeric);      
p.addParameter('filmresolution', [300 300],@isnumeric);      

p.parse(thisR,omniFileName,rtfFileName, varargin{:});
diaphragmDiameter_mm = p.Results.diaphragmdiameter;
filmdiagonal= p.Results.filmdiagonal;
raysperpixel= p.Results.raysperpixel;
filmresolution= p.Results.filmresolution;

%% The chess set with pieces




%{
thisR=piRecipeDefault('scene','ChessSet');
filmZPos_m           = -1.5;
thisR.lookAt.from(3)= filmZPos_m;
%}




%% FIlm distance as provided by Google

% Determine film distance from omni lens file
lens=lensC('file',omniFileName);
filmdistance_mm=lens.get('infocusdistance');



%% Compare Omni with RTF
label{1}='omni';
cameras{1} = piCameraCreate('omni','lensfile',omniFileName);
cameras{1}.filmdistance.type='float';
cameras{1}.aperturediameter.type='float';
cameras{1}.aperturediameter.value= diaphragmDiameter_mm;
cameras{1}=rmfield(cameras{1},'focusdistance');
thisDocker{1} = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';

label{2}='rtf';
cameras{2} = piCameraCreate('raytransfer','lensfile',rtfFileName);
thisDocker{2} = 'vistalab/pbrt-v3-spectral:raytransfer-ellipse';



for c=1:numel(cameras)
    
    camera = cameras{c};
    camera.filmdistance.value=filmdistance_mm/1000;
    
    thisR.set('pixel samples',raysperpixel);
    thisR.set('film diagonal',filmdiagonal,'mm');
    thisR.set('film resolution',filmresolution);
    
    
    thisR.integrator.subtype='path';
    
    thisR.integrator.numCABands.type = 'integer';
    thisR.integrator.numCABands.value =1;
    
    
    
    % Render

    % % RTF
    thisR.set('camera',camera);
    piWrite(thisR);
    

    
    [oiTemp,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker{c});
    oiTemp.name=[omniFileName '-' label{c}];
    oi{c} =oiTemp;
    
    oiWindow(oiTemp);
    %oiSet(oiTemp,'gamma',0.8)
    pause(2)
    exportgraphics(gca,['./fig/scene/' [omniFileName '-' label{c}] '.png'])
end
%% Compare diagional
maxnorm=@(x)x/max(x);
figure; hold on
for i=1:numel(oi)
    plot(maxnorm(diag(oi{i}.data.illuminance)));
end
xlabel('pixels on diagonal')
ylabel('illuminance')
legend(label)
exportgraphics(gca,['./fig/diagonal/' [omniFileName '-' label{c}] '.png'])

return
