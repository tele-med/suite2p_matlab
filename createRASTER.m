function createRASTER(deltaFoFskew,skewfilt_idx,ops,stat)
%createRASTER
%Function that creates the RASTER.mat file.
%INPUTS: deltaFoFskew trace of just the skew filtered cells(help deltaFoverF to find the function)
%        cellskew_idx   indexes from suite2p of just the skew filtered cell
%        ops
%        stat
%OUTPUTS:For T imaging frames and N ROIs, a .mat file with the _RASTER.mat suffix contains the following variables:
%        deltaFoF:              a T x N matrix of the ?F/F0 time series of all ROIs.
%        raster:                a T x N matrix. For each column (i.e., each ROI), it is filled either with zeros for frames with 
%                               non-significant fluorescent transients or with the ?F/F0 values of the frames with significant transients. 
%                               If the user does not wish to plot significant trial responses in the response analysis module, or if all the 
%                               ?F/F0 values should be considered in the module for the detection of the assemblies (instead of only 
%                               the significant transients), it should be a T x N matrix filled with ones.
%        movements:             T x 1 binary array, with ones for frames where an imaging artifact was found,
%                               and otherwise zeros.
%        dataAllCells.avg:      average image of the imaging file, showing the anatomy of the imaged plane.
%        dataAllCells.cell_per: an Nx1 cell array, containing the perimeter coordinates for each ROI.
%        dataAllCells.cell:     a 1 x N cell array, containing the pixel indexes of each ROI
%
%
%

prompt = {'Enter the suffix of the suffix_RASTER.m file:'};
dlgtitle = 'Choose name';
dims = [1 50];
definput = {'prova'};
fileName = inputdlg(prompt,dlgtitle,dims,definput);
fileName = strcat(fileName{1},'_RASTER.mat');

%deltaFoverF
deltaFoF=deltaFoFskew';

%raster
raster=ones(size(deltaFoF));

%movements
movements=zeros(size(deltaFoF,2),1);

%dataAllcells
%meanImage
dataAllCells.avg=ops.meanImg;

%perimeters & cell indexes
idx_cell=skewfilt_idx; %just taking the ROI classified as cells

dataAllCells.cell_per=cell(size(idx_cell)); %cell-array
dataAllCells.cell=cell(size(idx_cell))';
%im_cells=zeros(ops.Ly,ops.Lx);
for n=1:length(idx_cell)
    im=zeros(ops.Ly,ops.Lx); %image with cell masks
    ypix = stat{idx_cell(n)}.ypix(stat{idx_cell(n)}.overlap==0)+1; %without overlapping pixels
    xpix = stat{idx_cell(n)}.xpix(stat{idx_cell(n)}.overlap==0)+1;
    ind  = sub2ind(size(im), ypix, xpix);
    im(ind)= 1;
    imP=bwperim(im);
    %im_cells(ind)=n+1;
    dataAllCells.cell{n}=[xpix,ypix];
    [ypix,xpix]=ind2sub(size(im),find(imP==1));
    dataAllCells.cell_per{n,1}=[xpix,ypix];
end

%imshow(im_cells)
save(fileName, 'deltaFoF', 'raster', 'movements', 'dataAllCells');
end