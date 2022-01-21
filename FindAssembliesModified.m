function [assembliesCells, matchIndexTimeSeries, matchIndexTimeSeriesSignificance, assembliesVectors, PCsRot,confSynchBinary]=FindAssembliesModified(skewfilt_idx)
%To work with this function you need to provide a file with the _RASTER.mat
%suffix organized as follows:
%deltaFoF: a T x N matrix of the ?F/F0 time series of all ROIs.
%raster: a T x N matrix. For each column (i.e., each ROI), it is filled either with zeros for frames with 
%non-significant fluorescent transients or with the ?F/F0 values of the frames with significant transients. 
%If the user does not wish to plot significant trial responses in the response analysis module, or if all the 
%?F/F0 values should be considered in the module for the detection of the assemblies (instead of only 
%the significant transients), it should be a T x N matrix filled with ones.
%movements: T x 1 binary array, with ones for frames where an imaging artifact was found,
%and otherwise zeros.
%dataAllCells.avg: average image of the imaging file, showing the anatomy of the imaged plane.
%dataAllCells.cell_per: an Nx1 cell array, containing the perimeter coordinates for each ROI.
%dataAllCells.cell: a 1 x N cell array, containing the pixel indexes of each ROI
%
%To obtain this file use the createRASTER function.

%%%%%%% INPUT FILES
[filename,pathname] = uigetfile({'*_RASTER.mat';'*_RASTER.MAT'},'Open file with raster data', 'MultiSelect', 'off');
filenameRASTER=fullfile(pathname,filename);

cutName=strfind(filenameRASTER,'_RASTER.mat');
% if isempty(cutName)
%     cutName=strfind(filenameRASTER,'_MultiPlane_RASTER.mat');
%     filenameALL_CELLS=[filenameRASTER(1:cutName-1) '_MultiPlane_ALL_CELLS.mat'];
%     %outputFile=[filenameRASTER(1:cutName-1) '_MultiPlane_CLUSTERS.mat'];
% else
%    filenameALL_CELLS=[filenameRASTER(1:cutName-1) '_ALL_CELLS.mat'];
    %outputFile=[filenameRASTER(1:cutName-1) '_CLUSTERS.mat'];
% end

dataRaster=load(filenameRASTER);
% if exist(filenameALL_CELLS, 'file') == 2
%     dataAllCells=load(filenameALL_CELLS);
% else
    if isfield(dataRaster,'dataAllCells')
        if isfield(dataRaster.dataAllCells,'avg')
            dataAllCells.avg=dataRaster.dataAllCells.avg;
        else
            disp('Error: Field avg in dataAllCells is missing in RASTER file. Quitting program.')
        end
        if isfield(dataRaster.dataAllCells,'cell_per')
            dataAllCells.cell_per=dataRaster.dataAllCells.cell_per;
        else
            disp('Error: Field cell_per in dataAllCells is missing in RASTER file.Quitting program.')
        end
        if isfield(dataRaster.dataAllCells,'cell')
            dataAllCells.cell=dataRaster.dataAllCells.cell;
        else
            disp('Error: Field cell in dataAllCells is missing in RASTER file.Quitting program.')
        end
    else
        disp('Error: Variable dataAllCells missing in RASTER file. Quitting program.')
    end
%end

raster=dataRaster.raster;
deltaFoF=dataRaster.deltaFoF;
movements=dataRaster.movements;

%%

ansMethod = questdlg('Select the number of the clustering method to be used', 'Select clustering method', 'PCA-promax','K-means','Hierarchical clustering','PCA-promax');
clustering.method=ansMethod;

if strcmp(clustering.method,'PCA-promax')
    % Ask if manually select cut-off for assembly cells
    manuallySelect = questdlg('Manually select the cut-off value (zMax) for assembly cells?', 'Question', 'Yes', 'No', 'No');
    
