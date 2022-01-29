clear; close all
ieInit;

lensName={};
filmdiagonal=[];polyDegree=[];
diaphragmDiameters=[];
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=5;
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=2;
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=3;
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=4;
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=6;
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=7;

%lensName{end+1} = 'fisheye.87deg.50.0mm';filmdiagonal(end+1)=200;polyDegree(end+1)=6;
%lensName{end+1} = 'dgauss.22deg.12.5mm'; filmdiagonal(end+1)=14; polyDegree(end+1)=5;



%lensName{end+1} = 'dgauss.22deg.100.0mm';
%lensName{end+1} = 'dgauss.22deg.12.5mm'; filmdiagonal(end+1)=20;

%lensName{end+1} = 'dgauss.22deg.3.0mm';filmdiagonal(end+1)=10;polyDegree(end+1)=5;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=8; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=9; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=10; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=11; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=12; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=15; diaphragmDiameters(end+1)=7;
lensName{end+1} = 'dgauss.22deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=20; diaphragmDiameters(end+1)=7;


%lensName{end+1} = 'dgauss.22deg.6.0mm';filmdiagonal(end+1)=10;polyDegree(end+1)=5;
  
%lensName{end+1} = 'petzval.12deg.6.0mm';
%lensName{end+1} = 'petzval.12deg.100.0mm';
%lensName{end+1} = 'petzval.12deg.12.5mm';filmdiagonal(end+1)=11;polyDegree(end+1)=5;
%lensName{end+1} = 'petzval.12deg.3.0mm';
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=1;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=2;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=3;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=4;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=5;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=6;
% lensName{end+1} = 'petzval.12deg.50.0mm';filmdiagonal(end+1)=80;polyDegree(end+1)=7;
  
 
%lensName{end+1} = 'reversed.telephoto.37deg.100mm';
%lensName{end+1} = 'reversed.telephoto.42deg.100mm';
%lensName{end+1} = 'telephoto.250mm'; filmdiagonal(end+1)=20; % error
%lensName{end+1} = 'tessar.22deg.100.0mm';polyDegree(end+1)=5;
%lensName{end+1} = 'tessar.22deg.12.5mm'; filmdiagonal(end+1)=20;
%lensName{end+1} = 'tessar.22deg.3.0mm';
%lensName{end+1} = 'tessar.22deg.50.0mm';polyDegree(end+1)=5;
%lensName{end+1} = 'tessar.22deg.6.0mm';
%lensName{end+1} = 'wide.40deg.100.0mm';
%lensName{end+1} = 'wide.40deg.12.5mm'; filmdiagonal(end+1)=40; % Fails miserably
%lensName{end+1} = 'wide.40deg.3.0mm';
%lensName{end+1} = 'wide.40deg.50.0mm';
%lensName{end+1} = 'wide.40deg.6.0mm';
%lensName{end+1} = 'wide.56deg.100.0mm';
%lensName{end+1} = 'wide.56deg.12.5mm'; filmdiagonal(end+1)=40;polyDegree(end+1)=5;
%lensName{end+1} = 'wide.56deg.3.0mm';filmdiagonal(end+1)=10;polyDegree(end+1)=5;
%lensName{end+1} = 'wide.56deg.50.0mm';filmdiagonal(end+1)=40;polyDegree(end+1)=5;
%lensName{end+1} = 'wide.56deg.6.0mm';
%lensName{end+1} = 'wide.56deg.6.0mm_v3';

%lensName{end+1} = '  fisheye.87deg.100.0mm'; 
%lensName{end+1} = 'fisheye.87deg.12.5mm';                filmdiagonal(end+1)=40;

%lens%lensName{end+1} = 'fisheye.87deg.6.0mm';
  
%%
outputdir = './rtfs/'
outputdir =  './'
%outputdir = fullfile(piRootPath,'data','lens/RTF/')


failed={};
for i=1:numel(lensName)
    try
        disp(['attempt RTF generation - ' lensName{i}])
        
        
        % Set diaphragm size small enough, else PBRT might automatically
        % adjust causing a mismatchin the comparison. 
        lens=lensC('file',[lensName{i} '.json']);
        if(isnan(diaphragmDiameters(i)))
            diaphragmdiameter_mm(i)=lens.apertureMiddleD/2;
        else
            diaphragmdiameter_mm(i)= diaphragmDiameters(i);
        end
        % Generate RTF
        [rtf,rtfname]=isetlensToRTF(lensName{i},'outputdir',outputdir,'diaphragmdiameter', diaphragmdiameter_mm(i),'polydegree',polyDegree(i));
        rtfLensName{i}=rtfname;
        
        disp(['RTF generation Complete- ' lensName{i}])
        
 
        pause(0.5)
 
    catch ME
        
        error([lensName{i} ' RTF generation failed'])
        error(ME.message)
        disp('')
        failed{end+1}=lensName{i};
        continue;
    end

end



%% PBRT omni VS RTF
raysperpixel = 1000
filmresolution = [400 400]
for i=1:numel(lensName)
        disp(['Render Compare OMNI and RTF in PBRT - ' lensName{i}])
        % Compare PBRT simulation image with omni
        thisR=piRecipeDefault('scene','simplescene');
        thisR=piRecipeDefault('scene','chessset');
        thisR.lookAt.from(3)=-1;
        
        %thisR=piRecipeDefault('scene','flatsurface');
        rtfVsOmniPBRT(thisR,[lensName{i} '.json'], [rtfLensName{i} '.json'], ...
            'diaphragmdiameter',diaphragmdiameter_mm(i),'filmdiagonal',filmdiagonal(i),...
            'raysperpixel',raysperpixel,'filmresolution',filmresolution);
        pause(0.1);
    
end