classdef DrugClass <handle
   
    properties
        
        Figure
        PanelConfig
        PanelCalibration
        CalibrationClass
        
        ax
        ax2
        
        type %m because i'm searching for mat files
        
        txaB
        
        file
        path
        tF
        tL
        start
        stop
        in
        idx_cell %defined in MenuSelection
        IDX
        Line
        deleted
        help
     
        fs
        fsField
        
        correctionFactor
        alphaField
        deltaFoF
        deltaFoFCut
        t
        typePB %type of photobleaching correction

        order
        filterField
        
        cut
        cutL
        cutH
        cutField
        
        calibrationValueL
        calibrationValueH
        calibrationField
        
        runButton
        restartButton
        
        photob
        YPhotoBleach
        
        saveButton
        dfUp
        dfDown
        dfMiddle
        time
        interval

        buttonDelete
        
        
        indexesExcited
        indexesInhibited
        indexesNoResp
        
        idxPlot
        
        logFile
    end
    
    methods
    
        function app=DrugClass
            
            %costruttore
            app.logFile='logMatlab.txt';
            app.typePB='noCorrection';
            app.type='m';
            app.Figure=uifigure('Name','Drug Application Experiment');
            app.Figure.Position=[115   221   1300   530];
            gB=uigridlayout(app.Figure,[2 3]);
            gB.ColumnWidth={210,'1x','1x'};
            gB.RowHeight={90,'1x'};
            
            configPanel(app,gB)
            
            calibrationPanel(app,gB)
            
            allPanelConfig(app,gB)


        end
    
        function calibrationPanel(app,gB) %pannello deltaFoF
            app.PanelCalibration=uipanel(gB,'Title','Calibration');
            app.PanelCalibration.Layout.Column=1;
            app.PanelCalibration.Layout.Row=1;
            grid2 = uigridlayout(app.PanelCalibration,[2 1]);
            buttont=uibutton(grid2,'Text','Global dFoF (tif file)');
            buttont.ButtonPushedFcn=@(src,event)globalDelta(app); %tif selection for global dfoverf 
            buttonc=uibutton(grid2,'Text','Calibration');
            buttonc.ButtonPushedFcn=@(src,event)calibrationFunction(app);
        end
            
        function calibrationFunction(app)
            app.CalibrationClass=Calibration;
        end
        
        function configPanel(app,gB) %Pannello Config
           
           app.PanelConfig = uipanel(gB,'Title','Configuration');
           app.PanelConfig.Layout.Column=1;
           app.PanelConfig.Layout.Row=2;
           
           % Grid in the panel
           grid2 = uigridlayout(app.PanelConfig,[12 2]);
           grid2.RowHeight = {20,20,20,20,20,20,20,20,20,20,20,'1x'};
           grid2.ColumnWidth = {140,'1x'};

           %Buttons for file and directory selection
           buttonf = uibutton(grid2,'Text','Import .mat file');
           buttonf.ButtonPushedFcn = @(src,event)MenuSelection(app,'m',buttonf);
           buttonf.Layout.Row=1;
           buttonf.Layout.Column=[1,2];
           
           % frequency Label
           fsLabel=uilabel(grid2,'HorizontalAlignment','right','Text','samplig rate [Hz]');
           fsLabel.Layout.Row=2;
           fsLabel.Layout.Column=1;
           
           % frequency edit field
           app.fsField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(app,'fs'));
           app.fs=1;
           app.fsField.Value = 1;
           
           % alpha Label
           alphaLabel=uilabel(grid2,'HorizontalAlignment','right','Text','neuropil correction factor');
           alphaLabel.Layout.Row=3;
           alphaLabel.Layout.Column=1;
           
           % alpha edit field
           app.alphaField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(app,'a'));
           app.correctionFactor=0.7;
           app.alphaField.Value = 0.7;
          
           %LP Label
           LPLabel=uilabel(grid2,'HorizontalAlignment','right','Text','LP filter order');
           LPLabel.Layout.Row=4;
           LPLabel.Layout.Column=1;
           
           % LP edit field
           app.filterField=uieditfield(grid2,'numeric');
           app.filterField.ValueChangedFcn=@(src,event)takeValue(app,'o');
           app.order = 5;
           app.filterField.Value = 5; 
           
           % cutLabel
           cutLabel=uilabel(grid2,'HorizontalAlignment','right','Text','cut treshold [delta]');
           cutLabel.Layout.Row=5;
           cutLabel.Layout.Column=1;
           % cut editField
           app.cutField=uieditfield(grid2,'ValueChangedFcn',@(src,event)takeValue(app,'c'));
           app.cutField.Layout.Row=5;
           app.cutField.Layout.Column=2;
           app.cutL=-2;
           app.cutH=5;
           app.cutField.Value = '-2,5';
           
           % calibrationLabel
           calibrationLabel=uilabel(grid2,'HorizontalAlignment','right','Text','hist extremes');
           calibrationLabel.Layout.Row=6;
           calibrationLabel.Layout.Column=1;
           
           
           
           % calibration editField
           app.calibrationField=uieditfield(grid2,'ValueChangedFcn',@(src,event)takeValue(app,'hist'));
           app.calibrationField.Layout.Row=6;
           app.calibrationField.Layout.Column=2;
           app.calibrationValueH=8;
           app.calibrationValueL=-3;
           app.calibrationField.Value = '-3,8';
           
           %histogram
           histButton=uibutton(grid2,'Text','histogram','ButtonPushedFcn',@(src,event)istogramma(app));
           histButton.Layout.Row=7;
           histButton.Layout.Column=[1,2];
            
           %PHOTOBLEACHING Button
           app.photob=uibutton(grid2,'Text','Correct Photobleaching');
           app.photob.ButtonPushedFcn = @(src,event)Photobleaching(app);
           app.photob.Layout.Row=8;
           app.photob.Layout.Column=[1,2];
           
           % RUN
           app.runButton=uibutton(grid2,'Text','RUN');
           app.runButton.Layout.Row=9;
           app.runButton.Layout.Column=[1,2];
           app.runButton.ButtonPushedFcn=@(btn,event)RunFunction(app);
           
           %RESTART
           app.restartButton=uibutton(grid2,'Text','RESTART');
           app.restartButton.Layout.Row=10;
           app.restartButton.Layout.Column=[1,2];
           app.restartButton.ButtonPushedFcn=@(btn,event)RestartFunction(app);
          
           
           %SAVE
           app.saveButton=uibutton(grid2,'Text','Save data');  
           app.saveButton.ButtonPushedFcn = @(src,event)saveFiles(app);
           
           %HELP BUTTON
           app.help=uibutton(grid2,'Text','Help');
           app.help.ButtonPushedFcn = @(src,event)openHelp('helpDrug.txt');
           
           %TEXT AREA
           app.txaB=uitextarea(grid2,'Editable','off');
           app.txaB.Layout.Row=12;
           app.txaB.Layout.Column=[1,2];
           
           
       
        end
        
        function allPanelConfig(app,gB)
            
            p=uipanel(gB);
            p.Layout.Column=2;
            p.Layout.Row=[1,2];
            app.ax = axes(p);
            
            p2=uipanel(gB);
            p2.Layout.Column=3;
            p2.Layout.Row=[1,2];
            app.ax2 = axes(p2);
            
            app.buttonDelete=uibutton(p2,'Text','Delete Trace','Position',[2,2,200,20]);
            app.buttonDelete.ButtonPushedFcn = @(src,event)deleteTrace(app);
            
            buttonVisualizeExc=uibutton(p2,'Text','E','Position',[220,2,20,20]);
            buttonVisualizeExc.ButtonPushedFcn = @(src,event)visualizeTrace(app,'E');
            
            buttonVisualizeInh=uibutton(p2,'Text','I','Position',[250,2,20,20]);
            buttonVisualizeInh.ButtonPushedFcn = @(src,event)visualizeTrace(app,'I');
            
            buttonVisualizeNoR=uibutton(p2,'Text','NR','Position',[280,2,25,20]);
            buttonVisualizeNoR.ButtonPushedFcn = @(src,event)visualizeTrace(app,'NR');
            
            
          
        end
        
        function takeValue(app,label)
            %INPUTS: app,label
            %labels: 'fs'(frequency) 'a'(alpha field)
            %         'o'(order)      'c' (cut levels Low and High) 
            %         'hist'(histogram levels) 
            switch label
                case 'fs'
                    app.fs=app.fsField.Value;
                case 'a'
                    app.correctionFactor=app.alphaField.Value;
                case 'o'
                    app.order=app.filterField.Value;
                case 'c'
                    v=split(app.cutField.Value,',');
                    app.cutL=str2double(v{1});
                    try
                        app.cutH=str2double(v{2});
                    catch
                        if app.cutL<0
                            app.cutH=-app.cutL;
                        else
                            app.cutH=app.cutL;
                            app.cutL=-app.cutH;
                        end
                            format long
                            app.cutField.Value=sprintf('%.1f,%.1f',app.cutL,app.cutH);
                    end
                case 'hist'
                    v=split(app.calibrationField.Value,',');
                    app.calibrationValueL=str2double(v{1});
                    app.calibrationValueH=str2double(v{2});
            end
         
        end
    
        function deleteTrace(app)
            
            Midx=app.idx_cell(app.IDX);
            s2pidx=Midx-1;
            app.deleted=[app.deleted,s2pidx];
            app.in.iscell(Midx,1)=0; %cancello la cellula 
            app.idx_cell(app.IDX)=[]; 
            PostSuite2pStim(app,app.fs,app.correctionFactor,app.order,app.ax,app.ax2);
            
            h=app.saveButton;
            set(h,'backg',[1 .6 .6]);
            title('All cells dF/F traces','Parent',app.ax2)
            
        end
     
    
        function saveFiles(app)
            
            if ~exist('MatlabResults', 'dir')
                mkdir('MatlabResults')
                sprintf('MatlabResults folder created')
            end
            
            %salvataggio
            col=get(app.runButton,'backg');
            set(app.saveButton,'backg',[0,1,0]);
            
            
            %EXPORT DELLE IMMAGINI
            Fig2=figure();
            set(Fig2, 'Visible', 'off');
            copyobj(app.ax,Fig2);
            
            date=char(datetime('now'));
            date= regexprep(date, ':+', '');
            date= regexprep(date, ' +', '-');
            subDir=append('MatlabResults/',date);
            mkdir(subDir);
            title=append(subDir,'/','Groups.png');
            print(Fig2,title,'-dpng','-r300')
            
            m=[app.dfUp;app.dfMiddle;app.dfDown;app.time;app.interval]';
            
            iscell=app.in.iscell;
            save('Fall.mat','iscell','-append');
            
            title=append(subDir,'/','deletedCells.txt');
            writematrix(app.deleted,title);
            
            title=append(subDir,'/','Exc-NoResp-Inh-t-01.txt');
            writematrix(m,title);
            
            set(app.saveButton,'backg',col);
            
            title=append(subDir,'/','Excited.txt');
            writematrix(app.deltaFoF(app.indexesExcited,:)',title);
            
            title=append(subDir,'/','NoResponse.txt');
            writematrix(app.deltaFoF(app.indexesNoResp,:)',title);
            
            title=append(subDir,'/','Inhibited.txt');
            writematrix(app.deltaFoF(app.indexesInhibited,:)',title);
            
        end
        
        
        function visualizeTrace(app,type)
            
            M=[];
            suite2p=[];
            
            switch type
                case 'E'
                    M=app.deltaFoFCut(app.indexesExcited,:);
                    suite2p=find(app.indexesExcited==1);
                    
                case 'I'
                    M=app.deltaFoFCut(app.indexesInhibited,:);
                    suite2p=find(app.indexesInhibited==1);
                case 'NR'
                    M=app.deltaFoFCut(app.indexesNoResp,:);
                    suite2p=find(app.indexesNoResp==1);
            end
            
            if length(suite2p)>0
                suite2p=app.idx_cell(suite2p)-1;

                hFig=figure();
                axes=gca;
                app.idxPlot=1;

                plot(M(app.idxPlot,:))
                %text(1,double(mean(M(app.idxPlot,:))),num2str(suite2p(1)))
                ylabel('dFoF')
                xlabel('sample')
                title(sprintf('idx:%d   | %d/%d',suite2p(1),app.idxPlot,size(M,1)))

                ButtonForward=uicontrol('Parent',hFig,'Style','pushbutton','String','>',...
                'Position',[30,2,20,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)forward(app,M,suite2p,axes));

                ButtonBack=uicontrol('Parent',hFig,'Style','pushbutton','String','<',...
                'Position',[2,2,20,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)back(app,M,suite2p,axes));            
            end
  
        end
        
        
        function forward(app,M,suite2p,axes)
            app.idxPlot=app.idxPlot+1;
            
            if app.idxPlot>size(M,1)
                app.idxPlot=1;
            end
            
                
                plot(M(app.idxPlot,:),'Parent',axes)
                %text(1,double(mean(M(app.idxPlot,:))),num2str(suite2p(app.idxPlot)))
                ylabel('dFoF')
                xlabel('sample')
                title(sprintf('idx:%d   | %d/%d',suite2p(app.idxPlot),app.idxPlot,size(M,1)))
       
        end
        
        function back(app,M,suite2p,axes)
            app.idxPlot=app.idxPlot-1;
            
            if app.idxPlot<1
                app.idxPlot=1;
            end
         
            plot(M(app.idxPlot,:),'Parent',axes)
            %text(1,double(mean(M(app.idxPlot,:))),num2str(suite2p(app.idxPlot)))
            ylabel('dFoF')
            xlabel('sample')
            title(sprintf('idx:%d   | %d/%d',suite2p(app.idxPlot),app.idxPlot,size(M,1)))
        end
        
        function RunFunction(app)
            
            app.in=load(app.path);
            app.idx_cell=find(app.in.iscell(:,1)==1);
            fprintf('Length:%d',length(app.in.F))
            
            try
                %m(app.in.elimDuringCalib)=[]; %discarding the excluded cells
                nElim=length(app.in.elimDuringCalib); %number of excluded cells
                

                figure
                idxs2p=app.idx_cell(app.in.elimDuringCalib)-1;
                for i=1:length(app.in.elimDuringCalib)
                    sign=app.in.F(app.in.elimDuringCalib(i),:);
                    timeL=0/app.fs:1/app.fs:(length(sign)-1)/app.fs;
                    timeL=timeL/60;
                    plot(timeL,sign+1000*i);
                    hold on
                    text(1,double(mean(sign(1:100))+1000*i),num2str(idxs2p(i)));
                end
                title('F of the cells deleted during calibration')
                xlabel('time')
                ylabel('F trace')

                app.in.iscell(app.in.elimDuringCalib,:)=0;
                 
                for i =1:length(app.in.elimDuringCalib)
                   s=zeros(size(app.idx_cell));
                   s(app.in.elimDuringCalib(i):end)=1;
                   app.idx_cell=app.idx_cell+s;
                end
                app.idx_cell=find(app.in.iscell(:,1)==1);
                    
            catch
                disp('No eliminated traces during calibration')
            end
            
            
            TimePointsCustomization(app); %Here app.tF and app.tL are choosen
            PostSuite2pStim(app,app.fs,app.correctionFactor,app.order,app.ax,app.ax2);
            
        end
        
        function RestartFunction(app)
           
            PostSuite2pStim(app,app.fs,app.correctionFactor,app.order,app.ax,app.ax2);
            
        end
        
        function globalDelta(app)
            MenuSelection(app,'f');
            globalDeltaFromTiff(app.file);
        end
    
    end
end