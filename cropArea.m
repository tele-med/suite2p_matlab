function copyImage=cropArea(copyImage)
type = questdlg('Cropping', 'Type:', 'exclude an area','keep an area','keep an area');
switch type
    case 'exclude an area'
        
        h = drawrectangle; %draw something 
        M = h.createMask();
        copyImage(M) = NaN;
        

    case 'keep an area'
        
        h = drawfreehand; %draw something 
        M = ~h.createMask();
        copyImage(M) = NaN;
        
end
        
end