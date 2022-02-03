function [indici,picchi]=PeaksDetector(sig,soglia)
%funzione che restituisce gli indici dei picchi(come vettore colonna) e il valore dei
%picchi (l'altezza) e plotta i picchi stessi
%sul segnale.
%inputs:
%segnale-> Funziona su segnali che hanno il valore medio in un valore compreso tra -1 e +1 circa.
%         IL PRIMO IF ELIMINA L'OFFSET DAL SEGNALE.
%soglia-> Cutoff sopra il quale il peak detector incomincia la ricerca di
%         picchi
%

L=length(sig);

if mean(sig)>1 || mean(sig)<-1
   sig=sig-floor(mean(sig));
end

% if mean(sig1)<-1
%     sig1=sig1-floor(mean(sig1));
% end

M=max(sig);
C=zeros(1,L);
ind=zeros(1,L);
count=0;



for i=1:L
    if sig(i)>=soglia*M
        C(i)=sig(i); %metto i valori del segnale in posizione pari al suo indice i
        count=count+1; % numero totale di valori sovrasoglia trovati
    end
end

if count==0
    msg='Lower the treshold';
    error(msg);
end

for i=1:L-1
if C(i)==0
    if C(i+1)~=0
    ind(1,i)=i+1;
    end
end
end
ind(ind==0)=[];

d=diff(ind);
if length(d)==0
    d=0;
end
distanza=floor(min(d)); %minimo n0 dei campioni presenti tra un campione diverso da 
                                 %zero e il successivo arrotondato al
                                 %valore + piccolo
                                 
                                 
distanzaultimo=L-ind(1,end);    %distanza tra lunghezza del segnale e primo campione
                                %dell'ultima sequenza di indici diversi da 0 
                               
if distanza>=distanzaultimo
    distanza=distanzaultimo;
end
%ho fatto questo perché se tra l'ultimo campione utile e la fine del
%segnale ho meno campioni rispetto alla media che generalmente li
%distanzia, andrei a fare un sottovettore pretendendo di prendere più
%elementi di quelli che ci sono, quindi se la distanza>distanzaultimo non
%posso aggiungere i campioni che in media ho tra i vari sottovettori
                                
riga=zeros(1,distanza); 
Mr=zeros(1,length(ind));
for i=1:length(ind)
    riga=C(ind(i):ind(i)+distanza);
    riga(riga==0)=[];
    cell(1,i)={riga};
    Mr(1,i)=max(riga);
end



indici=ones(1,L);
for i=1:L-1
   for j=1:length(Mr)
    if C(i)==Mr(j)
       indici(1,i)=i;
      
    end
   end
end

%correzione picchi sbagliati
indici(indici==1)=[];
if length(indici)-length(Mr)>0
d=diff(indici); %distanza tra indici
lind=length(indici); %lunghezza vettore indici
Piccosb=zeros(1,lind); %individuo il falso picco basandomi sulla distanza tra picchi

for i=1:lind-1
    if indici(i+1)-indici(i)< 0.8*mean(d)
        if C(indici(i))>C(indici(i+1))
        Piccosb(1,i+1)=indici(i+1);
        else
            Piccosb(1,i)=indici(i);
        end
    end
end
indici=indici-Piccosb; %elimino gli indici falsi
indici(indici==0)=[];
end


%modo per non plottare gli offset ma devi eliminare i campioni in più
indici=indici';
picchi=sig(indici);


end
