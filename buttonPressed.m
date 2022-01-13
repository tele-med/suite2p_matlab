function buttonPressed(hFig,button,stat_cell,deltaFoF,idx_cell,t)

[points,idx]=readPoints(stat_cell,idx_cell);

l=cell(1,size(points,2));

figure
for k=1:size(points,2)
    l{1,k}=num2str(idx_cell(idx(1,k))-1);
    hold on
    plot(t,deltaFoF(idx(1,k),:))
    hold on
end
xlabel('time[min]')
ylabel('Fluorescence dF/F')
legend(l);

end

