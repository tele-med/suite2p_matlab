function PostSuite2pStim(app,name,fs,correctionFactor,order,cut,ax)
%scegliere il file con la funzione solita dell'import
%frequenza campionamento
%scegliere un correction factor (alpha neuropil)
%ordine del filtro
%scegliere un cut factor
%indice suite2p da visualizzare 
%possibile bottone per usare un cut factor ottenuto dal segnale medio di glut
path=append(pwd,'\',name);
in=load(path);

cell_idx=find(in.iscell==1);



try
    newStr = extractBetween(path,'[',']');
    splitted=split(newStr,'-');
    str=str2double(splitted);
    tF=str(1);
    sub=str-tF;
    idx=find(sub>20,1,'first');
    tL=str(idx);
catch
    tF=size(in.F,2);
end


dFoverF=deltaFoverF(in.iscell,in.F,in.Fneu,correctionFactor,order,tF);
time=0:1/fs:size(dFoverF,2)/fs;
time(end)=[];


%% normalizzazione

% %normalizzo
% norm=@(x) (2*(x-min(x))./(max(x)-min(x))-1); %normalizzare??????
% dFNorm=norm(dFoverF)';

dFNorm=dFoverF;
%% divisione in gruppi

m=mean(dFNorm(:,tL-fs*60:tL)')';  %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
maxdf=max(max(dFNorm));

mindf=min(min(dFNorm));
idxU=find(m>cut);   %up se hanno un dFoverF>10% %indici MATLAB
up=dFNorm(idxU,:);
if size(up,1)>1

    dfUp=mean(up);
else
    dfUp=up;
end

idxD=find(m<-cut);  %down se hanno un dFoverF<-10%
down=dFNorm(idxD,:);
if size(down,1)>1
    dfDown=mean(down);
else
    dfDown=down;
end


idx=find(m>=-cut & m<=cut);
middle=dFNorm(idx,:);
if size(middle,1)>1
    dfMiddle=mean(middle);
else
    dfMiddle=middle;
end


cla(ax)
size(dFoverF)
try
   plot(time,dfUp,'r','Parent',ax);
   str1=append('UP ',mat2str(size(up,1)));
   x=round(time(10))
   y=double(round(max(dfUp),1))
   text(x,y,str1,'Color','red','Parent',ax)
   hold (ax,'on')
catch
   hold (ax,'on')
end
try
    plot(time,dfDown,'g','Parent',ax);
    str2=append('DOWN ',mat2str(size(down,1)));
    x=length(10);
    y=double(round(max(dfDown),1))
    
    text(x,y,str2,'Color','green','Parent',ax)
    hold (ax,'on')
catch
    hold (ax,'on')
end
try
    plot(time,dfMiddle,'b','Parent',ax)
    str3=append('NO RESP ',mat2str(size(middle,1)));
    x=time(10);
    y=double(round(max(dfMiddle),1));
    text(x,y,str3,'Color','blue','Parent',ax)
    hold (ax,'on')
catch
    hold (ax,'on')
end

tF=tF/fs;
tL=tL/fs;
xline(tF,'-.',{'Drug appl'},'Parent',ax);
xline(tL,'-.',{'Wash out'},'Parent',ax);

xlabel('Time [s]','Parent',ax)
ylabel('dF/F averaged trace','Parent',ax)

title(sprintf('Gouping %d cells in excited-inhibited-no response',size(dFoverF,1)),'Parent',ax);


figure
for i=1:size(dFNorm,1)
    plot(time,dFNorm(i,:))
    hold on
end
xlabel('Time [s]')
ylabel('dF/F')
title('All cells dF/F traces')

app.dfUp=dfUp;
app.dfDown=dfDown;
app.dfMiddle=dfMiddle;


