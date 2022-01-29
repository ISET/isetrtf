clear

lensName={};filmdiagonal=[];
lensName{end+1} = 'wide.40deg.12.5mm'; filmdiagonal(end+1)=40;
  
%%
outputdir = './rtfs/'
outputdir = fullfile(piRootPath,'data','lens/')
%%

failed={}
for i=1:numel(lensName)
    
        disp(['attempt RTF generation - ' lensName{i}])
        lens=lensC('file',[lensName{1} '.json']);
        diaphragmdiameter_mm=lens.apertureMiddleD/2;
        % Generate RTF
        [rtf,rtfLensName]=isetlensToRTF(lensName{i},'outputdir',outputdir,'diaphragmdiameter', diaphragmdiameter_mm);
        disp(['RTF generation Complete- ' lensName{i}])
        
        disp(['Compare OMNI and RTF in PBRT - ' lensName{i}])
        % Compare PBRT simulation image with omni
        rtfVsOmniPBRT([lensName{i} '.json'], [rtfLensName '.json'], 'diaphragmdiameter',diaphragmdiameter_mm,'filmdiagonal',filmdiagonal(i));
        
        
        


end