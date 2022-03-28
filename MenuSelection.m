function file=MenuSelection(varargin) %PER IL MENU IMPORT
           app=varargin{1};
           app.type=varargin{2}; 

           if app.type=='f'
               %file
                [app.file,path]=uigetfile('*.tif','MultiSelect','off');
                
                try
                    app.txaB.Value={'File name:';app.file;'Path name:';path};
                    cd(path);  
                catch
                    app.txaB.Value='NO FILE SELECTED';
                end
           end
           if app.type=='d'
               %directory
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
                    app.path=append(app.path,'\',app.file);
                    app.in=load(app.path);
                    app.idx_cell=find(app.in.iscell==1);
%                     app.start=1;
%                     app.stop=size(app.in.F,2);
%                     app.t=app.start/app.fs:1/app.fs:app.stop/app.fs;
%                     app.t=app.t/60;
                    initValues(app);
                catch
                    app.txaB.Value='NO FILE SELECTED';
                end
                
                
           end
           file=app.file;
           

        end 