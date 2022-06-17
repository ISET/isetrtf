file  = 'wideangle200deg-circle'

f=load([file '-comparison.mat'])


X=[f.relativeIllum.zemax.x f.relativeIllum.zemax.y]
csvwrite([file '-relativeillum-zemax.csv'],X);