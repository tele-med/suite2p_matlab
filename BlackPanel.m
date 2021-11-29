classdef BlackPanel <handle
    
   properties
       MainFrame
       PanelB
       buttonBack
       txaB
              
       menuVisualizeStack   %menu per visulizzare i tif Stack
        
       menuHelp             %menù con tutta la spiegazione dei vari campi
       
       menuROI              %menu per il ROI manager
       FrameROI
       image_data           %cell con le 3 immagini prese a 2/5 3/5 e 4/5 della lunghezza totale
       c                    %circle
       count                %numero di ROI aggiunti
       listROI              %lista con tutte le aree degli ROI aggiunti
       dropDown
       textROI
       
       folderField
       levelField
       runButton
       
       destFolder
       level
       file
       type
        
   end
   
   
   methods(Static)
       
        function openHelp
            txt=uitextarea();
            pos=txt.Parent.Position;
            pos([1,2])=0;
            txt.Position=pos;
            fid=fopen('help.txt');
            while ~feof(fid)
                tline = fgetl(fid);
                txt.Value=[txt.Value;tline];
            end
            fclose(fid);

        end
   end
   
   methods
       
       
        function app=BlackPanel(mainFrame)
           
           app.MainFrame=mainFrame;
           app.PanelB=uipanel(mainFrame.Figure,'Visible','off','Position',[0 0 560 420],'BorderType','none');
           app.PanelB.BackgroundColor='#FFFFFF';  
           gB=uigridlayout(app.PanelB,[3 4]);
           gB.RowHeight={22,120,'1x'};
           uibutton(gB,'Text','<<Menu',...
           'ButtonPushedFcn',@(btn, event)closeBlack(app));
           
           app.txaB = uitextarea(gB,'Editable','off');
           app.txaB.Layout.Row=[2 3];
           app.txaB.Layout.Column=1;
           
           configPanel(app,gB);
           app.menuCreation();  
           
        end

       
        function configPanel(app,gB) %Pannello Config
           p = uipanel(gB,'Title','Configuration');
           p.Layout.Row=[2 3];
           p.Layout.Column=[2 4];
           
           % Grid in the panel
           grid2 = uigridlayout(p,[5 2]);
           grid2.RowHeight = {22,22,22,22,22};
           grid2.ColumnWidth = {120,'1x'};

           %Buttons for file and directory selection
           buttonf = uibutton(grid2,'Text','Import File');
           buttonf.ButtonPushedFcn = @(src,event)MenuSelection(app,'f',buttonf);
           buttond = uibutton(grid2,'Text','Import Directory');
           buttond.ButtonPushedFcn = @(src,event)MenuSelection(app,'d',buttond);
           
           % Folder Label
           uilabel(grid2,'HorizontalAlignment','right','Text','Destination folder');
            
           % Folder edit field
           app.folderField=uieditfield(grid2,'ValueChangedFcn',@(src,event)textChanged(app,'f'));
           app.destFolder='noBlack';
           app.folderField.Value = 'noBlack';
          
           % Level Label
           uilabel(grid2,'HorizontalAlignment','right','Text','Gray level for black');
            
           % Level edit field
           app.levelField=uieditfield(grid2,'numeric');
           app.levelField.ValueChangedFcn=@(src,event)textChanged(app,'l');
           app.level=1000;
           app.levelField.Value =1000;           
           
           app.runButton=uibutton(grid2,'Text','RUN');
           app.runButton.Layout.Row=4;
           app.runButton.ButtonPushedFcn=@(btn,event)runBlackElim(app);
           
           stopLabel=uilabel(grid2,'Text','To STOP the execution press CTRL+C','FontColor','#0072BD');
           stopLabel.Layout.Row=5; 
           stopLabel.Layout.Column=[1 2];
          
        end
       
       
        function textChanged(app,t)%PER I DESTFOLDER E LEVEL INPUT FIELDS         
          if t=='f'
            app.destFolder=app.folderField.Value;
            
            else if t=='l'
                app.level=app.levelField.Value;
                end
                
          end
  
       end 
       
               
        function menuCreation(app)
           
           %menu ROI Manager
           app.menuROI = uimenu(app.MainFrame.Figure,'Text','ROIManager','Visible','off');
           
           mitemChoose=uimenu(app.menuROI,'Text','Choose tif');
           mitemChoose.MenuSelectedFcn = @(src,event)chooseSomeImages(app,'f');
           
           mitemAnalyze=uimenu(app.menuROI,'Text','Analyze');
           mitemAnalyze.Accelerator = 'A';
           mitemAnalyze.MenuSelectedFcn = @(src,event)roiAnalyzer(app);
           
           %menu Visualize
           app.menuVisualizeStack = uimenu(app.MainFrame.Figure,'Text','Visualize','Visible','off');
           app.menuVisualizeStack.MenuSelectedFcn = @(src,event)openVisualizer(app,'f');
           %mitemVisual = uimenu(app.menuVisual,'Text','Choose tif')
           
           %menuHelp
           app.menuHelp = uimenu(app.MainFrame.Figure,'Text','Help');
           app.menuHelp.MenuSelectedFcn = @(src,event)app.openHelp; 
        end
      
        
        function file=MenuSelection(varargin) %PER IL MENU IMPORT
           app=varargin{1};
           app.type=varargin{2}; 
           try
             h=varargin{3};
             col = get(h,'backg');
             set(h,'backg',[1 .6 .6]);
           catch
           end
               
           if app.type=='f'
                [app.file,path]=uigetfile('*.tif','MultiSelect','off');
                %blackElim('f',file)
                try
                    app.txaB.Value={'File name:';app.file;'Path name:';path};
                    cd(path);  
                catch
                    app.txaB.Value='NON HAI SELEZIONATO UN FILE';
                end
            
            else
                dirname = uigetdir('C:\');
                try
                    cd(dirname)
                    d=dir('*');
                    d=string({d.name});
                    d=["Current folder",d];
                    app.txaB.Value=d;
                catch
                    app.txaB.Value='NON HAI SELEZIONATO LA CARTELLA';
                end
                
            end
            file=app.file;
            
            try
                pause(0.5)
                set(h,'backg',col);
            catch
                
            end
        end 
        
        
        function runBlackElim(app) %FUNZIONE CHE ELIMINA I FRAME NERI DAL TIF MOVIE 
            app.txaB.Value='Process start';
            
            if app.type=='f'
                blackElim(app.type,app.file,app.destFolder,app.level);
            else
                blackElim(app.type,app.destFolder,app.level);
            end
            
            app.txaB.Value='Process ended';
        end
        
        
        function openVisualizer(app,type)
            
            try
                fName=MenuSelection(app,type);
                app.txaB.Value=[app.txaB.Value;'  ';'Wait...'];
                pause(0.01)
                warning('off','all');
                LoadAndVisualizeTIFSTACK(fName);
            catch
                app.txaB.Value='No file selected';
            end
            
        end
        
        
        function roiAnalyzer(app) %INTERFACCIA PER L'ROI TOOLBOX
           app.count=0;
           app.FrameROI=uifigure('Name','ROI Analizer','Color','#FFFFFF','Position',[1049,337,250,400]);
           gROI=uigridlayout(app.FrameROI,[5 2]);
           gROI.ColumnWidth={150,'1x'};
           gROI.RowHeight={22,22,22,22,'1x'};
           app.textROI=uitextarea(gROI,'Editable','off');
           app.textROI.Layout.Row=[1 5];
           app.textROI.Layout.Column=1;
           
           try
               figure('Name','Current Frame for ROI measurement')
               imshow(app.image_data{1,1})
               app.textROI.Value='ROI N   AREA';
           catch
               app.textROI.Value='NO .tif SELECTED';
           end
           
           %ADD ROI BUTTON
           addButton=uibutton(gROI,'Text','Add ROI',...
               'ButtonPushedFcn',@(src,event)addROI(app));
           addButton.Layout.Column=2;
           addButton.Layout.Row=1;
           
           %MEASURE BUTTON
           measureButton=uibutton(gROI,'Text','Measure');
           measureButton.Layout.Column=2;
           measureButton.Layout.Row=2;
           measureButton.ButtonPushedFcn=@(src,event)measure(app);
           
           %DROP DOWN TO CHOOSE IMAGES
           app.dropDown=uidropdown(gROI,'Items',{'Image_1','Image_2','Image_3'},...
               'ValueChangedFcn',@(src,event)ddSelection(app));
           app.dropDown.Layout.Row=3;
           
           %CLEAR ACTUAL ROI BUTTON
           clearButton=uibutton(gROI,'Text','Clear',...
               'ButtonPushedFcn',@(src,event)initialize(app));
           clearButton.Layout.Row=4;
           
        end
        
        
        function chooseSomeImages(app,type) %FUNZIONE CHE SCEGLIE SOLO 3 FRAME DAGLI N PRESENTI NEL TIF MOVIE
            warning('off','all');
            fileName=MenuSelection(app,type);
            info = imfinfo(fileName);
            numberOfPages = length(info);
            idx=round(numberOfPages/5);
            vector=[idx,2*idx,3*idx];
            app.image_data=cell(1,length(vector));
            for k = 1 : length(vector)
                % Read the kth image in this multipage tiff file.
                thisPage = imread(fileName, vector(k));
                app.image_data{k}=thisPage;
            end
            
        end

        
        function addROI(app) %FUNZIONE CHE RUNNA DRAWCIRCLE
            
            app.count=app.count+1;
            %c=drawcircle('Label',string(app.count),'LineWidth',0.2,'Color','y');
            circ=drawcircle('LineWidth',0.2,'Color','y');
            app.c=[app.c,circ];
            area=(circ.Radius)*(circ.Radius)*pi;
            str=[app.textROI.Value;'ROI',num2str(app.count),'   ',num2str(area)];
            app.textROI.Value=str;
            app.listROI=[app.listROI, area];
            
        end
        
        
        function ddSelection(app) %PER SELEZIONARE IMMAGINE 1/2/3
           try
           i=str2double(extractAfter(app.dropDown.Value,'_'));
           imshow(app.image_data{1,i});
           catch
               app.textROI.Value='NO .tif SELECTED';
           end
        end
              
        
        function initialize(app)
           app.count=0;
           app.textROI.Value='ROI N   AREA';
           app.listROI=[];
           delete(app.c);
        end %INIZIALIZZAZIONE VALORI ROI
        
        
        function measure(app)
            diam=sqrt(4*app.listROI);
            m=mean(diam);
            str=[app.textROI.Value;'';'mean_diameter=',num2str(m)];
            app.textROI.Value=str;
            m=abs(m-[6,12,24,48]);
            [~,ind]=min(m);
            str=[app.textROI.Value;'';'spatial_scale=',num2str(ind)];
            app.textROI.Value=str;
            
        end
            
            
        function closeBlack(app)      
           app.txaB.Value=''; 
           app.menuROI.Visible='off';
           app.menuVisualizeStack.Visible='off';
           app.PanelB.Visible='off';
        end
      

   end    
end