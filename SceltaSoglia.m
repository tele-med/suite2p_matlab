%wilkoxon non paramentrical paired test signed rank test

% dFoF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,tF);
f=1;
correctionFactor=0.7;
order=100;
tStart=1; %start of the calibration IN CAMPIONI
tK=588; %potassium application IN CAMPIONI
tStop=1508; %end of the calibration (while still in the application period)IN CAMPIONI

%dFoF=deltaFoverF(iscell,F,Fneu,correctionFactor,order,tK);
dFoF=obj.dFoF;
%need to assess if the baseline il bigger than the drug application period
%or viceversa as I need to take two equally long vectors;
d1=tK-tStart;%before k
d2=tStop-tK;%after k
if d1<=d2
    preStimuli=dFoF(:,1:tK);
    postStimuli=dFoF(:,tStop-tK+1:tStop);
else
    preStimuli=dFoF(:,1:tStop-tK);
    postStimuli=dFoF(:,tK+1:tStop);
end


metaK=round((tStop-tK)/2); 
mediane=median(dFoF(:,tStop-metaK:tStop)');


%% MEDIAN APPROACH
positive=find(mediane>0);
mediana=median(mediane(1,positive));
medianCUT=mediana
%equivalent to
% tracciaMediana=median(dFoF);
% mediana2=median(tracciaMediana(1,tStop-metaK:tStop));
% onemV2=0.2*mediana;

%% STATISTIC APPROACH

differenza=preStimuli-postStimuli;
nPunti=10;
indici=round(linspace(1,length(differenza),nPunti+1));
for i=1:length(indici)-1  
    pre(i,:)=mean(preStimuli(:,indici(i):indici(i+1))');
    post(i,:)=mean(postStimuli(:,indici(i):indici(i+1))');
end

for i=1:size(preStimuli,1)
    %p(i)=signrank(preStimuli(i,:),postStimuli(i,:),'method','exact');
     p(i)=signrank(pre(:,i),post(:,i));
end

nonsignificativi=find(p>0.05);
significativi=find(p<=0.05);

figure
for i=1:length(nonsignificativi)
    plot(dFoF(nonsignificativi(i),:),'r')
    hold on
end
for i=1:length(significativi)
   plot(dFoF(significativi(i),:),'b')
   hold on
end

mediane2=mediane(1,significativi);%double(median(significative(:,tStop-metaK:tStop)));
positive=find(mediane2>0);
wilcoxonCUT=median(mediane2(1,positive))
isign=find(mediane==wilcoxonCUT);
figure
plot(dFoF(isign,:))
text(1,double(wilcoxonCUT),num2str(wilcoxonCUT));
title('Wilcoxon')

% figure
% for i=1:size(dFoF,1) 
%     plot(dFoF(i,:))
%     hold on
% end

%% ANGULAR COEFF APPROACH

%y=mx+q
%m=(y(2)-y(1))/(x(2)-x(1))
%q=y-mx
xBaseline(1)=tStart;
xBaseline(2)=tK;
xDrug(1)=tK;
xDrug(2)=tStop;

for i=1:size(dFoF,1) 

    yBaseline(1)=dFoF(i,tStart);
    yBaseline(2)=dFoF(i,tK);
    mBaseline=(yBaseline(2)-yBaseline(1))/(xBaseline(2)-xBaseline(1));

    yDrug(1)=dFoF(i,tK);
    yDrug(2)=dFoF(i,tStop);
    mDrug=(yDrug(2)-yDrug(1))/(xDrug(2)-xDrug(1));
    
    mDiff(i)=atan(mDrug-mBaseline)*180/pi;
end

indPend=find(mDiff>=0.01); %un decimo di grado
indNoPend=find(mDiff<0.01);
medianePendenza=mediane(1,indPend);
cutPend=median(medianePendenza)

figure()
title('Angular Coefficent Approach')
for i=1:length(indPend)
    plot(dFoF(indPend(i),:),'g')
    hold on
end
for i=1:length(indNoPend)
    plot(dFoF(indNoPend(i),:),'k')
    hold on
end
