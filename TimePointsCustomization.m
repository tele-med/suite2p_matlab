function TimePointsCustomization(app)

% path=app.path;
% newStr = extractBetween(path,'[',']');
% splitted=split(newStr,'-');
% str=str2double(splitted);
% 

figure('Name','Time points and interval definition')
mediaF=mean(app.in.F);
plot(mediaF)
hold on

% try
%     %finding all the intervals
%     idx=1;
%     i=1;
%     while length(idx)>=1
%         t(i)=str(idx);
%         sub=str-t(i);
%         idx=find(sub>20,1,'first');
%         i=i+1;  
%     end
% catch
%     display('Wrong type of folder, cant find the deleted black frames written inside []')
%     customization(app);
%     app.start=1; %the start is 1 as default (start of the signal)
%     app.stop=size(app.in.F,2); 
%     app.deltaFoF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,app.tF);
%     app.deltaFoFCut=app.deltaFoF(:,app.start:app.stop);
%     app.t=app.start/app.fs:1/app.fs:app.stop/app.fs;%size(app.deltaFoF,2)/app.fs;
%     %app.t(end)=[];
%     app.t=app.t/60;
% 
%     return
% end

t=[app.tF,app.tL];

for i=1:length(t)
    xline(t(i),'--k')
    hold on
    text(t(i),double(round(mean(mediaF))),'blackfr')
end

xlabel('samples')
ylabel('Mean fluorescence trace')

prompt={'Interval to analize ( i.e. 1,200 or 300,end )[sample]'};
name1='Inputs';
numlines=1;
defaultanswer={'all'};
opt.WindowStyle='normal';
answer=inputdlg(prompt,name1,numlines,defaultanswer,opt);
%start and stop 
app.start=1; %the start is 1 as default (start of the signal)
app.stop=size(app.in.F,2); %the stop point is the end of the signal as default
if strcmp(answer{1},'all')==0
    interval=split(answer{1},',');
    app.start=str2double(interval(1));
    app.stop=str2double(interval(2));
    if isnan(app.stop)==1
        app.stop=length(app.in.F);
    end
end

%if I wanto to define intervals
if strcmp(answer{1},defaultanswer{1})==0
    
    hold on
    plot(app.start:app.stop,mediaF(1,app.start:app.stop),'r');
    elim=zeros(1);
    for i=1:length(t)
        if t(i)>=app.start && t(1)<=app.stop
            xline(t(i),'--k')
            hold on
            text(t(i),double(round(mean(mediaF))),'blackfr')
        else
            elim(1,i)=i;
        end
    end
    
elim(elim==0)=[];
t(elim)=[];    
end


answer = questdlg('Do you want to define the timepoints?(Not a DRUG+WASH-OUT default)',...
                  'Custom experiment','No','Yes','No');
switch answer
    case 'Yes'
        customization(app); 
    case 'No'
        try 
            
            app.tL=t(2); 
            app.tF=t(1);
        catch
            fprintf('You have to define baseline and end of aplication samples')
            customization(app);
            app.tL=size(app.in.F,2);
            app.tF=size(app.in.F,2);
        end
        
end

app.deltaFoF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,app.tF);
app.deltaFoFCut=app.deltaFoF(:,app.start:app.stop);
app.t=app.start/app.fs:1/app.fs:app.stop/app.fs;%size(app.deltaFoF,2)/app.fs;
%app.t(end)=[];
app.t=app.t/60;


    function customization(app)
        prompt2={'Start of the baseline [sample]:','End of the baseline,drug application [sample]:','End of drug application [sample]:'};
        nameprompt='Custom';
        numlin=1;
        defaultansw={'1','10','20'};
        opts.Resize = 'on';
        opts.WindowStyle= 'normal';
        answ=inputdlg(prompt2,nameprompt,numlin,defaultansw,opts);
        app.start=str2double(answ{1});
        app.tF=str2double(answ{2});
        app.tL=str2double(answ{3});
        t(1)=app.tF;
        t(2)=app.tL;
    end
        
end
