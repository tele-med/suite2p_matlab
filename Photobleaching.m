figure
subplot(2,2,[1,3])
plot(mean(deltaFoF));
ax=gca;
%chiedi: vuoi stimare la baseline? se sì parte il tool, se no parte
%l'approccio normale

%Nel tool apro lo schermo, in cui metto a destra mean(deltaFoF) cliccabile e a sinistra 2 plot
%nel subplot in alto metto il fitting esponenziale, nel subplot in basso
%metto il fitting che fa Elda
%Default è un bottone che, se cliccato, mi fa deltaFoverF-baselineDefault
%Linear è un bottone che, se cliccato, mi fa deltaFoverF-baselineLinear

inizio=app.tF; %inizio della risposta al farmaco
fine=app.tL; %fine della risposta al farmaco
L=length(deltaFoF);
L=L-fine; %numero campioni tra fine risposta e fine segnale
L=round(0.75*L);
fine=fine+L; %considero come fine della risposta non il momento del lavaggio, 
             %ma il momento in cui è già avvenuto il 75% del tratto da tL
             %alla fine del segnale.
pad=fine-inizio-1;
taglio=[media(1:inizio,1);media(fine:end,1)];    
M=mean(taglio);
taglio=[media(1:inizio,1);M*ones(pad,1);media(fine:end,1)];
Y=expsmooth(taglio,1,100);

subplot(2,2,2);
plot(taglio,'y')
hold on
plot(Y)


[x,y] = getpts(ax);

m= (y(2)-y(1))/(x(2)-x(1));
q= y(1)-m*x(1);
time=0:1/fs:size(deltaFoF,2)/fs;
time(end)=[];
time=time/60;
coord=time;
YL=m*coord+q;

subplot(2,2,4)
plot(time,taglio,'y')
hold on
plot(time,YL)


%Invece quando devo selezionare 2 punti 
