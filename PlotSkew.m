classdef PlotSkew <handle
    
    properties
        fileName            %'Fall.mat'
        correctionFactor    %alpha multiplicative factor for Fcorr=Fraw-alpha*Fneu
        in                  %input structure
        
        ButtonI             %back button
        
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
        
        hFig                %figure relative to the skewness panel
        fig                 %figure relative to the variance panel
        TextH               %text field for skewness level
        TextC               %text field for intresting cells
        txt                 %intresting indexes choosen by user
        ButtonH             %button for cell selection and plot
        ButtonC             %button for clustering
        ButtonV             %button for variance filtering
        ButtonVis           %button for visualizing cells
        ButtonK             %button for keeping just the selected cells
        
        clusters            %cell array containg the index of cells belonging to clusters
        variance            %variance values for each cell
        mantain             %indexes of cells the user wants to mantain after the variance filtering
        
        iL                  %indexes of cells with variance>percentile25
        iLs2p               %indexes according to suite2p metrics
    end
    
    methods
        
        function app=PlotSkew(fileName,correctionFactor)
            %fileName= 'Fall.mat' of the suite2p analysis you want
            %correctionFactor= input from the general GUI that needs to be
            %memorized globally and passed here, so here you don't have to
            %ask for a user input.
            app.correctionFactor=correctionFactor;
            app.fileName=fileName; %il nome è Fall.mat, è il file che contiene tutti gli output di suite2p
            app.in=load(fileName);
            app.iscell=app.in.iscell;
            
            app.deltaFoF=deltaFoverF(app.iscell,app.in.F,app.in.Fneu,correctionFactor);
            %inizializzazione deltaFoverFskew con il deltaFoF totale
            app.deltaFoFskew=app.deltaFoF;
            
            %indici delle cellule (suite2p indexes but 1 based)
            app.idx_cell=find(app.iscell(:,1)==1); %REMEMBER in suite2p the idx=idx_cell-1
            %init of the skewness filtered indexes to all the
            %cells indexes (in the suite2p coords but 1-based)
            app.skewfilt_idx=app.idx_cell;
            
            %stat delle sole cellule (stat of cells)
            app.stat_cell=app.in.stat(app.idx_cell);
            %init of the vector containing just the stat of the skewness
            %filtered cells to the one of all the suite2p had found
            app.skew_cell=app.stat_cell;
            
            %levels of skewness of each cell
            for s=1:length(app.stat_cell)
                app.skewlevel(1,s)=app.stat_cell{s}.skew;
            end
                
            
            app.initImage 
        end
        
        
        function initImage(app)
            
            [image,type]=createImage(app.fileName);
            
%             switch type
%                 case'cell masks'
%                     app.cells=image; %select cell masks
%                     showImage(app,app.cells);
%                 case 'neuropil masks'
%                     app.neu=image; %select neuropil masks
%                     showImage(app,app.neu);
%                 case 'skewness'
                    app.skew=image; %select skewness
                    app.s=image;
                    skewnessHandling(app)
