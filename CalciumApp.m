classdef CalciumApp <handle 
    %main
    
    properties
        Frame           %Frame principale
        PanelBlack      %Pannello per il toolbox 
        Drug            %Drug class
        Swing           %Swing class
        Optogenetic     %Opto class
        
    end
    
    
    methods
        
        %costruttore
        function app=CalciumApp
            
            app.Frame=MainFrame; %Creo il Frame con men�
            app.Frame.Figure.Position=[100 337 560 420];
            app.PanelBlack=BlackPanel(app.Frame); %Creo il Pannello del black frame elimination toolbox
            app.Frame.Figure.CloseRequestFcn = @(src,event)my_closereq(app);
           
            app.Frame.blackButton.ButtonPushedFcn=@(btn,event)openBlack(app); %callback per entrare nel black elimination toolbox
            app.Frame.drugButton.ButtonPushedFcn=@(btn,event)openDrug(app); %callback per Frame Drug Experiment
            app.Frame.swingButton.ButtonPushedFcn=@(btn,event)openSwing(app);
        end
            
            
        
        function openBlack(app)
            app.PanelBlack.menuVisualizeStack.Visible='on';
            app.PanelBlack.menuROI.Visible='on';
            app.PanelBlack.PanelB.Visible='on';
        end
        
                
        function openDrug(app)
            app.Drug=DrugClass;

        end
         
        function openSwing(app)
            
            [filename,pathname]=uigetfile('*.mat','Pick a "Fall.mat" file');
            
            prompt={'Enter the  neuropil correction factor value:'};
            name='alpha factor';
            numlines=1;
            defaultanswer={'0.9'};
            answer=inputdlg(prompt,name,numlines,defaultanswer);
            app.Swing=PlotSkew([pathname,filename],str2double(answer{1}));
            
        end
        
        function my_closereq(app)
            
            selection = uiconfirm(app.Frame.Figure,'Close the figure window?',...
            'Confirmation');
        
            switch selection
                
                case 'OK' 
                    delete(app.Frame.Figure)
                    delete(app.PanelBlack.MainFrame)
                    delete(app.PanelBlack.FrameROI)
                    close all
                    %delete(app.DrugFigure.Figure)
                    %delete(app.SwiggleFigure)
                    %delete(app.OptoFigure)
                case 'Cancel'
                    return
            end
        end


      
    end



end