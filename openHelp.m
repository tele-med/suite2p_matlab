function openHelp(filename)
    txt=uitextarea();
    pos=txt.Parent.Position;
    pos([1,2])=0;
    txt.Position=pos;
    fid=fopen(filename);
    while ~feof(fid)
        tline = fgetl(fid);
        txt.Value=[txt.Value;tline];
    end
    fclose(fid);

end