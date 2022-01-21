%# remove diagonal elements
%corrMat = mmax + 2*eye(size(mmax));
corrMat=double(mmax);
%# and convert to a vector (as pdist)
dissimilarity = 1 - corrMat(find(corrMat))';
%dissimilarity = 1-corrMat;


%# decide on a cutoff
%# remember that 0.4 corresponds to corr of 0.6!
cutoff = 0.05; 

%# perform complete linkage clustering
Z = linkage(dissimilarity,'single');

%# group the data into clusters
%# (cutoff is at a correlation of 0.5)
groups = cluster(Z,'cutoff',cutoff,'criterion','distance');

dendrogram(Z,0,'colorthreshold',cutoff)


figure
x=67;
y=56;
plot(deltaFoF(x,:))
hold on
plot(deltaFoF(y,:))


[m,idx]=max(corrMat);
au=unique(idx);

for i=1:length(au)
    logic=idx==au(i);
    indexes=find(logic==1);
    group{1,i}=indexes;
    
    figure(i)
    plot(deltaFoF(i,:))
    hold on
    for j=1:length(indexes)
        plot(deltaFoF(indexes(j),:))
        hold on
    end
end



