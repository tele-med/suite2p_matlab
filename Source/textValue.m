function textValue
% Create figure and components.

fig = uifigure('Position',[100 100 366 270]);


lbl = uilabel(fig,...
      'Position',[130 100 100 15]);

txt = uieditfield(fig,...
      'Position',[100 175 100 22],...
      'ValueChangedFcn',@(txt,event) textChanged(txt,lbl));
end

% Code the callback function.
function textChanged(txt,lbl)
lbl.Text = txt.Value;
end