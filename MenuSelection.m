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
                
                try
                    app.txaB.Value={'File name:';app.file;'Path name:';path};
                    cd(path);  
                catch
                    app.txaB.Value='NO FILE SELECTED';
                end
           end
           if app.type=='d'
                dirname = uigetdir('C:\');
                try
                    cd(dirname)
                    d=dir('*');
                    d=string({d.name});
                    d=["Current folder",d];
                    app.txaB.Value=d;
                catch
                    app.txaB.Value='NO DIRECTORY SELECTED';
                end
                
           end
           if app.type=='m'
               [app.file,app.path]=uigetfile('*.mat','MultiSelect','off');
                
                try
                    app.txaB.Value={'File name:';app.file;'Path name:';app.path};
                    cd(app.path);  
                catch
                    app.txaB.Value='NO FILE SELECTED';
                end
           end
            file=app.file;
            
            try
                pause(0.5)
                set(h,'backg',col);
            catch
                
            end
        end 