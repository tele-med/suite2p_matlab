function [coordinateSelected, minIdx] = showZValueFcn(hObj,event,i,app)
%  FIND NEAREST (X,Y,Z) COORDINATE TO MOUSE CLICK
% Inputs:
%  hObj (unused) the axes
%  event: info about mouse click
% OUTPUT
%  coordinateSelected: the (x,y,z) coordinate you selected
%  minIDx: The index of your inputs that match coordinateSelected. 


x = hObj.XData; 
y = hObj.YData; 

pt = event.IntersectionPoint;       % The (x0,y0) coordinate you just selected
coordinates = [x(:),y(:)];          % matrix of your input coordinates
dist = pdist2(pt(1:2),coordinates); %distance between your selection and all points
[~, minIdx] = min(dist);            % index of minimum distance to points
c=round(coordinates(minIdx,:),2);
hold on
plot(c(1),c(2),'*g');
coordinateSelected = c; %the selected coordinate
% from here you can do anything you want with the output.  This demo
% just displays it in the command window.  
%fprintf('[x,y] = [%.2f, %.2f]\n', coordinateSelected)



    %if I want to discard an existing peak I need to find it
    [boolx,coordx]=ismember(c(1),round(app.indexesNew{i},2));
    booly=ismember(c(2),round(app.peaksNew{i},2));
    
    if boolx==1 && booly==1
        
        app.indexesNew{i}(coordx)=[];
        app.peaksNew{i}(coordx)=[]; 
        fprintf('picco rilevato')
    else
        app.indexesNew{i}=[app.indexesNew{i};c(1)]; %x
        app.peaksNew{i}=[app.peaksNew{i};c(2)];  %y
        fprintf('picco aggiunto')
    
    end



end
  