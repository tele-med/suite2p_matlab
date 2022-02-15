clear all
clc
warning('off','all');

destFolder='noBlack';
mkdir(destFolder);

filename = 'S0001[57-58-59-141-142-143].tif';
info=imfinfo(filename);
numframe = length(info);
eliminated=zeros(1,numframe);

level=1000;
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

if length(eliminated)>0
    newName = append(extractBefore(filename,'.tif'),strrep(mat2str(eliminated),' ','-'),'.tif');
    newName=fullfile(destFolder,newName);
    imwrite(totalImage(:,:,1), newName);
    for i = 2:size(totalImage, 3) %append the rest of the slices
        imwrite(totalImage(:, :, i),newName, 'WriteMode', 'append');
    end
end

%Visualizzazione .tif
prompt='Do you want to visualize the modified tif? Type y/n: ';
x=input(prompt,'s');

if x=='y'
    cookedframes = mat2gray(totalImage);
    implay(cookedframes)
end