function VarianceHight(app)
%baseline elim
b=detrend(app.deltaFoFskew')';
b=app.deltaFoFskew-b;
deltaFoFbaseline=app.deltaFoFskew-b;

%variance calc
varianza=var(deltaFoFbaseline');
p80=prctile(varianza,80);
idxH=find(varianza>p80);
s2pidx=app.skewfilt_idx(idxH)-1;
varH=varianza(idxH);
skewH=app.skewlevel(idxH);

%app.TextC.String= string(a); 

end
