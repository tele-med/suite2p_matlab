for i=1:size(M,2)
    figure
    plot(M(:,i))
    hold on
end

smoothed_m = conv2(M, ones(3)/20, 'same');
% numerator = conv2(M, ones(3), 'same'); %works on columns
% denom = conv2(ones(size(M)), ones(3), 'same');
% smoothed_m2 = numerator ./ denom; 

for i=1:size(smoothed_m,2)
    plot(smoothed_m(:,i)+i)
    hold on
end


diff=M-smoothed_m;

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

% 
% for i=1:size(diff,2)
%     signal=diff(:,i);
%     interval=find(signal<Fcut(i));
%     p5(1,i)=prctile(signal(interval),5);
%     p95(1,i)=prctile(signal(interval),95); 
%     interval=find(signal>p5(i) & signal<p95(i));
%     m2(1,i)=mean(signal(interval));
%     s2(1,i)=std(signal(interval));
% end
% 
% Fcut2=m2+s2;

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
    figure
    subplot(2,2,1)
    plot(smooth(:,i))
    hold on
    plot(indexes{i},peaks{i},'*r')
    
    i=i+1;
    subplot(2,2,2)
    plot(smooth(:,i))
    hold on
    plot(indexes{i},peaks{i},'*r')
    
    
    i=i+1;
    subplot(2,2,3)
    plot(smooth(:,i))
    hold on
    plot(indexes{i},peaks{i},'*r')
    
    i=i+1;
    subplot(2,2,4)
    plot(smooth(:,i))
    hold on
    plot(indexes{i},peaks{i},'*r')
    i=i+1;
end