%                     
%             end
            
            
        end
        
        
        function showImage(app,image)
            % %PLOTTING THE MASKS IN RANDOM COLORS
            f=figure;
            f.Position=[488,253,556.8,500];
            indietro(app,f);
            mymap=[[1,1,1];hsv;[0,0,0]];
            imshow(image,'Colormap',mymap)
        end

        
        function skewnessHandling(app)
            %PLOTTING THE SKEWNESS IMAGE
            app.hFig=figure(2);
            app.hFig.Name= 'Swing Cells Experiment';
            
            mymap=[[1 1 1];jet];
            maxSkew=round(max(max(app.skew)));
            middle=maxSkew/2;
            imp=isnan(app.skew)==0;
            imp=bwperim(imp);
            i=imp==1;
            app.skew(i)=app.skew(i)-0.5;
            imshow(app.skew, 'Colormap',mymap);
            hcb=colorbar('Ticks',[-2,1,middle],'TickLabels',{'-2','1',mat2str(middle)});
            set(get(hcb,'Title'),'String','Skewness')
            caxis([-2 middle]) 
            
            addComponents(app)
            
        end
        
        function addComponents(app)
            %button to come back to the principal question box
            indietro(app,app.hFig);
            
            %text area for cell selection
            app.TextC=uicontrol('Parent',app.hFig,'Style','edit','Visible','on',...
                'Position',[10,450,140,20],'String','#cell separated by a space','Units','Normalized');
                
            app.ButtonVis=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Visualize',...
                'Position',[10,430,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonVis,event)intrestingCells(app));
            
            app.ButtonK=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Keep this cells',...
                'Position',[10,410,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonK,event)keepCells(app));

            %Add text area for skewness level
            app.TextH=uicontrol('Parent',app.hFig,'Style','edit','Visible','on',...
                'Position',[10,20,100,20],'String','Skewness level','Units','Normalized',...
                'CallBack',@(TextH,event) textChanged(app));

            %Add button for selecting cells
            app.ButtonH=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Select Cells',...
                'Position',[120,20,60,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonH,event)buttonPressed(app.hFig,app.ButtonH,app.skew_cell,app.deltaFoFskew,app.skewfilt_idx));

            %Add button for clustering
            app.ButtonC=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Clustering','Position',[200,20,60,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)clusteringButton(app));
            
            %Add button for variance low filtering
            app.ButtonV=uicontrol('Parent',app.hFig,'Style','pushbutton','String','Variance filtering','Position',[280,20,100,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)varianceFunct(app));
        end
        
        function textChanged(app)
            %textChanged callback function for the text field dedicated to the
            %skewness level.
            levelSkew=str2double(app.TextH.String);

            %in skewfilt_idx inserisco gli indici delle cellule filtrate per
            %la skewness indicata dall'utente.
            app.skewfilt_idx=[];
            
            %in skewlevel inserisco il valore di skewness delle cellule
            %filtrate
            app.skewlevel=[];
            
            for i=1:length(app.stat_cell)
                if app.stat_cell{1,i}.skew>levelSkew
                   app.skewfilt_idx=[app.skewfilt_idx,i]; 
                   app.skewlevel=[app.skewlevel;app.stat_cell{1,i}.skew];
                end
            end
            app.deltaFoFskew=app.deltaFoF(app.skewfilt_idx,:);
            app.skew_cell=app.stat_cell(1,app.skewfilt_idx); %stat delle cellule filtrate per skewness
            app.skewfilt_idx=app.idx_cell(app.skewfilt_idx,1); %idx of the suite2p file filtered through skewness


            %image construction
            app.s(app.s<=levelSkew)=NaN;
            figure(app.hFig.Number)
            axes=gca(app.hFig);
            imh = imhandles(axes); %gets your image handle if you dont know it
            set(imh,'CData',app.s);

            colorbar%('Ticks',[levelSkew,2.5],'TickLabels',{txt.String,'2.5'});
            %set(get(c,'Title'),'String','Skewness')
            caxis([levelSkew 2.5]) 

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
            buttonA=uicontrol('Parent',panel2,'Style','pushbutton','Visible','on','Position',[10,1220,60,20],...
                            'String','Filter cells',...
                            'CallBack',@(buttonA,event) discardTraces(app,textA));
            set(panel1,'Position',[0 0 0.95 1]);
            set(panel2,'Position',[0 -1 1 2]);
            set(gca,'Parent',panel2);
            A=app.deltaFoFskew(app.iL,:); %signals with low variance
            for i=1:size(A,1)
                sign=A(i,:)+i;
                plot(sign); 
                hold on
                x=round(length(sign)/3); y=i;
                text(x,y,num2str(app.iLs2p(i,:))); %plotting the suite2p index on every trace
            end
            ylim([0 size(A,1)+2]);

            %slider component
            uicontrol('Style','Slider','Parent',app.fig,...
                  'Units','normalized','Position',[0.95 0 0.05 1],...
                  'Value',1,'Callback',{@slider_callback1,panel2});
               
            %callback to scroll up/down
            function slider_callback1(src,eventdata,arg1)
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
                ypix = app.skew_cell{app.iL(n)}.ypix(app.skew_cell{app.iL(n)}.overlap==0)+1; %without overlapping pixels
                xpix = app.skew_cell{app.iL(n)}.xpix(app.skew_cell{app.iL(n)}.overlap==0)+1;
                ind  = sub2ind(size(app.s), ypix, xpix);
                app.s(ind)=NaN;
            end
            axes=gca(app.hFig);
            imh = imhandles(axes); %gets your image handle
            set(imh,'CData',app.s);
            
            %update of the variables
            app.skewfilt_idx(app.iL)=[];
            app.deltaFoFskew(app.iL,:)=[]; 
            app.skew_cell(app.iL)=[];
            app.skewlevel(app.iL)=[];
            close(app.fig)
            
            
        end
        
        function varianceHigh(app)

            p80=prctile(app.variance,80);
            iH=app.variance>p80;
            s2pidx=app.skewfilt_idx(iH)-1;
            %varH=varianza(idxH);
            %skewH=app.skewlevel(iH);
            app.TextC.String= join(string(s2pidx)',' '); 

        end
        
        function intrestingCells(app)
            delete(app.txt);
            app.txt=[];
            idxs2p=str2double(split(app.TextC.String,' '));
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
                    plot(trace+i)
                    hold on
                    text(length(trace)/2,i,coords{i,3},'Color','m','FontSize',8);
                    
                end
                begindex=endindex+1;
            end
        end

        function keepCells(app)
            
            idxs2p=str2double(split(app.TextC.String,' '));
            if ~isnan(idxs2p)
                indexes=idxs2p+1; %from suite2p to matlab indexing sys
                ismemb=ismember(app.skewfilt_idx,indexes); %need to pass from the cells I want to keep to one I want get rid off
                indexes=find(ismemb==0); %indexes of cells I want to eliminate


                %image construction
                for n=1:length(indexes)
                    ypix = app.skew_cell{indexes(n)}.ypix(app.skew_cell{indexes(n)}.overlap==0)+1; %without overlapping pixels
                    xpix = app.skew_cell{indexes(n)}.xpix(app.skew_cell{indexes(n)}.overlap==0)+1;
                    ind  = sub2ind(size(app.s), ypix, xpix);
                    app.s(ind)=NaN;
                end
                axes=gca(app.hFig);
                imh = imhandles(axes); %gets your image handle
                set(imh,'CData',app.s);

                %updating variables
                app.skewfilt_idx(indexes)=[];
                app.deltaFoFskew(indexes,:)=[]; 
                app.skew_cell(indexes)=[];
                app.skewlevel(indexes)=[];

                app.TextC.String='#cell separated by a space';
            end
            
            
        end
        
        function indietro(app,figHandler)
            app.ButtonI=uicontrol('Parent',figHandler,'Style','pushbutton','String','<<Back',...
                'Position',[10,480,60,20],'Units','normalized','Visible','on',...
                'CallBack',@(ButtonH,event)buttonIndietro(app,figHandler));
        end
        
        function buttonIndietro(app,figHandler)
            close(figHandler)
            PlotSkew(app.fileName,app.correctionFactor);
        end
  end
    
    
end