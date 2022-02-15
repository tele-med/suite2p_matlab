% 
% smoothed_m = conv2(Mb, ones(3)/20, 'same');
% 
% for i=1:size(smoothed_m,2)
%     plot(smoothed_m(:,i)+i)
%     hold on
% end
% 
% 
% diff=Mb-smoothed_m;
% 
% for i=1:size(diff,2)
%     plot(diff(:,i)+i)
%     hold on
% end
% 
% p5  = prctile(diff,5); %5th percentile
% p95 = prctile(diff,95); %95th percentile
% 
% for i=1:size(diff,2)
%     signal=diff(:,i);
%     interval=find(signal>p5(i) & signal<p95(i));
%     m(1,i)=mean(signal(interval));
%     s(1,i)=std(signal(interval));
% end
% 
% Fcut=m+2*s;
% smooth = sgolayfilt(double(diff),7,21);
% 
% 
% for i=1:size(smooth,2)
%     [index,peak]=PeaksDetector(smooth(:,i),Fcut(i));
%     indexes{i}=index;
%     picchi{i}=peak;
% end
% 
% i=1;
% for j=1:round(size(smooth,2)/4)
%     
%    if i>size(smooth,2)
%        break
%    end
%     
%     fig=figure;
%     
%     for k=1:4
%         ax(k) = subplot(2,2,k);
%         
%         plot(smooth(:,i));
%         hold on
%         
%         plot(indexes{i},picchi{i},'*r');
%         
%         i=i+1;
%         if i>size(smooth,2)
%             break
%         end
%     end
%     
%     i=i+1;
%              
% end
app.fs=1;

W=0.15;
nCells=size(peak.indexes,2);
synch=cell(1,nCells);
for i=1:nCells
    picchi=peak.indexes{i};
    for j=1:length(picchi)
        el=picchi(j);
        elL=el-W;
        elH=el+W;
        
        V=1:1:nCells;
        V(i)=-1;
        
        for v=1:length(V)
            if V(v)==-1
                continue
            else
                id=peak.indexes{v}>=elL & peak.indexes{v}<=elH;
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


for i=1:nCells
    %I need to pair and consider as synchronized those cells with a large number of corresponding peaks
    %If the trace I'm considering has N peaks, I first find all the other
    %cells with a match of at least N/2 peaks.
    %After this firs filtering, I need to consider that the trace I'm
    %focusing on can have N peaks with N<<M (i.e the trace i'm comparing to all the others has N=3 peaks, 
    %while the one I'm comparing to has M=10 peaks). This can lead to false
    %synchronization. 
    %For this reason the second step considers the number M of peaks in the
    %comparative trace and looks if M/2>N/2. If true, the synchronization
    %is void, not considered.
    
    N=length(peak.indexes{i});
    n=round(N/2);
    synchIDX{i}=find(sum(synch{i})>=n); 
    for j=1:length(synchIDX{i})
        ind=synchIDX{i}(j);
        M=length(peak.indexes{ind});
        m=round(M/2); 
        if m>n
            synchIDX{i}(j)=0;
        end
    end
    
end


for i=1:nCells
    if sum(synchIDX{i})==0
        continue
    else
        figure
        
        plot(peak.originalTraces(:,i))
        hold on
        id=round(peak.indexes{i}*app.fs*60);
        
        plot(id,peak.originalTraces(id,i),'*')
        hold on
        ind=synchIDX{i}>0; 
        ind=synchIDX{i}(1,ind);
        for j=1:length(ind)
            try
                trace=peak.originalTraces(:,ind(j))+j;
                plot(trace)
                hold on
                id=round(peak.indexes{ind(j)}*app.fs*60);
                plot(id,trace(id),'*')
            catch
                continue
            end
        end
        title(num2str(i))
    end
end


%VERY SWING CELLS
sorted=cellfun(@sort,indexes,'UniformOutput',false);
difference=cellfun(@diff,sorted,'UniformOutput',false);
l=cellfun(@length,difference);
idx=find(l<2);
for i=1:length(idx)
    difference{idx(i)}=[];
end
v=cellfun(@var,difference);
idx=find(v<=prctile(v,25));

figure
for i=1:length(idx)
    plot(peak.originalTraces(:,idx(i))+i)
    hold on
end
