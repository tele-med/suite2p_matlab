% T=peak.originalTraces;
% P=peak.indexes;
function PeaksFunction(fs,t,T,P)
%%%T=peak.originalTraces
%%%P=peak.peaks


prompt={'Enter the window size [s]:','Enter the % of missing peaks:'};
name='Input for Peaks function';
numlines=1;
defaultanswer={'50','20'};
 
answer=inputdlg(prompt,name,numlines,defaultanswer);
 
seconds=str2double(answer{1});
nSaltati=str2double(answer{2});


%seconds=50;
W=seconds/60; %minutes 
nCells=size(P,2); %number of cells
synch=cell(1,nCells); %cell array in which we will save the synchronized cells
for i=1:nCells
    picchi=P{i};
    for j=1:length(picchi)
        el=picchi(j); %central element in minutes (not sample)
        elL=el-W;
        elH=el+W;
        
        V=1:1:nCells; %to skip the confront in between a cell and itself
        V(i)=-1; 
        
        for v=1:length(V)
            if V(v)==-1
                synch{i}(:,v)=0; %continue
            else
                id=P{v}>=elL & P{v}<=elH;
                s=sum(id);
                if(s>=1)
                    synch{i}(j,v)=1;
                else
                    synch{i}(j,v)=0;
                end
                    
            end
        end
    
    end
end

%nSaltati=20; %percentuale input utente
nSaltati=nSaltati/100;
synchIDX=cell(size(synch));
for i=2:nCells
    %I need to pair and consider as synchronized those cells with a large number of corresponding peaks
    %If the trace I'm considering has N peaks, and the trace I'm
    %confronting it with has M peaks, I have to first know if N is biger
    %than M or viceversa. In fact if N=3 and M=12, and the 3 peaks of the
    %first trace are all synchronized with the second one, I still don't
    %want to considder these 2 as synchronous, as I don't have enough
    %corrispondences in between the 2.
    
  

    Nattuale=length(P{i});
    for j=1:nCells
        if i~=j
            corrispondenze=sum(synch{i}(:,j));
            Nconfronto=length(P{j});
        
            if Nattuale>Nconfronto
                N=Nattuale-round(Nattuale*nSaltati);
            else
                N=Nconfronto-round(Nconfronto*nSaltati);
            end
            
            if corrispondenze>=N
                synchIDX{i}=[synchIDX{i},j];  
            end
        end
        
       
    end
    if sum(synchIDX{i})>0
       synchIDX{i}=[synchIDX{i},i];
    end
     
 
end


synchIDX=synchIDX(~cellfun('isempty',synchIDX));

for i=1:length(synchIDX)
    
    size_first=size(synchIDX{i},2);

    for j=1:length(synchIDX)
        if i==j
            continue
        else
            size_second=length(synchIDX{j});
            
            num=length(intersect(synchIDX{i},synchIDX{j}));
            
            if size_second<=size_first
               s=size_second;
               idx=j;
            else
                s=size_first;
                idx=i;
            end
        
            if s==num
                synchIDX{idx}=[];
            end
            
        end
    end
end

synchIDX=synchIDX(~cellfun('isempty',synchIDX));

for i=1:length(synchIDX)
        
    figure
    ind=synchIDX{i}>0; 
    ind=synchIDX{i}(1,ind);

    for j=1:length(ind)
        try
            trace=T(:,ind(j))+j;
            plot(trace)
            hold on
            id=round(P{ind(j)}*fs*60);
            plot(id,trace(id),'*')
            hold on
            text(1,double(mean(trace)),num2str(ind(j)))

        catch
            text(1 ,1,'No synchronization detected');
            continue
        end
    end
        
end


%%





%VERY SWING CELLS
% sorted=cellfun(@sort,P,'UniformOutput',false);
% difference=cellfun(@diff,sorted,'UniformOutput',false);
% l=cellfun(@length,difference);
% idx=find(l<2);
% for i=1:length(idx)
%     difference{idx(i)}=[];
% end
% v=cellfun(@var,difference);
% idx=find(v<=prctile(v,25));
% 
% figure
% for i=1:length(idx)
%     plot(T(:,idx(i))+i)
%     hold on 
% end
end
