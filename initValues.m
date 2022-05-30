function initValues(app)
path=app.path;
newStr = extractBetween(path,'[',']');
splitted=split(newStr,'-');
str=str2double(splitted);

try
    %finding all the intervals
    idx=1;
    i=1;
    while length(idx)>=1
        t(i)=str(idx);
        sub=str-t(i);
        idx=find(sub>50,1,'first');
        i=i+1;  
    end
catch
    
    app.txaB.Value='Wrong type of folder, cant find the deleted black frames written inside []';
    return
    
end


app.start=1; %the start is 1 as default (start of the signal)
app.stop=size(app.in.F,2); 
%app.deltaFoF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,app.tF);
%app.deltaFoFCut=app.deltaFoF(:,app.start:app.stop);
app.t=app.start/app.fs:1/app.fs:app.stop/app.fs;
app.t=app.t/60;
app.tL=t(2); 
app.tF=t(1);

app.start=1; %the start is 1 as default (start of the signal)
app.stop=size(app.in.F,2); %the stop point is the end of the signal as default