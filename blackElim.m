function blackElim(fd,varargin)
%blackElim is a function used to get rid of the black frames present in the
%.tif files
%   INPUT DESCRIPTION: fd        ----->     set 'f' as input if you want to apply the
%                                           function on a specific .tif file. 
%                                ----->     set 'd' as input if you want to apply the
%                                           function on a group of .tifs you have in the
%                                           current directory you are working in
%
%                      fileName  ----->     OPTIONAL paramenter, you have to set it
%                                           only if you choose 'f' as the first
%                                           input.
%
%                      destFolder ----->    OPTIONAL PARAMETER. The default
%                                           is that the new .tifs will be saved in a  
%                                           destination folder called
%                                           noBlack.
%                                           If yo want to change this folder default name                                        
%                                           set this parameter to a new
%                                           name (i.e. 'noBlackFolder').
%
%                      level     ----->     OPTIONAL parameter. The default
%                                           is 1000, and it represents the
%                                           gray level under which the frame is consdered black.

destFolder='noBlack';
level=1000;

if nargin>1
    if fd=='d' && isa(varargin,'string') && contains(varargin{1},'.tif')
        error('If you are choosing ''d'' as first input you cannot specify the fileName as second parameter');
    end
end
    

if nargin==2
    
   if isa(varargin{1},'double')
        level=varargin{1};
    else if fd=='f'
        filename=varargin{1};
        else
            destFolder=varargin{1};
        end
   end
end

                

if nargin==3
    
    if fd=='d'
        destFolder=varargin{1};
        level=varargin{2};
    end
   
    if fd=='f'
        filename=varargin{1};
        
        if isa(varargin{2},'double')
            level=varargin{2};
        else
            destFolder=varargin{2};
        end
    end            
end

if nargin==4
            filename=varargin{1};
            destFolder=varargin{2};
            level=varargin{3};
end


warning('off','all');
mkdir(destFolder);

disp('Process started')

if fd=='f'
    blackOneTif(filename,destFolder,level);
    %totalImage=blackOneTif(filename,destFolder,level);
    %tifVisualizer(totalImage);
    
    
else
    tifList= dir ('*.tif');
    tifList={tifList.name};    

    for i = 1:length(tifList)
    filename=tifList{i};
    blackOneTif(filename,destFolder,level);
    end
end

disp('Process ended');

end

