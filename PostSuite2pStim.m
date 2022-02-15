function PostSuite2pStim(app,fs,correctionFactor,order,cut,ax,ax2)
%scegliere il file con la funzione solita dell'import
%frequenza campionamento
%scegliere un correction factor (alpha neuropil)
%ordine del filtro
%scegliere un cut factor
%indice suite2p da visualizzare 
%possibile bottone per usare un cut factor ottenuto dal segnale medio di glut


tF=app.tF;
tL=app.tL;
dFoverF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,correctionFactor,order,tF);
time=0:1/fs:size(dFoverF,2)/fs;
time(end)=[];
time=time/60;
interval=zeros(size(time));
interval(1,tF:tL)=1;


%% divisione in gruppi

    cla(ax) %clear axes
    cla(ax2)
    
    %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
    %perché così lavoro su un momento in cui il comportamento della cellula
    %si è assestato, dato che ho somministrato il farmaco molto prima e c'è
    %stato il tempo di raggiungere una risposta "definitiva"
    m=mean(dFoverF(:,tL-fs*60:tL)')';  
    
    idxU=m>cut;   %up se hanno un dFoverF>cut %indici MATLAB
    dfUp=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idxU));
    if sum(idxU)>1
        dfUp=dFoverF(idxU,:);
        dfUp=mean(dfUp);
        plot(time,dfUp,'r','Parent',ax);
        str1=append('EXCITED ',len);
        x=time(10);
        y=double(round(max(dfUp),1));
        text(x,y,str1,'Color','red','Parent',ax)
        hold (ax,'on')
    end
 
    idxD=m<-cut;  %down se hanno un dFoverF<-0.1
    dfDown=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idxD));
    if sum(idxD)>1
        dfDown=dFoverF(idxD,:);
        dfDown=mean(dfDown);
        plot(time,dfDown,'g','Parent',ax);
        str2=append('INHIBITED ',len);
        x=time(10);
        y=double(round(max(dfDown),1));

        text(x,y,str2,'Color','green','Parent',ax)
        hold (ax,'on')
        
    end

    idx=m>=-cut & m<=cut; %middle
    dfMiddle=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idx));
    if sum(idx)>1
        dfMiddle=dFoverF(idx,:);
        dfMiddle=mean(dfMiddle);
        plot(time,dfMiddle,'b','Parent',ax)
        str3=append('NO RESP ',len);
        x=time(10);
        y=double(round(max(dfMiddle),1));
        text(x,y,str3,'Color','blue','Parent',ax)
        hold (ax,'on')
    end

    tF=tF/fs/60;
    tL=tL/fs/60;
    xline(tF,'-.',{'Drug appl',round(tF,2)},'Parent',ax);
    xline(tL,'-.',{'Wash out',round(tL,2)},'Parent',ax);
    xlabel('Time [min]','Parent',ax)
    ylabel('dF/F averaged trace','Parent',ax)
    title(sprintf('Gouping %d cells in excited-inhibited-no response',size(dFoverF,1)),'Parent',ax);
   
    %ALL CELLS
    LineList = plot(time,dFoverF,'Parent',ax2);
    set(LineList, 'ButtonDownFcn', {@myLineCallback, LineList,app});

    xlabel('Time [min]','Parent',ax2)
    ylabel('dF/F','Parent',ax2)
    title('All cells dF/F traces','Parent',ax2)



    app.dfUp=dfUp;
    app.dfDown=dfDown;
    app.dfMiddle=dfMiddle;
    app.time=time;
    
    app.interval=interval;



end
