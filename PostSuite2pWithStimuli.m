clear all
clc
path='Fall.mat'%'C:/Users/Sasha/Downloads/SPZ-VIP/noBlack/suite2p10-12-19-S0003[63-64-65-142-143-144]/plane0/Fall.mat';
load(path);

classifierLevel=0.5;    %threshold classificatore(P>classifierLevel->cell P<classifierLevel->notcell)
correctionFactor=0.95;  %fattore correzione F per il neuropilo (0.7 consigliata da Suite2p)
fs=0.2;                   %frequenza campionamento plane
name='S0003';

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

%idx_cell=find(iscell(:,2)>=classifierLevel);                
idx_cell=find(iscell(:,1)==1);      %trovo indici delle cellule 
Fcorrected=F(idx_cell,:)-correctionFactor*Fneu(idx_cell,:); %correggo neuropil


Fcorrected_filt= medfilt1(Fcorrected',50)';
%Fcorrected_filt=Fcorrected;

%dF/F **per ogni ROI** devo calcolare prima F0 [cioè la baseline avg(Fcorrected(0-->1frameNero))]
%e poi, per ogni istante temporale della traccia, devo calcolare
%dF/F come (Fcorrected-F0)/F0


F0=mean(Fcorrected_filt(:,1:tF-1)')';    %vettore delle medie per ogni ROI (1 ROI =1 riga)

dFoverF=(Fcorrected_filt-F0);            %prova fatta col loop
dFoverF=dFoverF./F0;


%% divisione in gruppi
    
m=mean(dFoverF(:,tL-fs*60:tL)')';  %prendo solo i frame relativi a un minuto precedente il lavaggio (tL)
maxdf=max(max(dFoverF));
mindf=min(min(dFoverF));
idxU=find(m>0.1);   %up se hanno un dFoverF>10%
up=dFoverF(idxU,:);
if size(up,1)>1
    dfUp=mean(up);
else
    dfUpe=up;
end

idxD=find(m<-0.1);  %down se hanno un dFoverF<-10%
down=dFoverF(idxD,:);
if size(down,1)>1
    dfDown=mean(down);
else
    dfDown=down;
end


idx=find(m>=-0.1 & m<=0.1);
middle=dFoverF(idx,:);
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
for i=1:size(dFoverF,1)
    plot(dFoverF(i,:))
    hold on
end

%% salvataggio

% %normalizzo???
% norm=@(x) (x-min(x))/(max(x)-min(x));
% dfUp=norm(dfUp);
% dfDown=norm(dfDown);
% dfMiddle=norm(dfMiddle);


save(append(extractBefore(path,'suite2p'),'dfUp',name,'-',num2str(tF),'-',num2str(tL)),'dfUp');
save(append(extractBefore(path,'suite2p'),'dfDown',name,'-',num2str(tF),'-',num2str(tL)),'dfDown');
save(append(extractBefore(path,'suite2p'),'dfMiddle',name,'-',num2str(tF),'-',num2str(tL)),'dfMiddle');
