function istogramma(app)

start=app.start;
stop=app.stop;
tF=app.tF-start+1;
tL=app.tL-start+1;
dFoverF=deltaFoverF(app.in.iscell,app.in.F,app.in.Fneu,app.correctionFactor,app.order,tF);
dFoverF=dFoverF(:,start:stop);
m=mean(dFoverF(:,tL-app.fs*60:tL)')';  




figure('Name', 'Histogram of the excitation levels');  
edges = [0 10 20 30 40 50 60 70 80 90 100];
edges=edges/100*app.calibrationValueH;

for i=1:length(edges)-1
    iL=edges(i);
    iH=edges(i+1);
    v{i}=find(m>=iL & m<iH);
end


hH = histogram(m,edges);
%hH.BinEdges = [0:app.calibrationValueH];
hH.ButtonDownFcn = @(obj,event)clickHistFcn(hH,event,v,app); 



figure('Name', 'Histogram of the inhibition levels');  
edges = [100 90 80 70 60 50 40 30 20 10 0];
edges=edges/100*app.calibrationValueL;

for i=1:length(edges)-1
    iL=edges(i);
    iH=edges(i+1);
    v{i}=find(m>=iL & m<iH);
end

hL = histogram(m,edges);
% hL.BinEdges = [0:app.calibrationValueL];
hL.ButtonDownFcn = @(obj,event)clickHistFcn(hL,event,v,app); 
end
