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
    end
    
    methods
        function obj = Calibration
            %Calibration Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.correctionFactor=0.7;
            obj.order=100;
            
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
           grid4 = uigridlayout(obj.PanelOutput,[5 2]);
           grid4.ColumnWidth = {'2x','1x'};
           grid4.RowHeight = {'4x','1x','1x','1x','1x'};
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
           obj.tStartField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(obj,'start'));
           obj.tStart=1;
           obj.tStartField.Value = 1;
           
           
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
           runButton=uibutton(grid2,'Text','RUN', 'ButtonPushedFcn',@(src,event)funzioneSoglia(obj)); %da fare meglio
           runButton.Layout.Row=7;
           runButton.Layout.Column=[1,2];
           
           
        end
        
        
        function initializePanelOutput(obj,grid)
            
           %text area
           obj.txaB=uitextarea(grid);
           obj.txaB.Layout.Row=[1,5];
           obj.txaB.Layout.Column=1;
           
           obj.bg = uibuttongroup(grid,'SelectionChangedFcn',@(src,event)radioButtonChanged(obj));
           obj.bg.Layout.Row=1;
           obj.bg.Layout.Column=2;
           rb1 = uiradiobutton(obj.bg,'Position',[10 100 91 15]);
           rb2 = uiradiobutton(obj.bg,'Position',[10 80 91 15]);
           rb3 = uiradiobutton(obj.bg,'Position',[10 60 91 15]);
           rb1.Text = 'cutMedian';
           rb2.Text = 'cutWilcoxon';
           rb3.Text = 'cutSlope';
           
           confirmButton=uibutton(grid,'Text','Confirm cut method','ButtonPushedFcn', @(src,event)radioButtonValue(obj));
           confirmButton.Layout.Column=2;
           confirmButton.Layout.Row=2;
           
           
           obj.idxField=uieditfield(grid,'Value','cell idx separated by commas');
           obj.idxField.Layout.Column=2;
           obj.idxField.Layout.Row=4;
           idxButton=uibutton(grid,'Text','Visualize','ButtonPushedFcn', @(src,event)visualizeTraces(obj));
           idxButton.Layout.Column=2;
           idxButton.Layout.Row=5;
            
        end
        
        
        
        function takeValue(obj,label)
            switch label
                case 'fs'
                    obj.fs=obj.fsField.Value;
                case 'start'
                    obj.tStart=obj.tStartField.Value;
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
            obj.t=obj.tStart/obj.fs:1/obj.fs:length(obj.dFoF)/obj.fs;
            obj.t=obj.t/60;
            
            figure
            for i=1:length(idx)
                plot(obj.t,obj.dFoF(idx(i),:)+i)
                hold on
                text(obj.t(1),i,num2str(obj.idxUser(i)))
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
                    obj.dFoF=deltaFoverF(obj.in.iscell,obj.in.F,obj.in.Fneu,obj.correctionFactor,obj.order,obj.tK);
                    

                    
                catch
                    obj.txaB.Value='NO FILE SELECTED';
                end
                
                
        end
           
        function funzioneSoglia(obj)
            [obj.soglie,obj.indWS,obj.indWNS,obj.indSlope,obj.indNSlope]=sceltaSoglie(obj.fs,obj.correctionFactor,obj.order,obj.tStart,obj.tK,obj.tStop,obj.dFoF);
            obj.txaB.Value=sprintf('-cutMedian: %0.5f \n-cutWilcoxon: %0.5f \n-cutSlope: %0.5f\nPath: %s',obj.soglie(1),obj.soglie(2),obj.soglie(3),obj.path);%obj.path,'---cutMedian ',num2str(obj.soglie(;1))
                                   
        end
        
        
        function radioButtonChanged(obj)
           
            text=obj.bg.SelectedObject.Text;
            switch text
                case 'cutMedian'
                    
                case 'cutWilcoxon'
                    slider(obj,obj.indWS,'S')
                    slider(obj,obj.indWNS,'NS')
                    
                case 'cutSlope'
                    slider(obj,obj.indSlope,'S')
                    slider(obj,obj.indNSlope,'NS')
            end
           
        end
        
        function radioButtonValue(obj)
            text=obj.bg.SelectedObject.Text;
            
            switch text
                case 'cutMedian'
                    
                case 'cutWilcoxon'
                    elimDuringCalib=obj.indWNS;
                    save('Fall.mat','elimDuringCalib','-append');
                    
                case 'cutSlope'
                    elimDuringCalib=obj.indNSlope;
                    save('Fall.mat','elimDuringCalib','-append');
                    
            end
            
        end
        
        
        
        function slider(obj,idx,type)
            %idx=indexes we are maintaining or discarding
            %type refers to the type of indexes (maintained or discarded)
            idxs2p=obj.idx_cell(idx)-1;
            
            obj.t=obj.tStart/obj.fs:1/obj.fs:length(obj.dFoF)/obj.fs;
            obj.t=obj.t/60;
            
            app.fig=figure('Position',[621,105,550,650]);
            panel1 = uipanel('Parent',app.fig,'Position',[0,0,500,100]);
            panel2 = uipanel('Parent',panel1);
            set(panel1,'Position',[0 0 0.95 1]);
            set(panel2,'Position',[0 -1 1 2]);
            set(gca,'Parent',panel2);
            
            B=(obj.dFoF(idx,:));

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
        
    end
end

