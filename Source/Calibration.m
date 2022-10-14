classdef Calibration <handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tStart              %starting point of the calibration process
        tK                  %start of the potassium application
        tStop               %stop of the calibration process
        fs                  %sampling frequency
        t                   %time
        inclination         %minumun inclination
        correctionFactor    %for neuropil correction FIXED TO 0.7
        order               %for neuropil correction FIXED TO 100
        in          %inputs
        idx_cell    %indexes of cells (matlab)
        file
        path
        
        
        
        bg
        fig
        
        dFoF
        soglie
        indWS
        indWNS
        indSlope
        indNSlope
        positive %the one considered for the threshold extraction
        negative %the inhibited cells
        
        %these indexes are used just for the one-by-one representation, in
        %order to be able to visualize the selected or the discarded
        %indexes indipendently by the user choosen method (through the radio buttons) 
        %The selection methods work on the positive traces (no inhibited ones are took
        %in consideration for computing the positive excitation threshold).
        %therefore the length(idx_cell) is not always the sum of Selected
        %and Not Selected indexes, as in the idx_cell we have the eventually inhibited
        %indexes, thus length(idx_cell)could be >= length(idxNS)+length(idxS)
        idxNS %indexes Not selected in this moment (can be the Wikoxon or the Slope)
        idxS %indexes selected in this moment (can be Wilcoxon or the Slope)
        indIN %indexes of the inhibited cells
        
        Figure
        txaB
        
        PanelConfig
        tStartField
        tKField
        tStopField
        fsField
        inclinationField
        idxField
        
        PanelOutput
        
        PanelTrace
        idxUser     %indexes selected by user for visualization (suite2p)
        idxMatlab   %indexes selected by user in matlab coordinates
        ax
        
        idxPlot
       
        
        logFile
    end
    
    methods
        function obj = Calibration
            %Calibration Construct an instance of this class
            %Detailed explanation goes here
            
            obj.correctionFactor=0.7;
            %obj.order=10; %% va modificato in funzioneSoglia
            
            obj.logFile='logMatlab.txt';
            
            obj.Figure=uifigure('Name','Calibration');
            obj.Figure.Position=[115   321   1000   330];
            gB=uigridlayout(obj.Figure,[1 2]);
            gB.ColumnWidth={'1x','2x'};           
            initializePanels(obj,gB)
            
        end
        
        
        function initializePanels(obj,gB)
           obj.PanelConfig = uipanel(gB,'Title','Configuration');
           obj.PanelConfig.Layout.Column=1;
           obj.PanelConfig.Layout.Row=1;
           grid2 = uigridlayout(obj.PanelConfig,[7 2]);
           grid2.RowHeight = {'1x','1x','1x','1x','1x','1x','1x'};
           grid2.ColumnWidth = {'1x','1x'};
           initializePanelConfig(obj,grid2) 

           
           obj.PanelOutput=uipanel(gB);
           obj.PanelOutput.Layout.Column=2;
           obj.PanelOutput.Layout.Row=1;
           grid4 = uigridlayout(obj.PanelOutput,[8 2]);
           grid4.ColumnWidth = {'2x','1x'};
           grid4.RowHeight = {'4x','1x','1x','1x','1x','1x'};
           initializePanelOutput(obj,grid4) 
        end  
           
        function initializePanelConfig(obj,grid2)
            
           buttonf = uibutton(grid2,'Text','Import .mat file');
           buttonf.ButtonPushedFcn = @(src,event)fileSelection(obj);
           buttonf.Layout.Row=1;
           buttonf.Layout.Column=[1,2];
            
           % tStart Label
           tStartLabel=uilabel(grid2,'HorizontalAlignment','left','Text','tStart [sample]');
           tStartLabel.Layout.Row=2;
           tStartLabel.Layout.Column=1;
           % tStart edit field
           obj.tStartField=uieditfield(grid2,'ValueChangedFcn',@(src,event)takeValue(obj,'start'));
           obj.tStartField.Value = 'A'; %automatico
           obj.tStart='A';
           
           
           % tK Label
           tKLabel=uilabel(grid2,'HorizontalAlignment','left','Text','tK [sample]');
           tKLabel.Layout.Row=3;
           tKLabel.Layout.Column=1;
           % tK edit field
           obj.tKField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(obj,'k'));
           obj.tK=100;
           obj.tKField.Value = 100;
           
           % tStop Label
           tStopLabel=uilabel(grid2,'HorizontalAlignment','left','Text','tStop [sample]');
           tStopLabel.Layout.Row=4;
           tStopLabel.Layout.Column=1;           
           % tStop edit field
           obj.tStopField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(obj,'stop'));
           obj.tStop=200;
           obj.tStopField.Value = 200;
           
           % frequency Label
           fsLabel=uilabel(grid2,'HorizontalAlignment','left','Text','samplig rate [Hz]');
           fsLabel.Layout.Row=5;
           fsLabel.Layout.Column=1;
           % frequency edit field
           obj.fsField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(obj,'fs'));
           obj.fs=1;
           obj.fsField.Value = 1;
           
           % inclination Label
           inclinationLabel=uilabel(grid2,'HorizontalAlignment','left','Text','inclination [°]');
           inclinationLabel.Layout.Row=6;
           inclinationLabel.Layout.Column=1;
           % inclination edit field
           obj.inclinationField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(obj,'i'));
           obj.inclination=0.1;
           obj.inclinationField.Value = 0.1;
           
           %run button
           runButton=uibutton(grid2,'Text','RUN', 'ButtonPushedFcn',@(src,event)funzioneSoglia(obj)); 
           runButton.Layout.Row=7;
           runButton.Layout.Column=[1,2];
           
           
        end
        
        
        function initializePanelOutput(obj,grid)
            
           %text area
           obj.txaB=uitextarea(grid);
           obj.txaB.Layout.Row=[1,8];
           obj.txaB.Layout.Column=1;
           
           obj.bg = uibuttongroup(grid,'SelectionChangedFcn',@(src,event)radioButtonChanged(obj));
           obj.bg.Layout.Row=1;
           obj.bg.Layout.Column=2;
           rb1 = uiradiobutton(obj.bg,'Position',[10 50 91 15]);
           rb2 = uiradiobutton(obj.bg,'Position',[10 30 91 15]);
           rb3 = uiradiobutton(obj.bg,'Position',[10 10 91 15]);
           rb1.Text = 'cutMedian';
           rb2.Text = 'cutWilcoxon';
           rb3.Text = 'cutSlope';
           
           confirmButton=uibutton(grid,'Text','Confirm cut method','ButtonPushedFcn', @(src,event)radioButtonValue(obj));
           confirmButton.Layout.Column=2;
           confirmButton.Layout.Row=2;
           
           onebyoneButtonM=uibutton(grid,'Text','o-by-o maintained','ButtonPushedFcn', @(src,event)visualizeOBO(obj,'M'));
           onebyoneButtonM.Layout.Column=2;
           onebyoneButtonM.Layout.Row=4;
           
           onebyoneButtonD=uibutton(grid,'Text','o-by-o discarded','ButtonPushedFcn', @(src,event)visualizeOBO(obj,'D'));
           onebyoneButtonD.Layout.Column=2;
           onebyoneButtonD.Layout.Row=5;
           
           onebyoneButtonINH=uibutton(grid,'Text','o-by-o inhibited','ButtonPushedFcn', @(src,event)visualizeOBO(obj,'I'));
           onebyoneButtonINH.Layout.Column=2;
           onebyoneButtonINH.Layout.Row=6;
           
           obj.idxField=uieditfield(grid,'Value','cell idx separated by commas');
           obj.idxField.Layout.Column=2;
           obj.idxField.Layout.Row=7;
           idxButton=uibutton(grid,'Text','Visualize','ButtonPushedFcn', @(src,event)visualizeTraces(obj));
           idxButton.Layout.Column=2;
           idxButton.Layout.Row=8;
           
            
        end
        
        
        
        function takeValue(obj,label)
            switch label
                case 'fs'
                    obj.fs=obj.fsField.Value;
                case 'start'
                    obj.tStart=str2double(obj.tStartField.Value);
                case 'stop'
                    obj.tStop=obj.tStopField.Value;
                case 'k'
                    obj.tK=obj.tKField.Value;
                case 'i'
                    obj.inclination=obj.inclinationField.Value;
                case 'idx'
                    idx=split(obj.idxField.Value);
                    idx=cell2mat(idx);
                    obj.idxUser=str2num(idx); %suite2p indexes
                    obj.idxMatlab=obj.idxUser+1;
            end
        end

        function visualizeTraces(obj)
            takeValue(obj,'idx');
            idx=obj.idxUser+1;  %from suite2p to matlab indexing sys
            [~,idx]=ismember(idx,obj.idx_cell);
            obj.t=obj.tStart/obj.fs:1/obj.fs:obj.tStop/obj.fs;
            obj.t=obj.t/60;
            
            figure
            for i=1:length(idx)
                plot(obj.t,obj.dFoF(idx(i),obj.tStart:obj.tStop)+i-1)
                hold on
                text(obj.t(1),i-1,num2str(obj.idxUser(i)))
            end
            
        end
        
        function fileSelection(obj)
                
               %calibration
               [obj.file,obj.path]=uigetfile('*.mat','MultiSelect','off');
                
                try
                    obj.txaB.Value={'File name:';obj.file;'Path name:';obj.path};
                    cd(obj.path);
                    obj.path=append(obj.path,'\',obj.file);
                    obj.in=load(obj.path);
                    obj.idx_cell=find(obj.in.iscell(:,1)==1);

                catch
                    obj.txaB.Value='NO FILE SELECTED';
                end
                
                
        end
           
        function funzioneSoglia(obj)
            
           if obj.tStartField.Value=='A'
               obj.tStart=double(obj.tK-(obj.tStop-obj.tK)); %automatic assessment 
               v=sprintf('%d',obj.tStart);
               obj.tStartField.Value = v; %automatico

               else 
                   takeValue(obj,'start');
           end
           
           obj.in=load(obj.path);
           obj.idx_cell=find(obj.in.iscell(:,1)==1);
           
           takeValue(obj,'stop');
           takeValue(obj,'k');
           obj.order=10;
           obj.in.F=obj.in.F(:,obj.tStart:obj.tStop);
           obj.in.Fneu=obj.in.Fneu(:,obj.tStart:obj.tStop);
           obj.tStop=obj.tStop-obj.tStart+1;
           obj.tK=obj.tK-obj.tStart+1;
           
           
           obj.tStart=obj.tStart-obj.tStart+1;
           
           obj.dFoF=deltaFoverF(obj.in.iscell,obj.in.F,obj.in.Fneu,obj.correctionFactor,obj.order,obj.tK);
           [obj.soglie,obj.indWS,obj.indWNS,obj.indSlope,obj.indNSlope, obj.positive,obj.negative]=sceltaSoglie(obj.fs,obj.correctionFactor,obj.order,obj.tStart,obj.tK,obj.tStop,obj.dFoF);
           %gli indici che ottengo sono riferiti a dFoF, quindi sono quelli
           %di idx_cell, perciò obj.indWS=9 significa che sto prendendo il
           %9° elemento del vettore dFoF, e quindi il 3°elemento di
           %idx_cell, che non per forza è 3, ma potrebbe essere un indice
           %diverso (perché magari in posizione 2 e 3 di iscell avevo un 0)
           %ex: iscell=[1, 0.899; 0 0.7999; 0 0.675; 1 0.7892; 1 0.654]
           %quindi idx_cell=[1 4 5 6 7 8 9 10 11] qui idx_cell(3)=5.
           obj.txaB.Value=sprintf('-cutMedian: %0.5f \n-cutWilcoxon: %0.5f \n-cutSlope: %0.5f\nPath: %s',obj.soglie(1),obj.soglie(2),obj.soglie(3),obj.path);
           
            date=char(datetime('now'));
            date= regexprep(date, ':+', '');
            date= regexprep(date, ' +', '-');
           
           if exist(obj.logFile,'file')==2
               fileID=fopen(obj.logFile,'a'); % open exist file and append contents
               fprintf(fileID,'\nCalibration RUN %s\n',date);
               fprintf(fileID,'fs=%d\n',obj.fs);
               fprintf(fileID,'tStart %s - tK %d - tStop %d\n',obj.tStartField.Value, obj.tKField.Value, obj.tStopField.Value);
               fprintf(fileID,'-cutMedian: %0.5f \n-cutWilcoxon: %0.5f \n-cutSlope: %0.5f\n',obj.soglie(1),obj.soglie(2),obj.soglie(3));
           else
               fileID=fopen(obj.logFile,'w'); % create file and write to it
               fprintf(fileID,'\nCalibration RUN %s\n',date);
               fprintf(fileID,'fs=%d\n',obj.fs);
               fprintf(fileID,'tStart %s - tK %d - tStop %d\n',obj.tStartField.Value, obj.tKField.Value, obj.tStopField.Value);
               fprintf(fileID,'-cutMedian: %0.5f \n-cutWilcoxon: %0.5f \n-cutSlope: %0.5f\n',obj.soglie(1),obj.soglie(2),obj.soglie(3));
           end
           fclose('all');
           
           %default for o-by-o visualization
           obj.idxS=1:1:size(obj.dFoF,1);%as default we use the Median approach, which is the already selected choice in radio button group
           obj.idxS(obj.negative)=[];
           obj.idxNS=[]; %the median does not discard any trace
           %the obj.negative is the same for all
        
        end
        
        
        function radioButtonChanged(obj)
           
            text=obj.bg.SelectedObject.Text;
            
            switch text
                case 'cutMedian'
                      obj.idxS=1:1:size(obj.dFoF,1);%all the indexes, because the median approach does not discard any trace
                      obj.idxS(obj.negative)=[];
                case 'cutWilcoxon'
                        obj.idxNS=obj.indWNS; %the not selected are the Wilcoxon
                        obj.idxS=obj.indWS;
                    if length(obj.indWNS)>=1
                        slider(obj,obj.indWNS,'NS') %with the slider we just visualize the not selected, as the selected are usually in a high number, so it's not a nice type of visualization (the traces are very flat and small)
                    end
                    
                case 'cutSlope'
                        obj.idxNS=obj.indNSlope; %the not selected are the Slope
                        obj.idxS=obj.indSlope;
                    if length(obj.indNSlope)>=1
                        slider(obj,obj.indNSlope,'NS')     
                    end
            end
           
        end
        
        function radioButtonValue(obj)
            text=obj.bg.SelectedObject.Text;
            
            switch text
                case 'cutMedian'
                    elimDuringCalib=[];
                     
                case 'cutWilcoxon'
                    elimDuringCalib=obj.indWNS;
                    
                case 'cutSlope'
                    elimDuringCalib=obj.indNSlope;
                          
            end
            
            save('Fall.mat','elimDuringCalib','-append');
            obj.txaB.Value=sprintf('-cutMedian: %0.5f \n-cutWilcoxon: %0.5f \n-cutSlope: %0.5f\nPath: %s \nSAVED %s',obj.soglie(1),obj.soglie(2),obj.soglie(3),obj.path,text);
            fileID=fopen(obj.logFile,'a'); %append mode
            fprintf(fileID,'\nSAVED %s',text);
            
        end
        
        
        
        function slider(obj,idx,type)
            %idx=indexes we are maintaining/discarding/treating as inhibited, according to
            %type value
            %type refers to the type of indexes (maintained M, discarded D or inhibited I)
            idxs2p=obj.idx_cell(idx)-1;
            B=(obj.dFoF(idx,obj.tStart:obj.tStop));

            obj.t=obj.tStart/(obj.fs*60):1/(obj.fs*60):obj.tStop/(obj.fs*60);
            %obj.t=obj.t/60;
            
            app.fig=figure('Position',[621,105,550,650]);
            panel1 = uipanel('Parent',app.fig,'Position',[0,0,500,100]);
            panel2 = uipanel('Parent',panel1);
            set(panel1,'Position',[0 0 0.95 1]);
            set(panel2,'Position',[0 -1 1 2]);
            set(gca,'Parent',panel2);
            
            
            for i=1:size(B,1)
                sign=B(i,:)+5*i;
                plot(obj.t,sign); 
                hold on
                x=obj.t(round(length(obj.t)/2));
                y=5*i;
                text(x,y,num2str(idxs2p(i))); %plotting the suite2p index on every trace
            end
            
            ylim([0 5*size(B,1)+5]);
            xlabel('time [min]')
            ylabel('Fluorescence traces')
            
            switch type
                case 'S'
                    title('Maintained traces')
                case 'NS'
                    title('Eliminated traces')
            end
             
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
        
        
        
        function visualizeOBO(obj,type)
            %I have 3 gorups of cells I can visualize with the o-by-o mode:
            %maintained, discarded and inhibited cells (by median-slope-wilcoxon)
            %therefore I have 3 one-by-one buttons for maintained-inhibited
            %and discarded traces, so i need to insert the type of the
            %button here, to show the correct indexes.
            %
            
            if type=='M'
                
                idx=obj.idxS'; %if the type of button is the one-by-one for the visualization 
                               %of maintained cells we have to take the idxS
                               %(significant) indexes
            end
            if type=='D'
                idx=obj.idxNS';
            end
            if type=='I' %inhibited
                idx=obj.negative';
            end
                
                    
            
            
            
            if size(idx,1)>0
                
                %IND=obj.idx_cell(idx); %tutti gli indici
                traces=obj.dFoF(idx,:);
                ymin=min(min(traces))-1;
                ymax=max(max(traces))+1;
                
                obj.idxPlot=1;
                suite2p=obj.idx_cell(idx(obj.idxPlot))-1; %retrieving the suite2p index
                hFig=figure();
                axes=gca;
                
                obj.t=obj.tStart/(obj.fs*60):1/(obj.fs*60):obj.tStop/(obj.fs*60);
                 
                %IND=find(obj.idx_cell==); %un solo indice
                plot(obj.t,obj.dFoF(idx(obj.idxPlot),:));
                xline(obj.t(obj.tK),'-','Potassium');
                ylabel('dFoF')
                xlabel('time')
                ylim([ymin,ymax])
                title(sprintf('%d/%d   index:%d',obj.idxPlot,size(idx,1),suite2p(1)))
            
                ButtonForward=uicontrol('Parent',hFig,'Style','pushbutton','String','>',...
                'Position',[30,2,20,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)forward(obj,axes,idx,ymin,ymax));

                ButtonBack=uicontrol('Parent',hFig,'Style','pushbutton','String','<',...
                'Position',[2,2,20,20],'Units','normalized','Visible','on',...
                'CallBack',@(src,event)backward(obj,axes,idx,ymin,ymax));     
            end
            
        end
        
        
        function forward(obj,axes,idx,ymin,ymax)
            
            obj.idxPlot=obj.idxPlot+1;
           
            
            if obj.idxPlot>size(idx,1)
                obj.idxPlot=1;
            end
            
                suite2p=obj.idx_cell(idx(obj.idxPlot))-1;
                plot(obj.t,obj.dFoF(idx(obj.idxPlot),:),'Parent',axes)
                xline(obj.t(obj.tK),'-','Potassium');
                ylabel('dFoF')
                xlabel('time')
                ylim([ymin,ymax])
                title(sprintf('%d/%d   index:%d',obj.idxPlot,size(idx,1),suite2p))
        end
        
        
        function backward(obj,axes,idx,ymin,ymax)
             
            obj.idxPlot=obj.idxPlot-1;
            
            if obj.idxPlot<1
                obj.idxPlot=1;
            end
            suite2p=obj.idx_cell(idx(obj.idxPlot))-1;
            plot(obj.t,obj.dFoF(idx(obj.idxPlot),:),'Parent',axes)
            xline(obj.t(obj.tK),'-','Potassium');
            ylabel('dFoF')
            xlabel('time')
            ylim([ymin ymax])
            title(sprintf('%d/%d   index:%d',obj.idxPlot,size(idx,1),suite2p));
        end
            
        
    end
    
end

