function PostSuite2pStim(app,fs,correctionFactor,order,ax,ax2)
%scegliere il file con la funzione solita dell'import
%frequenza campionamento
%scegliere un correction factor (alpha neuropil)
%ordine del filtro
%scegliere un cut factor
%indice suite2p da visualizzare 
%possibile bottone per usare un cut factor ottenuto dal segnale medio di glut

cla(ax) %clear axes
cla(ax2)
start=app.start;
stop=app.stop;
tF=app.tF-start+1;
tL=app.tL-start+1;
dFoverF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,tF);
dFoverF=dFoverF(:,start:stop);
%app.deltaFoF=dFoverF;
time=app.t;
interval=zeros(size(time));
interval(1,tF:tL)=1;


%% divisione in gruppi

    cla(ax) %clear axes
    cla(ax2)
    
%     MAX=max(max(dFoverF))
%     cut=cut*MAX/100

    cutL=app.cutL;
    cutH=app.cutH;
    
    %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
    %perché così lavoro su un momento in cui il comportamento della cellula
    %si è assestato, dato che ho somministrato il farmaco molto prima e c'è
    %stato il tempo di raggiungere una risposta "definitiva"
    m=mean(dFoverF(:,tL-fs*60:tL)')';  
    % m=mean(dFoverF(:,tF+fs*60:tL)')';
    
    idxU=m>=cutH;   %up se hanno un dFoverF>=cut %indici MATLAB
    dfUp=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idxU));
    if sum(idxU)>=1
        dfUp=dFoverF(idxU,:);
        if sum(idxU)==1
            dfUp=dfUp;
        else
            dfUp=mean(dfUp);
        end
        
        plot(time,dfUp,'r','Parent',ax);
        str1=append('EXCITED ',len);
        x=time(10);
        y=double(round(max(dfUp),1));
        text(x,y,str1,'Color','red','Parent',ax)
        hold (ax,'on')
    end
 
    idxD=m<=cutL;  %down se hanno un dFoverF<cutL (negativo)
    dfDown=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idxD));
    if sum(idxD)>=1
        dfDown=dFoverF(idxD,:);
        
        if sum(idxD)==1
            dfDown=dfDown;
        else
            dfDown=mean(dfDown);
        end
        plot(time,dfDown,'g','Parent',ax);
        str2=append('INHIBITED ',len);
        x=time(10);
        y=double(round(max(dfDown),1));

        text(x,y,str2,'Color','green','Parent',ax)
        hold (ax,'on')
        
    end

    idxM=(m>cutL & m<cutH); %middle
    dfMiddle=zeros(1,size(dFoverF,2));
    len=mat2str(sum(idxM));
    if sum(idxM)>=1
        dfMiddle=dFoverF(idxM,:);
        if sum(idxM)==1
            dfMiddle=dfMiddle;
        else
            dfMiddle=mean(dfMiddle);
        end
        plot(time,dfMiddle,'b','Parent',ax)
        str3=append('NO RESP ',len);
        x=time(10);
        y=double(round(max(dfMiddle),1));
        text(x,y,str3,'Color','blue','Parent',ax)
        hold (ax,'on')
    end

    tF=app.tF/fs/60;
    tL=app.tL/fs/60;
    xline(tF,'-.',{'Drug appl',round(tF,2)},'Parent',ax);
    xline(tL,'-.',{'Wash out',round(tL,2)},'Parent',ax);
    xlabel('Time [min]','Parent',ax)
    ylabel('dF/F averaged trace','Parent',ax)
    title(sprintf('Gouping %d cells in excited-inhibited-no response',size(dFoverF,1)),'Parent',ax);
    m=min(min([dfMiddle' dfDown' dfUp']))-2;
    M=max(max([dfMiddle' dfDown' dfUp']))+2;
    ylim(ax,[m M])
    
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
