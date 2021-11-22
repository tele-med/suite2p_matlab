function [pts,idx] = readPoints(stat_cell,idx_cell)
%readPoints   Read manually-defined points from image
%   POINTS = READPOINTS(IMAGE) displays the image in the current figure,
%   then records the position of each click of button 1 of the mouse in the
%   figure, and stops when another button is clicked. The track of points
%   is drawn as it goes along. The result is a 2 x NPOINTS matrix; each
%   column is [X; Y] for one point.
% 
%   POINTS = READPOINTS(N) reads up to N points only.

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
    pts(1,k) = xi;
    pts(2,k) = yi;
    
    for i=1:length(stat_cell)
        if ismember(round(yi),stat_cell{1,i}.ypix) && ismember(round(xi),stat_cell{1,i}.xpix)
            idx(1,k)=i;  
        end
    end

      if xold
          h(k)=plot([xold xi], [yold yi], 'go');  % draw. 'go-' to have the ----
          j(k)=text(xi,yi,num2str(idx_cell(idx(1,k))-1),'FontSize',6);%text(xi,yi,num2str(k));
      else
          h(k)=plot(xi, yi, 'go');         % first point on its own
          j(k)=text(xi,yi,num2str(idx_cell(idx(1,k))-1),'FontSize',6);
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