function TimePointsCustomization(app)
list={};
path=app.path;
newStr = extractBetween(path,'[',']');
splitted=split(newStr,'-');
str=str2double(splitted);

%finding all the intervals 
idx=1;
i=1;
while length(idx)>=1
    t(i)=str(idx);
    list{i}=[num2str(t(i))];
    sub=str-t(i);
    idx=find(sub>20,1,'first');
    i=i+1;  
end
%aggiungo la lunghezza del file per poter selezionare la fine
%del file come tL nel caso in cui il lavaggio non sia stato eseguito

list=[list,append(num2str(size(app.in.F,2)),'(end of the signal)')]; 
t=[t,size(app.in.F,2)]
answer = questdlg('Do you want to define the timepoints?(Not a DRUG+WASH-OUT default)',...
                  'Custom experiment','No','Yes','No');
switch answer
    case 'Yes'
        indxF= listdlg('PromptString','Select tDrug sample','SelectionMode','single','ListString',list);
        list=list(1,indxF+1:end);
        indxL = listdlg('PromptString','Select tWashOut sample','SelectionMode','single','ListString',list);
        app.tF=t(indxF)
        app.tL=t(indxL+indxF)
    case 'No'
        try 
           app.tL=t(2); 
           app.tF=t(1);
        catch
           app.tL=size(app.in.F,2);
           app.tF=size(app.in.F,2);
        end
        
end