else
    clustering.PCA= questdlg('Reduce dimensionality of the data before clustering?', 'Dimensionality reduction', 'Yes','No','Yes');
      
end

text_si=18;
scrsz = get(0, 'ScreenSize');
set(0,'DefaultAxesFontSize',text_si,'DefaultFigureColor','w', 'DefaultAxesTickDir', 'in','DefaultFigureWindowStyle','normal',...
    'DefaultFigurePosition', [1 1 scrsz(3) scrsz(4)])


numFrames=size(raster,1);

originalNumCells=size(raster,2);
nonSpikingcells=find(nansum(raster,1)==0);

keptCells=setdiff(1:originalNumCells,nonSpikingcells);

cellsOutside=[];

keptCells=setdiff(keptCells,cellsOutside);
nonCosideredCells=sort([nonSpikingcells cellsOutside]);
rasterOld=raster;
deltaFoFOld=deltaFoF;
raster(:,nonCosideredCells)=[];
deltaFoF(:,nonCosideredCells)=[];

rasterAnalog=single(deltaFoF);
rasterClean=single(raster);
rasterClean(logical(movements),:)=0;
rasterAnalog(logical(movements),:)=0;
rasterAnalog(~logical(rasterClean))=0;


rasterZTransf=zscore(rasterAnalog);

if ~strcmp(clustering.method,'PCA-promax')
    window = {['Select number of clusters, a number bigger than 1 and smaller than number of active ROIs (' num2str(size(rasterZTransf,2)) ')']};
    dlg_title = 'Clustering';
    num_lines = 1;
    def = {'2'};
    answer = inputdlg(window,dlg_title,num_lines,def);
    clustering.nClust= str2num(answer{1});
    
    clustering.distanceMetric= questdlg('Select type of distance metric', 'Distance metric', 'euclidean','correlation','euclidean');
    if strcmp(clustering.method,'Hierarchical clustering')
        clustering.linkageAlgorithm= questdlg('Algorithm for computing distance between clusters', 'Hierarchical clustering', 'single','complete','single');
    end
    
end


pValueBinary=pValueSynch(rasterClean,100);
confSynchBinary=find(pValueBinary<0.05,1,'first');




if strcmp(clustering.method,'PCA-promax') | strcmp(clustering.PCA,'Yes')
    
    
    [PCs,~,eigenvals]=princomp(rasterZTransf);
    maxEigenValPastur=(1+sqrt(size(raster,2)/size(raster,1)))^2;
    minEigenValPastur=(1-sqrt(size(raster,2)/size(raster,1)))^2;
    correctionTracyWidom=size(raster,2)^(-2/3);
    
    smaller = eigenvals < maxEigenValPastur + correctionTracyWidom;
    cutOffPC = find(smaller,1)-1; % The significant PCs go up to cutOffPC
    
    if isempty(cutOffPC)
        disp 'No assemblies were found in the data. Quitting program'
        assembliesCells=[];
        PCs=[];
        assembliesVectors=[];
        return
    else
        disp(['Found ' num2str(cutOffPC) ' principal components in data']);
    end
    
end

