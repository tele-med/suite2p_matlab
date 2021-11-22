classdef DrugClass <handle
   
    properties
        
        Figure
        
    end
    
    methods
    
        function drug=DrugClass
            %costruttore
            
            drug.Figure=uifigure('Name','Drug Application Experiment')
        end
    
    end
    
    
    
end