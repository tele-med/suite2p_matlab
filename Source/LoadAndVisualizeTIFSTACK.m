function LoadAndVisualizeTIFSTACK(filename)
tic;
warning('off','all');
info=imfinfo(filename);
numframe = length(info);
totalImage=zeros(512,512,numframe);
for k = 1 : numframe
    actualFrame=imread(filename,'Index',k,'Info',info);
    totalImage(:,:,k) = mat2gray(actualFrame);  
end

implay(totalImage)
toc
end

