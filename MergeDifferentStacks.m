clear all
clc
D=dir('*df*');

up=cell(length(D),3);
down=cell(length(D),3);
middle=cell(length(D),3);
countu=0;
countd=0;
countm=0;

for i=1:length(D)

   fileName=D(i).name; 
    
   if  contains(fileName,'Up')
       countu=countu+1;
       s=load(fileName);
       up{countu,1}=s.dfUp;
       idx=split(extractBetween(fileName,'-','.'),'-');
       up{countu,2}=str2double(idx(1));
       up{countu,3}=str2double(idx(2));
   end
   if contains(fileName,'Down')
       countd=countd+1;
       s=load(fileName);
       down{countd,1}=s.dfDown;
       idx=split(extractBetween(fileName,'-','.'),'-');
       down{countd,2}=str2double(idx(1));
       down{countd,3}=str2double(idx(2));
      
   end
   if contains(fileName,'Middle')
       countm=countm+1;
       s=load(fileName);
       middle{countm,1}=s.dfMiddle;
       idx=split(extractBetween(fileName,'-','.'),'-');
       middle{countm,2}=str2double(idx(1));
       middle{countm,3}=str2double(idx(2));
       
   end
end

s=length(D)/3;
down=reshape(down(~cellfun('isempty',down)),s,3);
up=reshape(up(~cellfun('isempty',up)),s,3);
middle=reshape(middle(~cellfun('isempty',middle)),s,3);

len=cell2mat(cellfun(@length,down,'uni',false));

ltDrug=min(cell2mat((up(:,2))));
idx_init=cell2mat(up(:,2))-ltDrug;
idx_fin=min(len(:,1)-idx_init);%+idx_init;


tWash=mean(cell2mat(up(:,3)));

%Allineo i tracciati ed eseguo la media

for i=1:length(down)
    try
        down{i,1}=down{i,1}(idx_init(i)+1:idx_fin+idx_init(i));
        up{i,1}=up{i,1}(idx_init(i)+1:idx_fin+idx_init(i));
        middle{i,1}=middle{i,1}(idx_init(i)+1:idx_fin+idx_init(i));
    catch 
        continue
    end
end

mdown=mean(cell2mat(down(:,1)));
mup=mean(cell2mat(up(:,1)));
mmiddle=mean(cell2mat(middle(:,1)));

figure
plot(mdown,'g')   %aggiungi tF e tL
hold on
plot(mup,'r')
hold on
plot(mmiddle)
legend(length(down(:,1)),length(up(:,1)),length(middle(:,1)))
xline(ltDrug,'-.',{'Drug appl'});
xline(tWash,'-.',{'Wash out'});
