%% INPUTS
%scegliere il file con la funzione solita dell'import
%scegliere un correction factor
%ordine del filtro
%scegliere un cut factor
%indice suite2p da visualizzare 
%possibile bottone per usare un cut factor ottenuto dal segnale medio di glut

clear all
clc
path='D:/AAdati_tesi/tif-new/150639/noBlack/suite2pS0001[330-331-644]/plane0/Fall.mat';

load(path);


correctionFactor=0.95;  %fattore correzione F per il neuropilo (0.7 consigliata da Suite2p)
order=1;
fs=0.2;                   %frequenza campionamento plane
%name='S0003';

cell_idx=find(iscell==1);

try
    newStr = extractBetween(path,'[',']');
    splitted=split(newStr,'-');
    str=str2double(splitted);
    tF=str(1);
    sub=str-tF;
    idx=find(sub>20,1,'first');
    tL=str(idx);
catch
    tF=size(F,2);
end


dFoverF=deltaFoverF(iscell,F,Fneu,correctionFactor,order,tF);


%% divisione in gruppi


%normalizzo
norm=@(x) (2*(x-min(x))./(max(x)-min(x))-1); %normalizzare??????
dFNorm=norm(dFoverF)';

dFNorm=dFoverF;
%%
cut=0.6;

m=mean(dFNorm(:,tL-fs*60:tL)')';  %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
maxdf=max(max(dFNorm));

mindf=min(min(dFNorm));
idxU=find(m>cut);   %up se hanno un dFoverF>10% %indici MATLAB
up=dFNorm(idxU,:);
if size(up,1)>1

    dfUp=mean(up);
else
    dfUpe=up;
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

%plot
figure
plot(dfUp,'r');
hold on
plot(dfDown,'g');
hold on
plot(dfMiddle,'--')
hold on
xline(tF,'-.',{'Drug appl'});
xline(tL,'-.',{'Wash out'});
str1=append('UP ',mat2str(size(up,1)));
str2=append('DOWN ',mat2str(size(down,1)));
str3=append('MIDDLE ',mat2str(size(middle,1)));
legend(str1,str2,str3)


figure
for i=1:size(dFNorm,1)
    plot(dFNorm(i,:))
    hold on
end

%% salvataggio



save(append(extractBefore(path,'suite2p'),'dfUp',name,'-',num2str(tF),'-',num2str(tL)),'dfUp');
save(append(extractBefore(path,'suite2p'),'dfDown',name,'-',num2str(tF),'-',num2str(tL)),'dfDown');
save(append(extractBefore(path,'suite2p'),'dfMiddle',name,'-',num2str(tF),'-',num2str(tL)),'dfMiddle');


%% visualizza traccia scegliendo indice

suite2p_idx=1;

matlab_idx=suite2p_idx+1;
idx=find(cell_idx==matlab_idx);
sign=dFoverF(idx,:);
plot(sign)
xline(tF,'-.',{'Drug appl'});
xline(tL,'-.',{'Wash out'});


%% elimina max o minimo
dF=dFoverF';
[m,i]=min(min(dF));

[M,I]=max(max(dF));

dFNorm(i,:)=[];
