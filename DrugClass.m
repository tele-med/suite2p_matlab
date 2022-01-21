classdef DrugClass <handle
   
    properties
        
        Figure
        PanelConfig
        
        ax
        ax2
        
        type %m because i'm searching for mat files
        
        txaB
        
        file
        path
        tF
        tL
        in
        idx_cell
        IDX
        Line
        deleted
        help
     
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
        time
        interval

        buttonDelete
        
    end
    
    methods
    
        function app=DrugClass
            
            %costruttore
            app.type='m';
            app.Figure=uifigure('Name','Drug Application Experiment');
            app.Figure.Position=[115   221   1200   470];
            gB=uigridlayout(app.Figure,[1 3]);
            gB.ColumnWidth={210,'1x','1x'};
            
            configPanel(app,gB)
            
            p=uipanel(gB);
            p.Layout.Column=2;
            app.ax = axes(p);
            
            allPanelConfig(app,gB)


        end
    
        
        
        function configPanel(app,gB) %Pannello Config
           
           app.PanelConfig = uipanel(gB,'Title','Configuration');
           app.PanelConfig.Layout.Column=1;
           
           % Grid in the panel
           grid2 = uigridlayout(app.PanelConfig,[8 2]);
           grid2.RowHeight = {22,22,22,22,22,22,22,22,'1x'};
           grid2.ColumnWidth = {140,'1x'};

           %Buttons for file and directory selection
           buttonf = uibutton(grid2,'Text','Import .mat file');
           buttonf.ButtonPushedFcn = @(src,event)MenuSelection(app,app.type,buttonf);
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
           app.saveButton.Layout.Column=[1,2];
           app.saveButton.ButtonPushedFcn = @(src,event)saveFiles(app);
          
           
           % RUN
           app.runButton=uibutton(grid2,'Text','RUN/RESTART');
           app.runButton.Layout.Row=6;
           app.runButton.Layout.Column=[1,2];
           app.runButton.ButtonPushedFcn=@(btn,event)PostSuite2pStim(app,app.fs,app.correctionFactor,app.order,app.cut,app.ax,app.ax2);
           
           app.help=uibutton(grid2,'Text','Help');
           app.help.ButtonPushedFcn = @(src,event)openHelp('helpDrug.txt');
           
           app.txaB=uitextarea(grid2,'Editable','off');
           app.txaB.Layout.Row=9;
           app.txaB.Layout.Column=[1,2];
           
           
       
        end
        
        function allPanelConfig(app,gB)
            p2=uipanel(gB);
            p2.Layout.Column=3;
            app.ax2 = axes(p2);
            
            app.buttonDelete=uibutton(p2,'Text','Delete Trace','Position',[2,2,200,20]);
            app.buttonDelete.ButtonPushedFcn = @(src,event)deleteTrace(app);
          
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
    
        function deleteTrace(app)
            
            Midx=app.idx_cell(app.IDX);
            s2pidx=Midx-1;
            app.deleted=[app.deleted,s2pidx];
            app.in.iscell(Midx,1)=0; %cancello la cellula 
            app.idx_cell(app.IDX)=[]; %??
            PostSuite2pStim(app,app.fs,app.correctionFactor,app.order,app.cut,app.ax,app.ax2);
            
            h=app.saveButton;
            set(h,'backg',[1 .6 .6]);
           
        end
     
    
        function saveFiles(app)
            %salvataggio
            %prompt per scegliere directory di destinazione e poi salvare in
            %quel path
            col=get(app.runButton,'backg');
            set(app.saveButton,'backg',[0,1,0]);
            
            
            %EXPORT DELLE IMMAGINI
            Fig2=figure();
            set(Fig2, 'Visible', 'off');
            copyobj(app.ax,Fig2);
            print(Fig2,'Groups.png','-dpng','-r300')
            
            m=[app.dfUp;app.dfMiddle;app.dfDown;app.time;app.interval]';
            
            iscell=app.in.iscell;
            save('Fall.mat','iscell','-append');
            writematrix(app.deleted,'deletedCells.txt');
            writematrix(m,'Up-Middle-Down-time-intervals.txt')
            
            set(app.saveButton,'backg',col);
        end
        
        
        
end
    
end