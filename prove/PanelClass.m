classdef PanelClass <handle
   
    properties
       Panel
       
    end
    
    
    methods
       
        function panel=PanelClass(frame)
           
            panel.Panel=uipanel(frame,'BackgroundColor','#acb678');
            
        end
            
        
    end
end