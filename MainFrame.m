classdef MainFrame <handle
    
    %proprietà della classe
    properties
        
        Figure                  % Graphics handles 
        DrugFigure
        Panel
        
        blackButton
        drugButton
        swingButton
        optoButton
  
    end
    
    
    %metodi della classe
    methods
        
        function app = MainFrame
            %costruttore
            
            app.init();
            %app.menuCreation();
            %app.Figure.CloseRequestFcn = @(src,event)my_closereq(app);
           
            
        end
        
        function init(app)
            app.Figure=uifigure('Name','Calcium Imaging Analysis','Resize','off','Color','#FFFFFF');
            
            app.Panel=uipanel('Parent',app.Figure,'Visible','on','Position',[0 0 560 420],'BorderType','none');
            app.Panel.BackgroundColor='#FFFFFF';
               
            gl = uigridlayout(app.Panel,[3 3]);
            gl.RowHeight = {22,60,'1x'};
            
            lab=uilabel(gl,'Text','Calcium imaging analysis toolbox');
            lab.Layout.Row=1;
            lab.Layout.Column=[1 3];
            
            app.blackButton=uibutton(gl,'push','Text','Black frames elimination toolbox');
            app.blackButton.BackgroundColor='#8fbc8f';
            app.blackButton.Layout.Row = 2;
            app.blackButton.Layout.Column = [1 3];
            
            app.drugButton=uibutton(gl,'push','Text','Drug Application Experiment');
            app.drugButton.BackgroundColor='#5f9ea0';
            app.drugButton.Layout.Row = 3;
            app.drugButton.Layout.Column = 1;
            
            app.swingButton=uibutton(gl,'push','Text','Swing Cells Experiment');
            app.swingButton.BackgroundColor='#b0c4de'; 
            
            app.optoButton=uibutton(gl,'push','Text','Optogenetic Experiment');
            app.optoButton.BackgroundColor= '#add8e6';
            
        end
        

        function my_closereq(app)
            
            selection = uiconfirm(app.Figure,'Close the figure window?',...
            'Confirmation');
        
            switch selection
                case 'OK'
                    delete(app.Figure)
                case 'Cancel'
                    return
            end
        end
        

  
                
        
        
        

            
        
    end
    
    
end