if strcmp(clustering.method,'K-means')
    
    if strcmp(clustering.distanceMetric,'euclidean')
        clustering.distanceMetric='sqeuclidean';
    end
    if strcmp(clustering.PCA,'Yes')
        %working with reduced dimensionality
        idx = kmeans(PCs(:,1:cutOffPC), clustering.nClust,'distance',clustering.distanceMetric,'replicates',3);
    else
        idx = kmeans(rasterZTransf', clustering.nClust,'distance',clustering.distanceMetric,'replicates',3);
    end
    assembliesCells=cell(clustering.nClust,1);
    for i=1:clustering.nClust
        assembliesCells{i}=find(idx==i);
    end
   
elseif strcmp(clustering.method,'Hierarchical clustering')  
    if strcmp(clustering.PCA,'Yes')
        dists = pdist(PCs(:,1:cutOffPC),clustering.distanceMetric); %dists = pdist(data','correlation');
       
    else
        dists = pdist(rasterZTransf',clustering.distanceMetric); %dists = pdist(data','correlation');
        size(squareform(dists))
    end
    
    Z = linkage(dists,clustering.linkageAlgorithm);
    idx = cluster(Z,clustering.nClust);
    assembliesCells=cell(clustering.nClust,1);
    for i=1:clustering.nClust
        assembliesCells{i}=find(idx==i);
    end
end

if strcmp(clustering.method,'PCA-promax')
    
    [PCsRot, Rot]=rotatefactors(PCs(:,1:cutOffPC),'Method','promax','Maxit',5000);
    
    for i=1:size(PCsRot,2)
        PCsRot(:,i)=PCsRot(:,i)/norm(PCsRot(:,i));
        if max(PCsRot(:,i))<=abs(min(PCsRot(:,i)))
            PCsRot(:,i)=-PCsRot(:,i);
        end
        
    end
    PCsRotOrig=PCsRot;
    cutOffPCOrig=cutOffPC;
    cellNormOnAxis=max(zscore(PCsRot)')';
    
    scrsz = get(0, 'ScreenSize');
    set(0,'DefaultFigurePosition', [1 1 scrsz(3) scrsz(4)])
    
    satisfied='No';
    while strcmp(satisfied,'No')
        PCsRot=PCsRotOrig;
        cutOffPC=cutOffPCOrig;
        if strcmp(manuallySelect,'Yes')
            
            
            [densityNorm,x,uStart] = ksdensity(cellNormOnAxis);
            
            u=uStart;
            
            hf=figure('Name', 'Select the zMax cut-off for including cells in assemblies');
            plot(x,densityNorm,'LineWidth',2,'Color','k');
            title('First select smoothing parameter then select zMax cut-off with mouse','FontWeight','Bold');
            xlabel('zMax'); ylabel('Density')
            set(gca,'Position',[0.13 0.11 0.5 0.815])
            doneSelect=0;
            posIm=get(gca,'Position');
            width=.1; height=.05;
            xpos=min(1-width+.01,posIm(1)+posIm(3)+.01); ypos=posIm(2)+.1;
            uicontrol('Style','pushbutton','String','Select cut-off','CallBack',{@get_Select},'Units','normalized','position',[xpos ypos width height]);
            ypos=ypos+3*height;
            uicontrol('Style','pushbutton','String','Test smoothing','CallBack',{@get_Test},'Units','normalized','position',[xpos ypos width height]);
             ypos=ypos+height;
            uChoose=uicontrol('Style','slider','BackgroundColor','c','Units','normalized','position',[xpos ypos width height],'Min', uStart/10,'Max',uStart*2,...
                'value', uStart,'sliderStep',[uStart/20 uStart/20],'Callback',{@get_slider});
            ypos=ypos+height;
            uicontrol('Style','text','Units','normalized','position',[xpos ypos width height],'String','Smooth parameter slider')
           
            
            while doneSelect==0
                
                drawnow
            end
            
        else
            normCutOff=2;
            disp([num2str(sum(cellNormOnAxis>normCutOff)) ' cells in assemblies']);
        end
        
        disp('zMax selected by user.')
        
        assembliesVectors=zeros(size(PCsRot));
        strengthAssembly=zeros(cutOffPC,1);
        clear assembliesCells;
        count=0; todel=[];
        count2=1;
        for i=1:cutOffPC
            [values, inds]= sort(zscore(PCsRot(:,i)),'descend');
            if isempty(inds(values>=normCutOff))
                todel=[todel i];
                count=count+1;
            else
                assembliesCells{count2}=inds(values>=normCutOff)';
                assembliesVectors(assembliesCells{count2},i)=PCsRot(assembliesCells{count2},i);
                strengthAssembly(i)=norm(assembliesVectors(:,i));
                assembliesVectors(:,i)=assembliesVectors(:,i)/strengthAssembly(i);
                count2=count2+1;
            end
        end
        PCsRot(:,todel)=[];
        assembliesVectors(:,todel)=[];
        strengthAssembly(todel)=[];
        cutOffPC=cutOffPC-count;
        
        if strcmp(manuallySelect,'Yes')
            disp([num2str(length(unique(reshape(cell2mat(assembliesCells),[],1)))) ' cells in assemblies']);
        end
        
        %% Let's check for assemblies that are too similar and merge them...
        similarityThresh=0.6;
        done=0;
        PCsRotMerged=PCsRot;
        assembliesVectorsMerged=assembliesVectors;
        assembliesCellsMerged= assembliesCells;
        count=0;
        % we calculate the projection between the assemblyVectors and if they
        % are bigger than similarityThresh we merge the assembly pair
        while ~done
            % projection
            similarityAssemblies=(assembliesVectorsMerged'*assembliesVectorsMerged);
            similarityAssemblies(logical(triu(similarityAssemblies)))=0;
            % check pairs too similars, and delete them one at a time
            [similar1,similar2]=find(similarityAssemblies>similarityThresh);
            if isempty(similar1)
                done=1;
                break
            end
            vals=zeros(size(similar1));
            for i=1:length(similar1)
                vals(i)=similarityAssemblies(similar1(i),similar2(i));
            end
            [junk,indMax]=max(vals);
            % the merged assemblies is the (thresholded) vectorial sum of their vectors
            summedVectors=(PCsRotMerged(:,similar1(indMax))+PCsRotMerged(:,similar2(indMax)));
            PCsRotMerged(:,[similar1(indMax) similar2(indMax)])=[];
            assembliesVectorsMerged(:,[similar1(indMax) similar2(indMax)])=[];
            assembliesCellsMerged([similar1(indMax) similar2(indMax)])=[];
            newVect=summedVectors/norm(summedVectors);
            PCsRotMerged(:,end+1)=newVect;
            assembliesCellsMerged{end+1}=find(zscore(newVect)>=normCutOff)';
            newVect(zscore(newVect)<normCutOff)=0;
            assembliesVectorsMerged(:,end+1)=newVect/norm(newVect);
            count=count+1;
        end
        disp(['Merging similar assemblies: ' num2str(count) ' pairs merged']);
        
        
        PCsRot=PCsRotMerged;
        assembliesVectors=assembliesVectorsMerged;
        assembliesCells=assembliesCellsMerged;
        clear assembliesVectorsMerged PCsRotMerged assembliesCellsMerged;
        cutOffPC= size(PCsRot,2);
        
        %% Checking assemblies significance
        disp('Checking for significance of the assemblies...');
        % calculate the synchronicity index and correlation level of each assembly
%         syn=zeros(cutOffPC,1);
%         corrsAssemblies=zeros(cutOffPC,1);
%         step=3;
%         vect=1:step:numFrames;
%         for i=1:length(assembliesCells)
%             corrsEns=corr(rasterClean(:,assembliesCells{i}));
%             corrsAssemblies(i)=mean(corrsEns(logical(triu(corrsEns)) & ~eye(size(corrsEns))));
%             count=zeros(size(vect,2),1);
%             for j=1:size(vect,2)-1
%                 temp=logical(sum(rasterClean(vect(j):vect(j+1),assembliesCells{i})));
%                 count(j)=sum(temp);
%             end
%             syn(i)=max(count)/length(assembliesCells{i});
%         end
%         
        % shuffle cell identity of assemblies and calculate surrogate versions of
        % synchronicity index and assembly correlations
%         repeats=1000;
%         corrsAssembliesShuffle=zeros(repeats,1);
%         synShuffle=zeros(repeats,1);
%         for i=1:repeats
%             ind = round(1 + (length(assembliesCells)-1).*rand(1,1));
%             nmCells=length(assembliesCells{ind});
%             newinds=randperm(size(raster,2));
%             shuffledAssembly=newinds(1:nmCells);
%             corrsEns=corr(rasterClean(:,shuffledAssembly));
%             corrsAssembliesShuffle(i)=mean(corrsEns(logical(triu(corrsEns)) & ~eye(size(corrsEns))));
%             count=zeros(size(vect,2),1);
%             for j=1:size(vect,2)-1
%                 temp=logical(sum(rasterClean(vect(j):vect(j+1),shuffledAssembly)));
%                 count(j)=sum(temp);
%             end
%             synShuffle(i)=max(count)/length(assembliesCells{ind});
%         end
%         
%         zSyn=zscore(syn);
%         zCorrsAssemblies=zscore(corrsAssemblies);
%         
%         threshCorrsShuffle=prctile(corrsAssembliesShuffle,95);
%         threshSynShuffle=max(prctile(synShuffle,95),2/3);
%         
%         % These are the weak assemblies:
%         weakAssemblies=find(corrsAssemblies<threshCorrsShuffle | syn<threshSynShuffle | zscore((zSyn + zCorrsAssemblies)/2)<-1);
%         
%         if ~isempty(weakAssemblies)
%             countWeak=length(weakAssemblies);
%         else
%             countWeak=0;
%         end
%         
%         disp([num2str(countWeak) ' assemblies were considered non-singnificant and deleted']);
%         PCsRot(:,weakAssemblies)=[];
%         assembliesVectors(:,weakAssemblies)=[];
%         assembliesCells(weakAssemblies)=[];
        cutOffPC= size(PCsRot,2);
        cutCell=length(unique(reshape(cell2mat(assembliesCells),[],1)));
        disp(['Final assemblies: ' num2str(cutCell) ' cells distributed in ' num2str(cutOffPC) ' assemblies']);
        if ~isempty(assembliesCells)
            disp(['Final assemblies: ' num2str(cutCell) ' cells distributed in ' num2str(cutOffPC) ' assemblies']);
            
%             figure
%             h1=subplot(4,1,[1 2]);
%             cellsIn=unique(reshape(cell2mat(assembliesCells),[],1));
%             provisionalOrder=[cellsIn' setdiff(1:length(keptCells),unique(reshape(cell2mat(assembliesCells),[],1)))];

%             imagesc(rasterAnalog(:,provisionalOrder)'); colormap(1-gray); caxis([0 prctile(reshape(rasterAnalog(rasterAnalog>0),[],1),90)]);  freezeColors; hold on; plot([1 numFrames],[cutCell cutCell],'r');
%             ylabel('ROI #');
%             set(gca,'XTickLabel',[],'TickDir','out');
%             title('Check result... Press Enter to continue')
%             h2=subplot(4,1,3);
%             bar(sum(rasterClean(:,cellsIn),2),1,'k');
%             mx2=max(sum(rasterClean(:,cellsIn),2));
%             set(gca,'XTickLabel',[],'TickDir','out');
%             ylabel('Counts')
%             h3=subplot(4,1,4);
%             bar(sum(rasterClean(:,setdiff(1:length(keptCells),unique(reshape(cell2mat(assembliesCells),[],1)))),2),1,'k')
%             mx3=max(sum(rasterClean(:,setdiff(1:length(keptCells),unique(reshape(cell2mat(assembliesCells),[],1)))),2));
%             ylabel('Counts')
%             set(gca,'TickDir','out');
%             set([h2 h3],'Ylim',[0 max(mx2,mx3)]);
%             linkaxes([h1 h2 h3],'x')
            satisfied = questdlg([num2str(cutCell) ' cells distributed in ' num2str(cutOffPC) ' assemblies. Satisfied?'], 'Question', 'Yes', 'No', 'Yes');
            %pause
        else
            disp('Final assemblies: No assemblies found.')
        end
    end
end

if ~isempty(assembliesCells)
    
    disp('Calculating the activation time-series of the assemblies...');
    numCells=size(raster,2);
    totalClust=length(assembliesCells);
    matchIndexTimeSeries=zeros(totalClust,numFrames);
    matchIndexTimeSeriesSignificance=zeros(totalClust,numFrames);
    
    
    for indClust=1:totalClust
        pattern=zeros(numCells,1);
        pattern(assembliesCells{indClust})=1;
        N=size(rasterClean,2);
        p=sum(pattern);
                
        matchIndexTimeSeries(indClust,:)=(2*(sum(bsxfun(@and,pattern',rasterClean),2))./(p+sum(rasterClean,2)))';
        matchIndexTimeSeriesSignificance(indClust,:)=ones(numFrames,1);
        
        for frame=1:numFrames
            hit=sum(pattern & rasterClean(frame,:)');
            if hit>0
                n=sum(rasterClean(frame,:));
                prob=hygepdf(0:min(p,n),N,p,n);
                matchIndexTimeSeriesSignificance(indClust,frame)=sum(prob(hit:end));
            end
        end
    end
    
    % Plot topography of assemblies
    %numModes=cutOffPC;
    numPlanes=size(dataAllCells.avg,3);
    if numPlanes==1
         bckg=dataAllCells.avg;
         titleFig='Topographies of assemblies';
    else
         bckg=(prctile(dataAllCells.avg(:,:,:),90,3));
         titleFig='Topographies of assemblies over projected stack';
    end
    for k=1:max(ceil(totalClust/9),1)
        
        figure('Name',titleFig);
        set(gcf,'color','w');
        set(gcf, 'Position', get(0,'Screensize'));
        ButtonV=uicontrol('Parent',gcf,'Style','pushbutton','String','Visualize a Cluster','Position',[20,100,100,20],'Units','normalized','Visible','on',...
                                      'CallBack',@(ButtonV,event)buttonVisualize);
        
        for i=1:9
            indMode=i+(k-1)*9;
            if indMode>totalClust
                break
            end
            h=subplot(3,3,i);
            imagesc(bckg); hold on;
            shading flat; colormap gray; axis image;
            set(h,'XTick',[],'YTick',[]);
            for j=1:length(assembliesCells{indMode})
                
                ind=keptCells(assembliesCells{indMode}(j));
                
                verts=[dataAllCells.cell_per{ind}(:,1), dataAllCells.cell_per{ind}(:,2)];
                faces=1:1:length(verts);
                p=patch('Faces',faces,'Vertices',verts,'FaceColor',[1 1 0], 'EdgeColor', [1 1 0]);
                
            end
            title(['Assembly #' num2str(indMode)]);
        end
    end
    
    if numPlanes>1
        done=0;
        while ~done
            ansPlanes = questdlg('Display an assembly over all planes?', 'Multi stack image', 'Yes','No','Yes');
            if strcmp(ansPlanes,'No')
                done=1;
                
            else strcmp(ansPlanes,'Yes')
                window = {'Select assembly to plot'};
                dlg_title = 'Select assembly';
                num_lines = 1;
                def = {''};
                answer = inputdlg(window,dlg_title,num_lines,def);
                selectedAssembly= str2num(answer{1});
                
                for k=1:max(ceil(numPlanes/9),1)
                    
                    figure('Name','Topography of selected assembly');
                    set(gcf,'color','w');
                    set(gcf, 'Position', get(0,'Screensize'));
                   
                    for i=1:9
                        indPlane=i+(k-1)*9;
                        if indPlane>numPlanes
                            break
                        end
                        h=subplot(3,3,i);
                        imagesc(squeeze(dataAllCells.avg(:,:,indPlane))); hold on;
                        shading flat; colormap gray; axis image;
                        set(h,'XTick',[],'YTick',[]);
                        for j=1:length(assembliesCells{selectedAssembly})
                            
                            ind=keptCells(assembliesCells{selectedAssembly}(j));
                            if dataAllCells.fromPlane(ind)==indPlane
                                verts=[dataAllCells.cell_per{ind}(:,1), dataAllCells.cell_per{ind}(:,2)];
                                faces=1:1:length(verts);
                                p=patch('Faces',faces,'Vertices',verts,'FaceColor',[1 1 0], 'EdgeColor', [1 1 0]);
                            end
                        end
                        title(['Plane #' num2str(indPlane)]);
                    end
                end
            end
        end
    end
    
    
     % Reintroduce cells that were left out of the assemblies
    if strcmp(clustering.method,'PCA-promax')
        assembliesVectorsBackup=assembliesVectors;
        PCsRotBackup=PCsRot;
        assembliesVectors=zeros(originalNumCells,cutOffPC);
        PCsRot=zeros(originalNumCells,cutOffPC);
        for i=1:cutOffPC
            assembliesCells{i}=keptCells(assembliesCells{i});
            assembliesVectors(keptCells,i)=assembliesVectorsBackup(:,i);
            PCsRot(keptCells,i)=PCsRotBackup(:,i);
        end
        clear assembliesVectorsBackup PCsRotBackup
        %save(outputFile,'clustering','assembliesCells', 'assembliesVectors', 'PCsRot', 'confSynchBinary', 'matchIndexTimeSeries', 'matchIndexTimeSeriesSignificance')
    else
        for i=1:clustering.nClust
            assembliesCells{i}=keptCells(assembliesCells{i});
           
        end
        %save(outputFile,'clustering','assembliesCells', 'confSynchBinary', 'matchIndexTimeSeries', 'matchIndexTimeSeriesSignificance')
    end
   
       
    disp('Done! Ending program')
    
else
    
    disp('No significant assemblies found.... Quitting program.')
end

    function get_slider(~,~,~)
        u=get(uChoose,'Value');
    end

    function get_Test(~,~,~)

        [densityNorm,x] = ksdensity(cellNormOnAxis,'width',u); 
        cla; 
        plot(x,densityNorm,'LineWidth',2,'Color','k');
        set(gca,'XTick',0:2:(max(x)-mod(max(x),2)));
        title('First select smoothing parameter then select zMax cut-off with mouse','FontWeight','Bold');
        xlabel('zMax'); ylabel('Density')
        set(gca,'Position',[0.13 0.11 0.5 0.815])

    end

    function get_Select(~,~,~)

        [normCutOff,junk]=ginput(1);
        doneSelect=1;
    end
    
    function buttonVisualize()
        window = {'Enter the number of the cluster'};
        dlgtitle = '#';
        dims = [1 50];
        definput = {'1'};
        clusterNum = inputdlg(window,dlgtitle,dims,definput);
        clusterNum= str2double(clusterNum{1});
        index_s2p=cell(length(assembliesCells),1);
        if size(assembliesCells,1)==1
            assembliesCells=assembliesCells';
        end
        
        for t=1:length(assembliesCells)
            index_s2p{t,1}=skewfilt_idx(assembliesCells{t,1},1);
        end
        
        figure
        
        lgn=cell(length(assembliesCells{clusterNum,1}),1);
        for s=1:length(assembliesCells{clusterNum,1})
            lgn{s}=num2str(index_s2p{clusterNum,1}(s)-1);
            subplot(1,2,1),plot(deltaFoF(:,assembliesCells{clusterNum,1}(1,s))), hold on
            subplot(1,2,2),plot(deltaFoF(:,assembliesCells{clusterNum,1}(1,s))+s), hold on
            hold on
        end
        lgd=legend(lgn);
        lgd.Title.String = 'Suite2p indexes';
        title(['Cluster #' num2str(clusterNum)])
    end


end

