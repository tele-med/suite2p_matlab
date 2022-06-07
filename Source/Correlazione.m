%invece di selezionare il livello di cross correlazione qui, creati solo la
%matrice di correlazione per le cellule con la varianza alta e poi passala
%al dendrogramma. Decidi lì il taglio. Il dendrogramma dovrebbe
%raggruppartele.

M=deltaFoF';
%qui non va messo deltaFoF ma il deltaFoFskewness, perché voglio lavorare
%SOLO sulle cellule selezionate tramite skewness/varianza

%Eventuale sottogruppo di cellule interessanti ottenute a partire da indici
%suite2p
idx=[0,2,6,7,10,18,20,21,22,28,30,32,37,38,43,45,47,55,58,70,73,...
    74,79,89,105,109,115,117,129,143,145,149,160,162,176,178,180,...
    182,192,199,203,216,231,241,249,247,277,313,319,323,325]+1;
idx_cell=find(iscell(:,1)==1); 
for i=1:length(idx)
    id(1,i)=find(idx_cell==idx(i));
end
M=M(:,id);

%eliminazione baseline
b=detrend(M);
b=M-b;
Mb=M-b;

% app.variance=var(Mb);
% p75=prctile(app.variance,75);
% iH=find(app.variance>p75);
% %s2pidx=app.skewfilt_idx(iH)-1; %controlla gli indici quando integri nella
% %GUI

hightCells=Mb(:,iH); %devo lavorare sulle tracce prive di pendenza

%% divisione 

[c,lags]=xcorr(Mb,'normalized');
%figure
% stem(lags,c)
[m,i]=max(c);
dim=sqrt(size(c,2));
mmax=triu(reshape(m,dim,dim));

shifts=i-ceil(size(c,1)/2);
shifts=triu(reshape(shifts,dim,dim));

mmax(1:(dim+1):end) = 0; %diag=-2 instead of 1 (max correlation)

level=0.6;
idx=find(mmax>level);
lag=shifts(idx);
[row,col]=ind2sub(size(mmax),idx);

% traces=[row;col];
% 
% correlatedrow=deltaFoF(row,:);
% 
% correlatedcol=deltaFoF(col,:);
% 
% figure
% for i=1:size(correlatedcol,1)
%     plot(correlatedcol(i,:))
%     hold on 
% end
% hold on
% 
% for i=1:size(correlatedrow,1)
%     if lag(i)<0
%         
%         pad=zeros(1,-lag(i));
%         crow=[correlatedrow(i,:),pad];
%     end
%     if lag(i)>0
%         pad=zeros(1,lag(i));
%         crow=[pad,correlatedrow(i,:)];
%     end
%     
%     plot(crow)
%     hold on 
% end


%ora bisogna fare un k means che usi queste correlazioni al posto della
%distanza.



%% k-means
len=size(deltaFoF,1);
window = {['Select number of clusters, a number bigger than 1 and smaller than number of active ROIs (' num2str(len) ')']};
%da modificare la size perché poi andrà inserito il numero delle cellule
%attualmente presenti
dlg_title = 'Clustering';
num_lines = 1;
def = {'2'};
nCluster = inputdlg(window,dlg_title,num_lines,def);
nCluster=str2double(nCluster{1});
random=randi([1 len],1,nCluster);

clusters=cell(1,nCluster);

for i=1:nCluster
    clusters{1,i}=deltaFoF(random(i),:);
end



% % This generates 100 variables that could possibly be assigned to 5 clusters
% n_variables = 100
% n_clusters = 5
% n_samples = 1000
% 
% % To keep this example simple, each cluster will have a fixed size
% cluster_size = n_variables // n_clusters
% 
% % Assign each variable to a cluster
% belongs_to_cluster = np.repeat([1:nCluster], cluster_size)
% np.random.shuffle(belongs_to_cluster)
% 
% # This latent data is used to make variables that belong
% # to the same cluster correlated.
% latent = np.random.randn(n_clusters, n_samples)
% 
% variables = []
% for i in range(n_variables):
%     variables.append(
%         np.random.randn(n_samples) + latent[belongs_to_cluster[i], :]
%     )
% 
% variables = np.array(variables)
% 
% C = np.cov(variables)
% 
% def score(C):
%     '''
%     Function to assign a score to an ordered covariance matrix.
%     High correlations within a cluster improve the score.
%     High correlations between clusters decease the score.
%     '''
%     score = 0
%     for cluster in range(n_clusters):
%         inside_cluster = np.arange(cluster_size) + cluster * cluster_size
%         outside_cluster = np.setdiff1d(range(n_variables), inside_cluster)
% 
%         # Belonging to the same cluster
%         score += np.sum(C[inside_cluster, :][:, inside_cluster])
% 
%         # Belonging to different clusters
%         score -= np.sum(C[inside_cluster, :][:, outside_cluster])
%         score -= np.sum(C[outside_cluster, :][:, inside_cluster])
% 
%     return score
% 
% 
% initial_C = C
% initial_score = score(C)
% initial_ordering = np.arange(n_variables)
% 
% plt.figure()
% plt.imshow(C, interpolation='nearest')
% plt.title('Initial C')
% print 'Initial ordering:', initial_ordering
% print 'Initial covariance matrix score:', initial_score
% 
% # Pretty dumb greedy optimization algorithm that continuously
% # swaps rows to improve the score
% def swap_rows(C, var1, var2):
%     '''
%     Function to swap two rows in a covariance matrix,
%     updating the appropriate columns as well.
%     '''
%     D = C.copy()
%     D[var2, :] = C[var1, :]
%     D[var1, :] = C[var2, :]
% 
%     E = D.copy()
%     E[:, var2] = D[:, var1]
%     E[:, var1] = D[:, var2]
% 
%     return E
% 
% current_C = C
% current_ordering = initial_ordering
% current_score = initial_score
% 
% max_iter = 1000
% for i in range(max_iter):
%     # Find the best row swap to make
%     best_C = current_C
%     best_ordering = current_ordering
%     best_score = current_score
%     for row1 in range(n_variables):
%         for row2 in range(n_variables):
%             if row1 == row2:
%                 continue
%             option_ordering = best_ordering.copy()
%             option_ordering[row1] = best_ordering[row2]
%             option_ordering[row2] = best_ordering[row1]
%             option_C = swap_rows(best_C, row1, row2)
%             option_score = score(option_C)
% 
%             if option_score > best_score:
%                 best_C = option_C
%                 best_ordering = option_ordering
%                 best_score = option_score
% 
%     if best_score > current_score:
%         # Perform the best row swap
%         current_C = best_C
%         current_ordering = best_ordering
%         current_score = best_score
%     else:
%         # No row swap found that improves the solution, we're done
%         break
% 
% # Output the result
% plt.figure()
% plt.imshow(current_C, interpolation='nearest')
% plt.title('Best C')
% print 'Best ordering:', current_ordering
% print 'Best score:', current_score
% print
% print 'Cluster     [variables assigned to this cluster]'
% print '------------------------------------------------'
% for cluster in range(n_clusters):
%     print 'Cluster %02d  %s' % (cluster + 1, current_ordering[cluster*cluster_size:(cluster+1)*cluster_size])
% 


