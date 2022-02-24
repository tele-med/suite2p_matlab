
function myLineCallback(LineH, EventData, LineList,app)

app.IDX=(find(LineList == LineH));
% Index of the active line in the list
app.Line=LineList;
set(LineList, 'LineWidth', 0.5);
set(LineH,    'LineWidth', 2.5);

str=append('All cells dF/F traces-Selected cell:',string(app.idx_cell(app.IDX)-1));
title(str,'Parent',app.ax2)
end