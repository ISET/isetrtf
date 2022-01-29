function rootPath = irtfRootPath()
% Return the path to the root isetrtf directory
%
% This function must reside in the directory at the base of the
% ISETRTF.directory structure.  It is used to determine the location
% of various sub-directories.
% 
% Example:
%   fullfile(irtfRootPath,'paper')
%
% Goossens, SCIEN STANFORD, 2022

fullPath = which('irtfRootPath');

rootPath=fileparts(fullPath);

end
