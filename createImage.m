function [img,type,img_idx]=createImage(fileName)
%image_idx= image with the index (in matlab 1 based coords) of the cells.
%
load(fileName);
type='';
%type = questdlg('What type of image?', 'Select', 'cell masks','neuropil masks','skewness','cell masks');

img     = NaN(ops.Ly,ops.Lx);


idx_cell = find(iscell(:,1)==1); %just taking the ROI classified as cells

%     %switch type
%      %   case 'cell masks'
%             disp('cell mask')
            im = NaN(ops.Ly,ops.Lx);
            for n=1:length(idx_cell)
                ypix = stat{idx_cell(n)}.ypix+1; %without overlapping pixels
                xpix = stat{idx_cell(n)}.xpix+1;
                ind  = sub2ind(size(im), ypix, xpix);
                im(ind)=idx_cell(n);
            end
            
%             
%         case 'neuropil masks'
%              disp('neuropil')
%              neumask = NaN(ops.Ly, ops.Lx); %image with neuropil masks
%              for n=1:length(idx_cell)   
%                  %Neuropil masks    
%                  [neux, neuy] = ind2sub(size(neumask),stat{idx_cell(n)}.neuropil_mask);
%                  idx=sub2ind(size(neumask),neuy,neux);
%                  neumask(idx) = 1;
% 
%              end
%              img=neumask;
%            
%         case 'skewness'
%            disp('skewness')
%            %skewness = zeros(1,length(idx_cell));
            im_skew = NaN(ops.Ly,ops.Lx); %image with skewness
            for n=1:length(idx_cell)
                ypix = stat{idx_cell(n)}.ypix+1; %without overlapping pixels
                xpix = stat{idx_cell(n)}.xpix+1;
                ind  = sub2ind(size(im_skew), ypix, xpix);
                im_skew(ind)= stat{idx_cell(n)}.skew;
                im(ind)=idx_cell(n);
            end
            img=im_skew;
            img_idx=im; %image with MATLAB indexes
                 
    %end


end