function globalDeltaFromTiff(filename) 
warning('off','all')
display(filename);
info=imfinfo(filename);
numframe = length(info);

k=0;

figure()
for K = 1 : numframe
   
    actualFrame=imread(filename,K);
    meanTrace(K)=mean(mean(actualFrame));
    
end

prompt = {'Enter start point for the baseline period:','Enter final point for the baseline period:','Enter the final sample of the part to analyze'};
dlgtitle = 'Baseline Definition';
dims = [1 100 ];
try
    newStr = extractBetween(filename,'[',']');
    splitted=split(newStr,'-');
    str=splitted{1};
    definput = {'1',str,'end'};
catch
    definput= {'1','200','end'};
    
end

answer = inputdlg(prompt,dlgtitle,dims,definput);
start=str2double(answer{1});
stop=str2double(answer{2});
f0=mean(meanTrace(1,start:stop));

try
    final=str2double(answer{3});
    dFoFGlobal=(meanTrace(1,start:final)-f0)./f0;
    
catch
    dFoFGlobal=(meanTrace(1,start:end)-f0)./f0;
end


plot(dFoFGlobal)
xlabel('samples')
ylabel('dF/F')