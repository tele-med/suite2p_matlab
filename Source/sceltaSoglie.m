function [soglie, indWS,indWNS, indSlope,indNSlope, positive, negative]=sceltaSoglie(fs,correctionFacto,order,tStart,tK,tStop,dFoF)
%wilkoxon non paramentrical paired test signed rank test

t=1/fs:1/fs:length(dFoF)/fs;
t=t/60;

% dFoF=dFoF(:,tStart:tStop);

metaK=round((tStop-tK)/2); 
mediane=median(dFoF(:,tStop-metaK:tStop)');

%need to assess if the baseline il bigger than the drug application period
%or viceversa as I need to take two equally long vectors;
d1=tK-tStart;%before k
d2=tStop-tK;%after k
if d1<=d2
    preStimuli=dFoF(:,tStart:tK);
    postStimuli=dFoF(:,tStop-tK+tStart:tStop);
    
else
    preStimuli=dFoF(:,tStart:tStart+tStop-tK);
    postStimuli=dFoF(:,tK:tStop);
    
end



%% MEDIAN APPROACH
positive=find(mediane>0);
negative=find(mediane<=0);
mediana=median(mediane(1,positive));
medianCUT=mediana;
%equivalent to
% tracciaMediana=median(dFoF);
% mediana2=median(tracciaMediana(1,tStop-metaK:tStop));
% onemV2=0.2*mediana;

%% STATISTIC APPROACH

differenza=preStimuli-postStimuli;
nPunti=10;
indici=round(linspace(1,size(differenza,2),nPunti+1));
for i=1:length(indici)-1  
    pre(i,:)=mean(preStimuli(:,indici(i):indici(i+1))');
    post(i,:)=mean(postStimuli(:,indici(i):indici(i+1))');
end

for i=1:size(preStimuli,1)
    %p(i)=signrank(preStimuli(i,:),postStimuli(i,:),'method','exact');
     p(i)=signrank(pre(:,i),post(:,i));
end

nonsignificativi=find(p>=0.05);
significativi=find(p<0.05);

mediane2=mediane(1,significativi);
positive=find(mediane2>0); %just the positive traces are considered in the definition of the threshold
wilcoxonCUT=median(mediane2(1,positive));
indWS=significativi(positive);

mediane3=mediane(1,nonsignificativi);
positive=find(mediane3>0);
indWNS=nonsignificativi(positive);



figure

for i=1:length(significativi)
    plot(t(tStart:tStop),dFoF(significativi(i),tStart:tStop),'k')
    hold on
end

for i=1:length(indWNS)
    plot(t(tStart:tStop),dFoF(indWNS(i),tStart:tStop),'r')
    hold on
end


for i=1:length(indWS)
   plot(t(tStart:tStop),dFoF(indWS(i),tStart:tStop),'b')
   hold on
end

xline(t(tK),'-','Potassium');
title('Wilcoxon: red:p>=0.05(eliminated) -- blue:p<0.05 -- black:inhib')
xlabel('time[min]')
ylabel('dFoF')


%% ANGULAR COEFF APPROACH

%y=mx+q
%m=(y(2)-y(1))/(x(2)-x(1))
%q=y-mx
xBaseline(1)=tStart;
xBaseline(2)=tK;
xDrug(1)=tK;
xDrug(2)=round(tStop-60*fs); %1 minute before the end to not take a point distorced by the low pass

for i=1:size(dFoF,1) 
    
    polB= polyfit(t(tStart:tK), dFoF(i,tStart:tK), 1);
    polD = polyfit(t(tK:tStop), dFoF(i,tK:tStop), 1);

    yBaseline(1)=dFoF(i,xBaseline(1));
    yBaseline(2)=dFoF(i,xBaseline(2));
    mBaseline=(yBaseline(2)-yBaseline(1))/(xBaseline(2)-xBaseline(1));

    yDrug(1)=dFoF(i,xDrug(1));
    yDrug(2)=dFoF(i,xDrug(2));
    mDrug=(yDrug(2)-yDrug(1))/(xDrug(2)-xDrug(1));
    
    mDiff(i)=atan(mDrug-mBaseline)*180/pi;
    
    mDiffPol(i)=atan(polD(1)-polB(1))*180/pi;
end

mDiff=round(mDiff,2);
mDiffPol=round(mDiffPol,2);
indPend=find(mDiff>0.01); %un decimo di grado
indNoPend=find(mDiff<=0.01); 
noPendMedia=mediane(indNoPend);
maintain=noPendMedia>0; %just the positive medians are considered for the definition of the threshold
indNoPend=indNoPend.*maintain;
indNoPend(indNoPend==0)=[];
medianePendenza=mediane(1,indPend);
cutPend=median(medianePendenza);
indSlope=indPend;
indNSlope=indNoPend;

figure

for i=1:length(significativi)
    plot(t(tStart:tStop),dFoF(significativi(i),tStart:tStop),'k')
    hold on
end

for i=1:length(indPend)
    plot(t(tStart:tStop),dFoF(indPend(i),tStart:tStop),'b')
    hold on
end
for i=1:length(indNoPend)
    plot(t(tStart:tStop),dFoF(indNoPend(i),tStart:tStop),'r')
    hold on
end
xline(t(tK),'-','Potassium');
title('Slopes: blue:angle>=slope -- red:angle<slope(eliminated) -- black:inhib')
xlabel('time [min]')
ylabel('dFoF')

soglie=[medianCUT,wilcoxonCUT,cutPend];
end
