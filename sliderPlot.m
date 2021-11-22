function mantain=sliderPlot(A,idxS2p)
figure
panel1 = uipanel('Parent',1);
panel2 = uipanel('Parent',panel1);
textA=uicontrol('Parent',panel2,'Style','edit','Visible','on','Position',[10 800 200 20],...
                'String','Indexes to mantain separated by commas',...
                'CallBack',@(textA,event) textChanged(textA));
set(panel1,'Position',[0 0 0.95 1]);
set(panel2,'Position',[0 -1 1 2]);
set(gca,'Parent',panel2);
for i=1:size(A,1)
    sign=A(i,:)+i;
    hold on
    plot(sign); % replace your stack plot fucntion here
    hold on
    x=round(length(sign)/3);
    y=i;
    text(x,y,idxS2p(i,:));
    hold on
end

s = uicontrol('Style','Slider','Parent',1,...
      'Units','normalized','Position',[0.95 0 0.05 1],...
      'Value',1,'Callback',{@slider_callback1,panel2});

    function slider_callback1(src,eventdata,arg1)
        val = get(src,'Value');
        set(arg1,'Position',[0 -val 1 2])
    end

    function textChanged(textA)
        mantain=str2double(split(textA.String,','));
    end

end