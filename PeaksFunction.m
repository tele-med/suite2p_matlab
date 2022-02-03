
smoothed_m = conv2(Mb, ones(3)/20, 'same');

for i=1:size(smoothed_m,2)
    plot(smoothed_m(:,i)+i)
    hold on
end


diff=Mb-smoothed_m;

for i=1:size(diff,2)
    plot(diff(:,i)+i)
    hold on
end

p5  = prctile(diff,5); %5th percentile
p95 = prctile(diff,95); %95th percentile

for i=1:size(diff,2)
    signal=diff(:,i);
    interval=find(signal>p5(i) & signal<p95(i));
    m(1,i)=mean(signal(interval));
    s(1,i)=std(signal(interval));
end

Fcut=m+2*s;
smooth = sgolayfilt(double(diff),7,21);


for i=1:size(smooth,2)
    [index,peak]=PeaksDetector(smooth(:,i),Fcut(i));
    indexes{i}=index;
    peaks{i}=peak;
end

i=1;
for j=1:round(size(smooth,2)/4)
    
   if i>size(smooth,2)
       break
   end
    
    fig=figure;
    
    for k=1:4
        ax(k) = subplot(2,2,k);
        
        h1=plot(smooth(:,i));
        hold on
        
        for id=1:length(indexes{i})
            PeaksList = plot(indexes{i}(id),peaks{i}(id),'*r');
            set(PeaksList, 'ButtonDownFcn', {@deleteExistingPeak,PeaksList,peaks{i},indexes{i}}); %delete an existing peak
        end
        
        h1.ButtonDownFcn = {@showZValueFcn,app,peak,index}; %add a new peak

        
        i=i+1;
        if i>size(smooth,2)
            break
        end
    end
   
    
    ButtonVis=uicontrol('Parent',fig,'Style','pushbutton','String','SaveChanges',...
                'Position',[1,1,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)addDiscardPeaks());
    
            i=i+1;
             
end


function addDiscardPeaks()
    fprintf('ciao ciao')
end

