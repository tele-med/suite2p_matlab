function textChangedFirstVersion(txt,fig,skew,imageSF)
%textChanged Summary of this function goes here
% Code the callback function.

levelSkew=str2double(txt.String);
s=skew; %s=image of the skewness filtered cells
s(s<=levelSkew)=NaN;
figure(fig.Number)
axes=gca(fig);
imh = imhandles(axes); %gets your image handle if you dont know it
set(imh,'CData',s);

imageSF=imh.CData;

colorbar%('Ticks',[levelSkew,2.5],'TickLabels',{txt.String,'2.5'});
%set(get(c,'Title'),'String','Skewness')
caxis([levelSkew 2.5]) 



end

