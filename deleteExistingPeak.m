
function  deleteExistingPeak(LineH,EventData,i,LineList,app)


xCoord=LineList.XData;
%yCoord=LineList.YData;
peak=app.peaksNew{i};
index=app.indexesNew{i};

id=find(index==xCoord);
peak(id)=[];
index(id)=[];
app.peaksNew{i}=peak;
app.indexesNew{i}=index;

set(LineList, 'Color', 'w');
set(LineH,    'Color', 'w');

end




 