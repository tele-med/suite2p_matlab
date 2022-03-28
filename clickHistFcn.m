function clickHistFcn(hObj,event,v,app)
% Get the bar edges and click coordinate
edges = hObj.BinEdges; 
click = event.IntersectionPoint;
% Determine which bar was clicked
barIdx = find(click(1) >= edges, 1, 'last');
% Do whatever you want with that....
fprintf('bar %d selected.\n',barIdx);

v(barIdx);


f=figure();
indexes=v{barIdx}(:);
if length(indexes)>1
    m=mean(app.deltaFoFCut(indexes,:));
else
    m=app.deltaFoFCut(indexes,:);
end
plot(app.t,m);
xlabel('time')
ylabel('mean dF/F of the highlighted cells')

suite2p=app.idx_cell(indexes)-1;

id=round(length(suite2p)/3);
text(0,double(max(m)),{num2str(suite2p(1:id)'),num2str((suite2p(id+1:2*id))'),num2str((suite2p(2*id+1:end))')},'FontSize',7,'Color','r');
disp(suite2p)


end

