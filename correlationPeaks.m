function correlationPeaks(M,p)
%M=peak.originalTraces;
%p=peak.indexes;
%photobleaching correction
b=detrend(M);
b=M-b;
Mb=M-b;

[c,lags]=xcorr(Mb,'normalized');
%figure
% stem(lags,c)
[m,i]=max(c);
dim=sqrt(size(c,2));
mmax=triu(reshape(m,dim,dim));

shifts=i-ceil(size(c,1)/2);
shifts=triu(reshape(shifts,dim,dim));

mmax(1:(dim+1):end) = 0; %diag=-2 instead of 1 (max correlation)

prompt={'Enter the minimum corelation level:'};
name='Level of similarity';
numlines=1;
defaultanswer={'0.8'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
 
level=str2double(answer{1}); %INPUT UTENTE
idx=find(mmax>level);
lag=shifts(idx);
[row,col]=ind2sub(size(mmax),idx);
T=[];
P={};

if isempty(col)
    figure
    plot(1,1)
    text(1,1,'No correlation')
    xlim([-2,2])
    ylim([-2,2])
end
 
for i=1:length(col)
    T=[];
    figure
    
    if lag(i)>0 
        
        %plot([Mb(lag(i):end,col(i));zeros(lag(i),1)])
        plot([Mb(:,col(i));zeros(lag(i),1)])
        hold on
        plot([zeros(lag(i),1);Mb(:,row(i))])  %shift only on row
        title('Correlated traces shifted according to the detected optimal lag')
        xlabel('samples')
        ylabel('dF/F')
        
        T(:,1)=[Mb(:,col(i));zeros(lag(i),1)];
        T(:,2)=[zeros(lag(i),1);Mb(:,row(i))];
        P{1}=p{:,col(i)};
        P{2}=p{:,row(i)}+lag(i)/(app.fs*60);
        
    else
        plot(Mb(:,col(i)))
        hold on
        plot(Mb(-lag(i):end,row(i))) %shift
        title('Correlated traces shifted according to the detected optimal lag')
        xlabel('samples')
        ylabel('dF/F')
        
        T(:,1)=Mb(1:end+lag(i)+1,col(i));
        T(:,2)=Mb(-lag(i):end,row(i));
        P{1}=p{:,col(i)};
        P{2}=p{:,row(i)}+lag(i)/(app.fs*60);
        
    end
    
    PeaksFunction(T,P)
   
end



