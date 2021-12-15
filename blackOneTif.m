function image=blackOneTif(filename, destFolder,level)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

display(filename);
info=imfinfo(filename);
numframe = length(info);
eliminated=zeros(1,numframe);
k=0;


for K = 1 : numframe
   
    actualFrame=imread(filename,K);
        
    if mean(mean((actualFrame)))<level
        eliminated=[eliminated,K];      
    else
        k=k+1;
        totalImage(:,:,k) = actualFrame;
    end
    
end

eliminated(eliminated==0)=[];

if ~isempty(eliminated)
    if length(eliminated)==1
        eliminated(2)=numframe-1;
    end
    newName = append(extractBefore(filename,'.tif'),strrep(mat2str(eliminated),' ','-'),'.tif');
    folderName=append('suite2p',extractBefore(newName,'.tif'));
    newName=fullfile(destFolder,newName);
    imwrite(totalImage(:,:,1), newName);
    for i = 2:size(totalImage, 3) %append the rest of the slices
    imwrite(totalImage(:, :, i),newName, 'WriteMode', 'append');
    end
end


mkdir(destFolder,folderName)
image=totalImage;

end



