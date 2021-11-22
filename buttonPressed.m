function buttonPressed(hFig,button,stat_cell,deltaFoF,idx_cell)

[points,idx]=readPoints(stat_cell,idx_cell);

l=cell(1,size(points,2));

figure
for k=1:size(points,2)
    l{1,k}=num2str(idx_cell(idx(1,k))-1);
    hold on
    plot(deltaFoF(idx(1,k),:))
    hold on
end

legend(l);



end

