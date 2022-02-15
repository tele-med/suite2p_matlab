function [pts,idx] = readPoints(stat_cell,idx_cell)
%readPoints   Read manually-defined points from image
%   POINTS = READPOINTS(stat_cell,idx_cell) 
%   records the position of each click of button 1 of the mouse in the
%   current figure, and stops when another button is clicked. The track of points
%   is drawn as it goes along. The result is a 2 x NPOINTS matrix; each
%   column is [X; Y] for one point.
% 
%   INPUTS: stat_cell, is the structure with the statistics computed on the
%           cells. Input [] if you don't need to use within the cell image
%           idx_cell, is the array containing the indexes of the cells in in
%           matlab coords,so 1-based. Input [] if don't needed.
%

j=findall(gca,'Type','Text');
delete(j);

n = Inf;
pts = zeros(2, 1);
idx = zeros(1,1);

xold = 0;
yold = 0;
k = 0;
hold on;           % and keep it there while we plot
while 1
    [xi, yi, but] = ginput(1);      % get a point
    if ~isequal(but, 1)             % stop if not button 1
        delete(h)
        %delete(j)
        break
    end
    k = k + 1;
    pts(1,k) = xi
    pts(2,k) = yi
    
    for i=1:length(stat_cell)
        if ismember(round(yi),stat_cell{1,i}.ypix) && ismember(round(xi),stat_cell{1,i}.xpix)
            idx(1,k)=i;  
        end
    end

      if xold
          h(k)=plot([xold xi], [yold yi],'k.');  % draw. 'go-' to have the ----
      else
          h(k)=plot(xi, yi,'k.');         % first point on its own  
      end
      
      if length(idx_cell)>1
        j(k)=text(xi,yi,num2str(idx_cell(idx(1,k))-1),'FontSize',6,'Color',[0.3 0.7 0.9]);
      end
      
      if isequal(k, n)
          break
      end
      
      xold = xi;
      yold = yi;
end
hold off;

if k < size(pts,2)
    pts = pts(:, 1:k);
end
end