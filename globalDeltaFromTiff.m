function globalDeltaFromTiff(filename) 
display(filename);
info=imfinfo(filename);
numframe = length(info);

k=0;

figure()
for K = 1 : numframe
   
    actualFrame=imread(filename,K);
    meanTrace(K)=mean(mean(actualFrame));
    
end

prompt = {'Enter start point for the baseline period:','Enter final point for the baseline period:'};
dlgtitle = 'Baseline Definition';
dims = [1 100];
newStr = extractBetween(filename,'[',']');
splitted=split(newStr,'-');
str=splitted{1};
definput = {'1',str};
answer = inputdlg(prompt,dlgtitle,dims,definput);

start=str2num(answer{1});
stop=str2num(answer{2});

f0=mean(meanTrace(1,start:stop));
dFoFGlobal=(meanTrace-f0)./f0;


plot(dFoFGlobal)
xlabel('samples')
ylabel('dF/F')