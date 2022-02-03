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
            
            app.Frame=MainFrame; %main initial frame 
            app.Frame.Figure.Position=[100 337 560 420];
            app.PanelBlack=BlackPanel(app.Frame); %Panel for the black frame elimination toolbox
            
            app.Frame.blackButton.ButtonPushedFcn=@(btn,event)openBlack(app); %callback to jump in the black elimination toolbox
            app.Frame.drugButton.ButtonPushedFcn=@(btn,event)openDrug(app); %callback for the Drug Experiment Frame
            app.Frame.swingButton.ButtonPushedFcn=@(btn,event)openSwing(app); %callback for the Swing Experiment Frame
        
            app.Frame.Figure.CloseRequestFcn = @(src,event)my_closereq(app); %closing callback
           
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
            
            prompt={'Neuropil correction factor value:','Sampling rate [Hz]:',...
                    'Interval to analize (i.e. 1,200)[sample]'};
            name1='Inputs';
            numlines=1;
            defaultanswer={'0.9','1','all'};
            answer=inputdlg(prompt,name1,numlines,defaultanswer);
            app.Swing=PlotSkew(pathname,filename,str2double(answer{1}),str2double(answer{2}),answer{3});
            
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
                    %delete(app.Drug.Figure)
                    %delete(app.Swing.Figure)
                    %delete(app.OptoFigure)
                case 'Cancel'
                    return
            end
        end


      
    end



end