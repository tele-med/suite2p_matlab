classdef FrameProva <handle
    
    properties
       
        Frame
        folderField
        
        lbl
        destFolder
        level
        
    end
    
    
    methods
        
        function app=FrameProva
            
            app.Frame=uifigure;
            
            % Create figure and components.
            app.lbl = uilabel(app.Frame,...
                  'Position',[130 100 100 15]);

            app.folderField = uieditfield(app.Frame,...
                  'Position',[100 175 100 22],...
                  'ValueChangedFcn',@(src,event)textChanged(app,'f'));
        end

   
    
    
        function textChanged(app,type)
         app.destFolder=app.folderField.Value;
         app.destFolder
         type   
        end

    end
    
end
    