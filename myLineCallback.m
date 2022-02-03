
function myLineCallback(LineH, EventData, LineList,app)

app.IDX=(find(LineList == LineH));  % Index of the active line in the list
app.Line=LineList;
set(LineList, 'LineWidth', 0.5);
set(LineH,    'LineWidth', 2.5);

end