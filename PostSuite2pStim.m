function PostSuite2pStim(app,fs,correctionFactor,order,cut,ax,ax2)
%scegliere il file con la funzione solita dell'import
%frequenza campionamento
%scegliere un correction factor (alpha neuropil)
%ordine del filtro
%scegliere un cut factor
%indice suite2p da visualizzare 
%possibile bottone per usare un cut factor ottenuto dal segnale medio di glut

path=app.path;

try
    newStr = extractBetween(path,'[',']');
    splitted=split(newStr,'-');
    str=str2double(splitted);
    tF=str(1);
    sub=str-tF;
    idx=find(sub>20,1,'first');
    tL=str(idx);
catch
    tF=size(app.in.F,2);
end


dFoverF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,correctionFactor,order,tF);
time=0:1/fs:size(dFoverF,2)/fs;
time(end)=[];
interval=zeros(size(time));
interval(1,tF:tL)=1;

%normalizzazione
% norm=@(x) (2*(x-min(x))./(max(x)-min(x))-1); %normalizzare??????
% dFNorm=norm(dFoverF)';
dFNorm=dFoverF;

%% divisione in gruppi

    cla(ax) %clear axes
    cla(ax2)
    
    m=mean(dFNorm(:,tL-fs*60:tL)')';  %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
    
    idxU=m>cut;   %up se hanno un dFoverF>0.1 %indici MATLAB
    dfUp=zeros(1,size(dFNorm,2));
    len=mat2str(sum(idxU));
    if sum(idxU)>1
        dfUp=dFNorm(idxU,:);
        dfUp=mean(dfUp);
        plot(time,dfUp,'r','Parent',ax);
        str1=append('EXCITED ',len);
        x=time(10);
        y=double(round(max(dfUp),1));
        text(x,y,str1,'Color','red','Parent',ax)
        hold (ax,'on')
    end
 
    idxD=m<-cut;  %down se hanno un dFoverF<-0.1
    dfDown=zeros(1,size(dFNorm,2));
    len=mat2str(sum(dfDown));
    if sum(idxD)>1
        dfDown=dFNorm(idxD,:);
        dfDown=mean(dfDown);
        plot(time,dfDown,'g','Parent',ax);
        str2=append('INHIBITED ',len);
        x=time(10);
        y=double(round(max(dfDown),1));

        text(x,y,str2,'Color','green','Parent',ax)
        hold (ax,'on')
        
    end

    idx=m>=-cut & m<=cut; %middle
    dfMiddle=zeros(1,size(dFNorm,2));
    len=mat2str(sum(idx));
    if sum(idx)>1
        dfMiddle=dFNorm(idx,:);
        dfMiddle=mean(dfMiddle);
        plot(time,dfMiddle,'b','Parent',ax)
        str3=append('NO RESP ',len);
        x=time(10);
        y=double(round(max(dfMiddle),1));
        text(x,y,str3,'Color','blue','Parent',ax)
        hold (ax,'on')
    end

    tF=tF/fs;
    tL=tL/fs;
    xline(tF,'-.',{'Drug appl'},'Parent',ax);
    xline(tL,'-.',{'Wash out'},'Parent',ax);
    xlabel('Time [s]','Parent',ax)
    ylabel('dF/F averaged trace','Parent',ax)
    title(sprintf('Gouping %d cells in excited-inhibited-no response',size(dFoverF,1)),'Parent',ax);


    %ALL CELLS
    LineList = plot(time,dFNorm,'Parent',ax2);
    set(LineList, 'ButtonDownFcn', {@myLineCallback, LineList,app});

    xlabel('Time [s]','Parent',ax2)
    ylabel('dF/F','Parent',ax2)
    title('All cells dF/F traces','Parent',ax2)



    app.dfUp=dfUp;
    app.dfDown=dfDown;
    app.dfMiddle=dfMiddle;
    app.time=time;
    
    app.interval=interval;



end
