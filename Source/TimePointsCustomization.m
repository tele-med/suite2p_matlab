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


t=[app.tF,app.tD,app.tL];

for i=1:length(t)
    xline(t(i),'--k');
    hold on
    text(t(i),double(round(mean(mediaF))),'blackfr');
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

%if I want to define intervals
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
            app.tD=app.tF;
        catch
            fprintf('You have to define baseline and end of aplication samples')
            customization(app);
            app.tL=size(app.in.F,2);
            app.tF=size(app.in.F,2);
        end
        
end

function customization(app)
        prompt2={'Start of the baseline [sample]:','End of the baseline[sample]','Drug application (may be end of baseline)[sample]:','End of drug application [sample]:'};
        nameprompt='Custom';
        numlin=1;
        defaultansw={'1','10','10','20'};
        opts.Resize = 'on';
        opts.WindowStyle= 'normal';
        answ=inputdlg(prompt2,nameprompt,numlin,defaultansw,opts);
        app.start=str2double(answ{1});
        app.in.F=app.in.F(:,app.start:app.stop);
        app.in.Fneu=app.in.Fneu(:,app.start:app.stop);
        app.tF=str2double(answ{2})-app.start+1;
        %tF and tD could be the same if we have a baseline that is immidiately followed by the drug application.
        %if different, it means that the baseline is disconnected by the
        %drug application period, and thus we have something in between the
        %baseline and the drug application we want to ignore
        app.tD=str2double(answ{3})-app.start+1; 
        app.tL=str2double(answ{4})-app.start+1;
        app.stop=app.stop-app.start+1;
        app.start=app.start-app.start+1;
        t(1)=app.tF;
        t(2)=app.tD;
        t(3)=app.tL;
    end
        

app.deltaFoF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,app.tF);
app.deltaFoFCut=app.deltaFoF(:,app.start:app.stop);
app.t=app.start/app.fs:1/app.fs:app.stop/app.fs;
app.t=app.t/60;


    
end
