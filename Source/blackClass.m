classdef blackClass <handle
   
    properties
        
        Button
        
    end
    
    methods
        
        function black=blackClass
            
            black.Button=uibutton('Text','<<Menu','Position',[10 10 120 22],...
                'ButtonPushedFcn',@(btn,event)menu(black))
        
        end
        
        function menu(black)
            black.
            
        end
    end
    
    
end