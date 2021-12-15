classdef DrugClass <handle
   
    properties
        
        Figure
        PanelConfig
        
        ax
        
        type %m because i'm searching for mat files
        
        txaB
        
        file
        path
        
        fs
        fsField
        
        correctionFactor
        alphaField

        order
        filterField
        
        cut
        cutField
        
        runButton
        
        saveButton
        
        dfUp
        dfDown
        dfMiddle
    end
    
    methods
    
        function app=DrugClass
            %costruttore
            app.type='m';
            app.Figure=uifigure('Name','Drug Application Experiment');
            app.Figure.Position=[415   321   760   420];
            gB=uigridlayout(app.Figure,[1 2]);
            gB.ColumnWidth={210,'1x'};
            configPanel(app,gB)
            p=uipanel(gB);
            p.Layout.Column=2;
            app.ax = axes(p);
            

        end
    
        
        
        function configPanel(app,gB) %Pannello Config
           
           app.PanelConfig = uipanel(gB,'Title','Configuration');
           app.PanelConfig.Layout.Column=1;
           
           % Grid in the panel
           grid2 = uigridlayout(app.PanelConfig,[7 2]);
           grid2.RowHeight = {22,22,22,22,22,22,22,'1x'};
           grid2.ColumnWidth = {140,'1x'};

           %Buttons for file and directory selection
           buttonf = uibutton(grid2,'Text','Import File');
           buttonf.ButtonPushedFcn = @(src,event)MenuSelection(app,'m',buttonf);
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
           app.correctionFactor=0.9;
           app.alphaField.Value = 0.9;
          
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
           cutLabel=uilabel(grid2,'HorizontalAlignment','right','Text','cut treshold');
           cutLabel.Layout.Row=5;
           cutLabel.Layout.Column=1;
           
           % cut edit field
           app.cutField=uieditfield(grid2,'numeric','ValueChangedFcn',@(src,event)takeValue(app,'c'));
           app.cut=0.5;
           app.cutField.Value = 0.5;
           
           app.saveButton=uibutton(grid2,'Text','Save data');  %COLLEGA AL CALLBACK
           app.saveButton.Layout.Row=7;    
          
           
           % RUN
           app.runButton=uibutton(grid2,'Text','RUN');
           app.runButton.Layout.Row=6;
           app.runButton.Layout.Column=[1,2];
           app.runButton.ButtonPushedFcn=@(btn,event)PostSuite2pStim(app,app.file,app.fs,app.correctionFactor,app.order,app.cut,app.ax);
          
           app.txaB=uitextarea(grid2,'Editable','off');
           app.txaB.Layout.Row=8;
           app.txaB.Layout.Column=[1,2];
           
       
        end
        
        function takeValue(app,label)
            switch label
                case 'fs'
                    app.fs=app.fsField.Value;
                case 'a'
                    app.correctionFactor=app.alphaField.Value;
                case 'o'
                    app.order=app.filterField.Value;
                case 'c'
                    app.cut=app.cutField.Value;
            end
         
        end
    
    
        function saveFiles(app)
            %salvataggio
            %prompt per scegliere directory di destinazione e poi i save in
            %quel path
            save(append(extractBefore(app.path,'suite2p'),'dfUp',name,'-',num2str(tF),'-',num2str(tL)),'app.dfUp');
            save(append(extractBefore(app.path,'suite2p'),'dfDown',name,'-',num2str(tF),'-',num2str(tL)),'app.dfDown');
            save(append(extractBefore(app.path,'suite2p'),'dfMiddle',name,'-',num2str(tF),'-',num2str(tL)),'app.dfMiddle');
        end
end
    
end