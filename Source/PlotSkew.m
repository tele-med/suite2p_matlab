classdef PlotSkew <handle
    
    properties
        fileName            %'Fall.mat'
        path
        correctionFactor    %alpha multiplicative factor for Fcorr=Fraw-alpha*Fneu
        fs                  %acquisition frequency
        t                   %time vector
        in                  %input structure
        interval
        
        ButtonI             %back button
        ButtonHelp
        
        deltaFoF            %deltaFoverF signal of all the cells imported from suite2p
        deltaFoFskew        %deltaFoverF filtered through skewness (and eventually variance)
        
        iscell              %iscell variable from input structure in
        
        idx_cell            %indexes of the cells imported from suite2p
        skewfilt_idx        %indexes of the subgroup of cells mantained after skewness (and variance) filtering 
        
        stat_cell           %stat(statistics) relative to all the cells imported from suite2p
        skew_cell           %stat relative to the manteined cells after skew(and variance) filtering
        
        skewlevel           %skewness values of the cells
        
        cells               %image of cell regions in random colors
        neu                 %image of neuropil regions (donuts)
        skew                %image of cell in different colors according to their skewness velue
        s                   %skew image, but after skewness filtering
        imageIdx            %MATLAB 1-based indexes
        
        hFig                %figure relative to the skewness panel
        fig                 %figure relative to the variance panel
        TextH               %text field for skewness level
        TextC               %text field for intresting cells
        txt                 %intresting indexes choosen by user
        ButtonH             %button for cell selection and plot
        ButtonIdx           %button for printing the indexes of the cells in the FOV
        ButtonSaveIdx       %button for saving the indexes of the cells in the FOV
        ButtonC             %button for clustering
        ButtonV             %button for variance filtering
        ButtonVis           %button for visualizing cells
        ButtonK             %button for keeping just the selected cells
        ButtonD             %Button for deleting the selected cells
        ButtonRS            %button for choosing between random/skewness visualization
        ButtonCrop
        
        clusters            %cell array containg the index of cells belonging to clusters
        variance            %variance values for each cell
        mantain             %indexes of cells the user wants to mantain after the variance filtering
        
        iL                  %indexes of cells with variance>percentile25
        iLs2p               %indexes according to suite2p metrics
        
        peaksOrig
        peaksNew
        PeakAnalysisButton
        indexesOrig
        indexesNew
        coeff
        ButtonPeak          %to find peaks on a new signal
        ButtonExistingPeak  %to load already calculated peaks
        M
        freq                %frequency of events 
        %frequencies        %texts with frequencies
    end
    
    
    methods
        
        function app=PlotSkew(path,fileName,correctionFactor,fs,interval)
           
            app.correctionFactor=correctionFactor;
            app.fileName=fileName; %il nome ? Fall.mat, ? il file che contiene tutti gli output di suite2p
            app.path=path;
            app.fs=fs;
            cd(app.path);
            if ~exist('MatlabResults', 'dir')
                mkdir('MatlabResults')
                sprintf('MatlabResults folder created')
            end
            app.in=load(fileName);
            app.iscell=app.in.iscell;
            app.interval=interval;
            
            
            intervals(app,app.interval);

            app.deltaFoF=deltaFoverF(app.iscell,app.in.F,app.in.Fneu,correctionFactor,5);

           
            %inizializzazione deltaFoverFskew con il deltaFoF totale
            app.deltaFoFskew=app.deltaFoF;
            
            %indici delle cellule (suite2p indexes but 1 based)
            app.idx_cell=find(app.iscell(:,1)==1); %REMEMBER in suite2p the idx=idx_cell-1
            %init of the skewness filtered indexes to all the
            %cells indexes (in matlab coords,so 1-based --> s2pindexes=skewfilt_idx-1)
            app.skewfilt_idx=app.idx_cell;
            
            %stat delle sole cellule (stat of cells)
            app.stat_cell=app.in.stat(app.idx_cell);
            %init of the vector containing just the stat of the skewness
            %filtered cells to the one of all the suite2p had found
            app.skew_cell=app.stat_cell;
            
            app.t=0:1:size(app.deltaFoF,2)-1;
            app.t=app.t/app.fs;
            %0:1/app.fs:size(app.deltaFoF,2)/app.fs-1;
            app.t=app.t/60; %in minutes
            
            %levels of skewness of each cell
            for s=1:length(app.stat_cell)
                app.skewlevel(1,s)=app.stat_cell{s}.skew;
            end

            app.initImage 
        end
        
        function initImage(app)
            
            [image,~,image_idx]=createImage(app.fileName);

            app.skew=image; %select skewness
            app.s=image;
            skewnessHandling(app)

            app.imageIdx=image_idx;

        end
        
        function showImage(app,image)
            % %PLOTTING THE MASKS IN RANDOM COLORS
            
            f=figure;
            f.Position=[488,253,700,700];
            indietro(app,f);
            mymap=[[1,1,1];hsv];
            imshow(rescale(image),'Colormap',mymap)
            
        end

        function skewnessHandling(app)
            %PLOTTING THE SKEWNESS IMAGE
            app.hFig = figure;
            app.hFig.Name = 'Swing Cells Experiment';
            mymap=[[1 1 1];jet];
           
            %perimeter of another color
            imp=isnan(app.skew)==0;
            imp=bwperim(imp);
            i=imp==1;
            app.skew(i)=app.skew(i)-0.5;
            
            imshow(app.skew, 'Colormap',mymap);
            
            maxSkew=round(max(max(app.skew)),1);
            middle=maxSkew/2;
            minSkew=round(min(min(app.skew)),1);
            hcb=colorbar('Ticks',[minSkew,middle,maxSkew],'TickLabels',{mat2str(minSkew),mat2str(middle),mat2str(maxSkew)});
            set(get(hcb,'Title'),'String','Skewness')
            caxis([minSkew middle]) 
            
            app.hFig.Position=[400,100,800,500];
            axes=gca;
            axes.Position=[0.2,0.14,0.8,0.8];
            
            addComponents(app)
            
        end
        
        function addComponents(app)
            %button to come back to the principal question box
            indietro(app,app.hFig);
            
            %text area for cell selection
            app.TextC=uicontrol('Parent',app.hFig,'Style','edit','Visible','on',...
                'Position',[10,450,200,20],'String','#cell separated by commas','Units','Normalized');
                
            app.ButtonVis=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Visualize',...
                'Position',[10,430,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonVis,event)intrestingCells(app));
            
            app.ButtonCrop=uicontrol('Parent',app.hFig,'Style','pushbutton','String','CropImage',...
                'Position',[110,430,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)croppingFunction(app));
            
            app.ButtonK=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Keep this cells',...
                'Position',[10,410,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonK,event)keepDeleteCells(app,0));

            app.ButtonD=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Delete this cells',...
                'Position',[110,410,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonK,event)keepDeleteCells(app,1));
            
            app.ButtonIdx=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Print Indexes',...
                'Position',[10,390,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonK,event)printIdx(app,0));
            app.ButtonSaveIdx=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Save indexes',...
                'Position',[110,390,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonK,event)printIdx(app,1));
            
            %Add text area for skewness level
            app.TextH=uicontrol('Parent',app.hFig,'Style','edit','Visible','on',...
                'Position',[10,20,100,20],'String','Skewness level','Units','Normalized',...
                'CallBack',@(TextH,event) skewnessLevelChanged(app));

            %Add button for selecting cells
            app.ButtonH=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Select Cells',...
                'Position',[120,20,60,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonH,event)buttonPressed(app.hFig,app.ButtonH,app.skew_cell,app.deltaFoFskew,app.skewfilt_idx,app.t));

            %Add button for clustering
            app.ButtonC=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Clustering','Position',[200,20,60,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)clusteringButton(app));
            
            %Add button for variance low filtering
            app.ButtonV=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Variance filtering','Position',[280,20,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)varianceFunct(app));
            
         
            app.ButtonPeak=uicontrol('Parent',app.hFig,'Style','pushbutton','String','PeakDetection',...
                'Position',[450,20,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)askCoefPeak(app));
            
            app.ButtonExistingPeak=uicontrol('Parent',app.hFig,'Style','pushbutton','String','LoadPeaks',...
                'Position',[560,20,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)loadPeaks(app));
            
            app.PeakAnalysisButton=uicontrol('Parent',app.hFig,'Style','pushbutton','String','AnalyzePeaks',...
                'Position',[670,20,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)findPeakSynch(app));
            
            
            
            n=app.iscell(:,1);
            n(n==0)=[];
            n=string(length(n));
            n=append("Total number of cells: ",n);
            lbl = uicontrol(app.hFig,'Style','text','String',n,'Position',[10,200,100,30]);
            
        end
        
        function skewnessLevelChanged(app)
            %textChanged callback function for the text field dedicated to the
            %skewness level.
            
            levelSkew=str2double(split(app.TextH.String,','));
            
            if length(levelSkew)==1
                levelSkewH=levelSkew;
                levelSkewL=min(app.skewlevel)-1;
            else
                levelSkewL=levelSkew(1);
                levelSkewH=levelSkew(2);
            end

            %in skewfilt_idx inserisco gli indici delle cellule filtrate per
            %la skewness indicata dall'utente.
            app.skewfilt_idx=[];
            
            %in skewlevel inserisco il valore di skewness delle cellule
            %filtrate
            app.skewlevel=[];
            
            %I want to mantain the external range of skewness and get rid
            %of the internal values.
            % --------levelSkewL xxxxxx SlevelkewH--------- 
            for i=1:length(app.stat_cell)
                if app.stat_cell{1,i}.skew>levelSkewH || app.stat_cell{1,i}.skew<levelSkewL
                   app.skewfilt_idx=[app.skewfilt_idx,i]; 
                   app.skewlevel=[app.skewlevel;app.stat_cell{1,i}.skew];
                end
            end
            app.deltaFoFskew=app.deltaFoF(app.skewfilt_idx,:);
            app.skew_cell=app.stat_cell(1,app.skewfilt_idx); %stat delle cellule filtrate per skewness
            app.skewfilt_idx=app.idx_cell(app.skewfilt_idx,1); %idx of the suite2p file filtered through skewness


            %image construction
            ind=find(app.s<levelSkewH & app.s>levelSkewL);
            
            app.s(ind)=NaN;
            
            imageUpdate(app)

  
        end
        
        function imageUpdate(app)
            figure(app.hFig.Number)
            axes=gca(app.hFig);
            imh = imhandles(axes); %gets your image handle if you dont know it
            set(imh,'CData',app.s);
        end
        
        function variablesUpdate(app,indexes)
              %updating variables
              app.skewfilt_idx(indexes)=[];
              app.deltaFoFskew(indexes,:)=[]; 
              app.skew_cell(indexes)=[];
              app.skewlevel(indexes)=[];
        end
    
        function clusteringButton(app)
            %callback function which creates the _RASTER.m file and launchs the
            %clustering function.
            createRASTER(app.deltaFoFskew,app.skewfilt_idx,app.in.ops,app.in.stat);
            app.clusters=FindAssembliesModified(app.skewfilt_idx);
            delete *_RASTER.mat

        end
       
        function varianceFunct(app)
            type = questdlg('Variance Analysis', 'Choose the variance filtering type:', 'Low','High','Low');
            %baseline elim
            b=detrend(app.deltaFoFskew')';
            b=app.deltaFoFskew-b;
            deltaFoFbaseline=app.deltaFoFskew-b;

            %variance calc
            app.variance=var(deltaFoFbaseline');
            
            switch type
                case 'Low'
                    varianceLow(app)
                case 'High'
                    varianceHigh(app)
            end
        
        end
            
        function varianceLow(app)
            p25=prctile(app.variance,25);
            app.iL=find(app.variance<=p25); %to delete
            app.iLs2p=app.skewfilt_idx(app.iL,:)-1; %for the legend
            sliderPlotNew(app);
        end
        
        function sliderPlotNew(app)
            app.fig=figure('Position',[621,105,550,650]);
            panel1 = uipanel('Parent',app.fig,'Position',[0,0,500,100]);
            panel2 = uipanel('Parent',panel1);
            textA=uicontrol('Parent',panel2,'Style','edit','Visible','on','Position',[10 1250 200 20],...
                            'String','Indexes to mantain separated by commas');
            uicontrol('Parent',panel2,'Style','pushbutton','Visible','on','Position',[10,1220,60,20],...
                            'String','Filter cells',...
                            'CallBack',@(buttonA,event) discardTraces(app,textA));
            set(panel1,'Position',[0 0 0.95 1]);
            set(panel2,'Position',[0 -1 1 2]);
            set(gca,'Parent',panel2);
            A=app.deltaFoFskew(app.iL,:); %signals with low variance
            
            for i=1:size(A,1)
                sign=A(i,:)+i;
                plot(app.t,sign); 
                hold on
                x=app.t(round(length(app.t)/2));
                y=i;
                text(x,y,num2str(app.iLs2p(i,:))); %plotting the suite2p index on every trace
            end
            ylim([0 size(A,1)+2]);
            xlabel('time [min]')
            ylabel('Fluorescence traces')

            %slider component
            uicontrol('Style','Slider','Parent',app.fig,...
                  'Units','normalized','Position',[0.95 0 0.05 1],...
                  'Value',1,'Callback',{@slider_callback1,panel2});
               
            %callback to scroll up/down
            function slider_callback1(src,event,arg1)
                val = get(src,'Value');
                set(arg1,'Position',[0 -val 1 2])
            end

        end
        
        function discardTraces(app,textA)
            app.mantain=str2double(split(textA.String,','));
            
            if~isnan(app.mantain)
                for j=1:length(app.mantain)
                    idx=find(app.iLs2p==app.mantain(j));
                    app.iL(idx)=[]; %iL=index TO DELETE, from which we take off the one user decided to mantain
                end
            end
            
            textA.String='Done';

            %image construction
            for n=1:length(app.iL)
                ypix = app.skew_cell{app.iL(n)}.ypix+1; %without overlapping pixels
                xpix = app.skew_cell{app.iL(n)}.xpix+1;
                ind  = sub2ind(size(app.s), ypix, xpix);
                app.s(ind)=NaN;
            end
            
            %updating the image
            imageUpdate(app)

            %updating the variables
            variablesUpdate(app,app.iL)
      
            close(app.fig)
            
            
        end
        
        function varianceHigh(app)

            p70=prctile(app.variance,70);
            iH=app.variance>p70;
            s2pidx=app.skewfilt_idx(iH)-1;
            %varH=varianza(idxH);
            %skewH=app.skewlevel(iH);
            app.TextC.String = join(string(s2pidx)',','); 

        end
        
        function intrestingCells(app)
            
            j=findall(gca,'Type','Text');
            delete(j);
            
            idxs2p=str2double(split(app.TextC.String,','));
            indexes=idxs2p+1; %from suite2p to matlab indexing sys
            [~,indexes]=ismember(indexes,app.skewfilt_idx);
            traces=app.deltaFoFskew(indexes,:);
            coords=cell(length(indexes),3);
            for n=1:length(indexes)
                ypix = app.skew_cell{indexes(n)}.med(1); %without overlapping pixels
                xpix = app.skew_cell{indexes(n)}.med(2);
                coords{n,1}=double(xpix);
                coords{n,2}=double(ypix);
                coords{n,3}=num2str(idxs2p(n));
            end

            for n=1:length(indexes)
               app.txt(n)=text(coords{n,1},coords{n,2},coords{n,3},'Color','m','FontSize',8,'FontWeight','bold');
            end
            
            begindex=1;
            numFigures=1:10:length(indexes);
          
            for j=1:length(numFigures)
                figure
                endindex=j*10;
                if endindex>length(indexes)
                    endindex=length(indexes);
                end
                
                for i=begindex:endindex
                    trace=traces(i,:);
                    plot(app.t,trace+i-1)
                    hold on
                    text(app.t(ceil(length(app.t)/2)),i-1-0.5,coords{i,3},'Color','m','FontSize',8);    
                end
                begindex=endindex+1;
                xlabel('time[min]')
                ylabel('Fluorescence traces')
                
            end
            
        end

        function keepDeleteCells(app,kd)
            %if kd=0 i'm maintaining the cells indexed by the user 
            %if kd=1 i'm deleting the cells indexed by the user
            
            idxs2p=str2double(split(app.TextC.String,','));
            if ~isnan(idxs2p)
                indexes=idxs2p+1; %from suite2p to matlab indexing sys
                ismemb=ismember(app.skewfilt_idx,indexes); %need to pass from the cells I want to keep to one I want get rid off
                indexes=find(ismemb==kd); %indexes of cells I want to eliminate
                

                %image construction
                for n=1:length(indexes)
                    ypix = app.skew_cell{indexes(n)}.ypix+1; %without overlapping pixels
                    xpix = app.skew_cell{indexes(n)}.xpix+1;
                    ind  = sub2ind(size(app.s), ypix, xpix);
                    app.s(ind)=NaN;
                end
                
                imageUpdate(app)
                
                %updating variables
                variablesUpdate(app,indexes)

                app.TextC.String='#cell separated by a comma';
            
            end
            
            
        end
        
        function croppingFunction(app)
            croppedImg=cropArea(app.s);
            app.s=croppedImg;
            
            %image updating
            imageUpdate(app);
            
            %finding the indexes of the cropped cells
            croppedImg(~isnan(croppedImg))=1;
            imageMult=app.imageIdx.*croppedImg;
            imageMult(isnan(imageMult))=0;
            V = nonzeros(imageMult);
            matlabidx=unique(V);
            ismemb=ismember(app.skewfilt_idx,matlabidx); %need to pass from the cells I want to keep to one I want get rid off
            indexes=find(ismemb==0); %indexes of cells I want to eliminate
            
            variablesUpdate(app,indexes);
            
            
        end
        
        function printIdx(app,type)
            str=string(app.skewfilt_idx-1);
            str=join(str,',');
            if type==0
                app.TextC.String=str;
            else
                filename=append('MatlabResults/',extractBefore(app.fileName,'Fall.mat'),date,'IntrestingIndexes-',app.interval,'.txt');
                fid = fopen(filename,'wt');
                fprintf(fid, str);
                fclose(fid);
            end
            
        end
        
        function askCoefPeak(app)
            prompt={'Cutoff scaling coefficient value:'};
            name='Enter the cutoff';
            numlines=1;
            defaultanswer={'2'};
            answer=inputdlg(prompt,name,numlines,defaultanswer);  
            app.coeff=str2double(answer{1});
            peakTool(app)
        end
        
        function peakTool(app)
            app.indexesOrig={};
            app.peaksOrig={};
            app.TextC.String='#cell separated by commas';
            app.M=app.deltaFoFskew';
            numberOfCell=size(app.M,2);
            b=detrend(app.M);
            b=app.M-b;
            Mb=app.M-b;
            smoothed_m = conv2(Mb, ones(3)/20, 'same');
            diff=Mb-smoothed_m;
            p5  = prctile(diff,5); %5th percentile
            p95 = prctile(diff,95); %95th percentile to find the threshold
            
            for i=1:size(diff,2)
                signal=diff(:,i);
                intervallo=find(signal>p5(i) & signal<p95(i));
                m(1,i)=mean(signal(intervallo));
                stdev(1,i)=std(signal(intervallo));
            end
            Fcut=m+app.coeff*stdev;
            smooth = sgolayfilt(double(diff),7,21);

            for i=1:size(smooth,2)
                trace=smooth(:,i);
                [index,peak]=PeaksDetector(trace,Fcut(i));
                app.indexesOrig{i}=index/(app.fs*60);
                app.freq(i)=length(index)/app.t(end);   
            end
            
            app.indexesNew=app.indexesOrig;
            app.peaksNew=app.peaksOrig;
            saveStruct(app);
            
            %plot part, the j index controls the number of figures, in
            %which we have 4 subplot boxes regulated by k.
            %the i index controls the dFoFskew trace we are working on 
            plotPeaks(app,smooth)
        end
        
        function plotPeaks(app,smooth)
            i=1;
            for j=1:round(size(smooth,2)/4)

               figPeak=figure;

               for k=1:4
                    ax(k) = subplot(2,2,k);
                    trace=smooth(:,i);
                    h1=plot(app.t,trace);
                    hold on
                    app.peaksOrig{i}=trace(round(app.indexesOrig{i}*app.fs*60));
                    for id=1:length(app.indexesOrig{i})
                        PeaksList = plot(app.indexesOrig{i}(id),app.peaksOrig{i}(id),'*r');
                        set(PeaksList, 'ButtonDownFcn', {@deleteExistingPeak,i,PeaksList,app}); %delete an existing peak
                    end
                    h1.ButtonDownFcn = {@showZValueFcn,i,app}; %add a new peak
                    xlabel('time') 
                    ylabel('dF/F with peaks') 
                    i=i+1;
                    if i>size(smooth,2)
                        break
                    end
               end


               uicontrol('Parent',figPeak,'Style','pushbutton','String','SaveChanges',...
                         'Position',[1,1,100,20],'Units','normalized','Visible','on',...
                         'CallBack',@(src,event)savePeaks(app)); %CALLBACK FOR SAVING
            end
        end
        function savePeaks(app)
            %SUBSTITUTE THE ORIGINAL WITH THE NEW ONE ON WHICH THE
            %MODIFICATIONS HAD BEEN APPLIED
            app.peaksOrig=[];
            app.peaksOrig=app.peaksNew;
            app.indexesOrig=[];
            app.indexesOrig=app.indexesNew;
            saveStruct(app);
        end
        function saveStruct(app)
            %%SAVE PEAKS
            clear peak;
            peak.originalTraces=app.M;
            peak.indexes=app.indexesOrig;
            %peak.peaks=app.peaksOrig;
            
            
            save(app.fileName,'peak','-append');
            fprintf('peak saved')
        end
        
        function loadPeaks(app)
            try
                app.in.peak=load(app.fileName,'peak');
                app.indexesOrig=app.in.peak.peak.indexes;
                app.indexesNew=app.indexesOrig;
                app.peaksNew=app.peaksOrig;

            plotPeaks(app,app.in.peak.peak.originalTraces)
            catch e %e is an MException struct
                fprintf(1,'The identifier was:\n%s',e.identifier);
                fprintf(1,'There was an error! The message was:\n%s',e.message);
                app.TextC.String='No peaks founded, run PeakDetection';
            end

        end
        
        function findPeakSynch(app)
            PeaksFunction(app.fs,app.t,app.in.peak.peak.originalTraces,app.indexesOrig);
            correlationPeaks(app.in.peak.peak.originalTraces,app.indexesOrig);
        end
            
        
        function indietro(app,figHandler)
            app.ButtonI=uicontrol('Parent',figHandler,'Style','pushbutton','String','<<Restart',...
                'Position',[10,480,50,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonH,event)buttonIndietro(app,figHandler));
            app.ButtonHelp=uicontrol('Parent',figHandler,'Style','pushbutton','String','Help',...
                'Position',[60,480,50,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonH,event)openHelp('helpSwing.txt'));
        end
        
        function buttonIndietro(app,figHandler)
            close(figHandler)
            PlotSkew(app.path,app.fileName,app.correctionFactor,app.fs,app.interval);
        end
               
  end
    
    
end
