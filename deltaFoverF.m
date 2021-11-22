function deltaFoF = deltaFoverF(iscell,F,Fneu,correctionFactor,order,tStim)
%DELTAFOF
%The inputs needs to be passed in this order:
%1)iscell
%2)F       fluorescence trace
%3)Fneu    neuropil trace
%OPTIONAL PARAMETERS:
%4)alpha   to use in Fcorrected=F-alpha*Fneu. If not specified alpha=0.7 as
%          in Suite2p
%5)order   order of the median filter, default=5
%6)tStim   time of drug application/stimuli,if you introduced one.


if nargin <3
    disp("Error,not enough input parameters");
end
if nargin==3
    correctionFactor=0.7;
    order=5;
    tStim=size(F,2);
    
end
if nargin==4
    order=5;
    tStim=size(F,2);
    
end
if nargin==5
    tStim=size(F,2);
end

order
idx_cell=find(iscell(:,1)==1);      %trovo indici delle cellule 
Fcorrected=F(idx_cell,:)-correctionFactor*Fneu(idx_cell,:); %correggo neuropil
Fcorrected_filt= medfilt1(Fcorrected',order)';
%Fcorrected_filt=Fcorrected;

%dF/F **per ogni ROI** 
F0=mean(Fcorrected_filt(:,1:tStim-1)')';    %vettore delle medie per ogni ROI (1 ROI =1 riga)

deltaFoF=(Fcorrected_filt-F0);            %prova fatta col loop
deltaFoF=deltaFoF./F0;



end

