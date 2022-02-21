function [init,fin]=intervals(app,interval)
init=1;
fin=size(app.in.F,2);
if strcmp(interval,'all')==0
    interval=split(interval,',');
    init=str2double(interval(1));
    fin=str2double(interval(2));
    if isnan(fin)==1
        fin=length(app.in.F);
    end
    app.in.F=app.in.F(:,init:fin);
    app.in.Fneu=app.in.Fneu(:,init:fin);
    app.in.spks=app.in.spks(:,init:fin);
end
end