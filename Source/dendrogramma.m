%# remove diagonal elements
%corrMat = mmax + 2*eye(size(mmax));
corrMat=double(mmax);
%# and convert to a vector (as pdist)
dissimilarity = 1 - corrMat(find(corrMat))';
%dissimilarity = 1-corrMat;


%# decide on a cutoff
%# remember that 0.4 corresponds to corr of 0.6!
cutoff = 0.5; 

%# perform complete linkage clustering
Z = linkage(dissimilarity,'complete');

%# group the data into clusters
%# (cutoff is at a correlation of 0.5)
groups = cluster(Z,'cutoff',cutoff,'criterion','distance');

dendrogram(Z,0,'colorthreshold',cutoff)


% figure
% x=8;
% y=14;
% plot(deltaFoF(x,:))
% hold on
% plot(deltaFoF(y,:))
% 

[m,ind]=max(corrMat);
au=unique(ind);

for i=1:length(au)
    logic=ind==au(i);
    indexes=find(logic==1);
    group{1,i}=idx(indexes)-1;
    
    figure(i)
    plot(deltaFoF(i,:))
    hold on
    for j=1:length(indexes)
        plot(deltaFoF(id(indexes(j)),:))
        hold on
    end
end



