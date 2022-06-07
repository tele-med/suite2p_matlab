function closeFig
fig = uifigure('Position',[100 100 425 275]);
fig.CloseRequestFcn = @(src,event)my_closereq(src);

    function my_closereq(fig)
        selection = uiconfirm(fig,'Close the figure window?',...
            'Confirmation');
        
        switch selection
            case 'OK'
                delete(fig)
            case 'Cancel'
                return
        end
    end

end