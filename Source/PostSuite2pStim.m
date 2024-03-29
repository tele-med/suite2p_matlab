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
tD=app.tD-start+1;
tL=app.tL-start+1;
%The dfoverf is the signal calculated as df=(f-f0)/f0, where the f0 value
%is the mean value of the baseline period. The baseline goes from start to
%tF, even if we have a disconnected drug application (tF differs from tD).
dFoverF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,tF);
dFoverF=dFoverF(:,start:stop);
%app.deltaFoF=dFoverF;
time=app.t;
interval=zeros(size(time));
interval(1,tD:tL)=1;


%% divisione in gruppi

    cla(ax) %clear axes
    cla(ax2)
    
%     MAX=max(max(dFoverF))
%     cut=cut*MAX/100

    cutL=app.cutL;
    cutH=app.cutH;
    
    %prendo solo i frame relativi alla met� precedente il lavaggio (tL)
    %perch� cos� lavoro su un momento in cui il comportamento della cellula
    %si � assestato, dato che ho somministrato il farmaco molto prima e c'�
    %stato il tempo di raggiungere una risposta "definitiva"
    tHalf=round((tL-tD)/2); %working on the drug application period, thus starting from tD
    m=mean(dFoverF(:,tL-tHalf:tL)')';  
    idxNaN=find(isnan(m));
    
    try
        nElim=length(app.in.elimDuringCalib); %number of excluded cells
    catch
        disp('No eliminated traces during calibration')
    end
    
    idxU=m>=cutH;   %up se hanno un dFoverF>=cut %indici MATLAB
    app.indexesExcited=idxU;
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
    app.indexesInhibited=idxD;
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
        y=double(round(min(dfDown),1));

        text(x,y,str2,'Color','green','Parent',ax)
        hold (ax,'on')
        
    end

    
    idxM=(m>cutL & m<cutH); %middle
    app.indexesNoResp=idxM;
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
    tD=app.tD/fs/60;
    tL=app.tL/fs/60;
    if tD~=tF
        xline(tF,'-.',{'End of baseline',round(tF,2)},'Parent',ax);
    end
    xline(tD,'-.',{'Drug appl',round(tD,2)},'Parent',ax);
    xline(tL,'-.',{'Wash out',round(tL,2)},'Parent',ax);
    xlabel('Time [min]','Parent',ax)
    ylabel('dF/F averaged trace','Parent',ax)
    title(sprintf('Tot cells:%d | excluded:%d | cutL,cutH: %.1f,%.1f | PB: %s',...
          size(dFoverF,1),nElim,cutL,cutH,app.typePB),'Parent',ax);
    m=min(min([dfMiddle' dfDown' dfUp']))-2;
    M=max(max([dfMiddle' dfDown' dfUp']))+2;
    ylim(ax,[m M])
    
    %ALL CELLS
    dFoverF(idxNaN,:)=0;
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
