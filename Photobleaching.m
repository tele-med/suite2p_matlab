classdef Photobleaching <handle
    
    properties
        
        RButton
        ButtonConfirm
        ax
        taglio
        YL
        YE
        Y
 
    end
    
    methods
        function cl=Photobleaching(parent)
            f=figure('Name','Photobleaching Correction','Position',[100 200 900 400]);
            
            media=mean(parent.deltaFoFCut);
            subplot(2,2,[1,3])
            plot(parent.t,media,'--');
            hold on
            title('mean(dF/F)')
            xlabel('t')
            ylabel('dF/F')
            cl.ax=gca;
            
            %Default è un bottone che, se cliccato, mi fa deltaFoverF-baselineDefault
            %Linear è un bottone che, se cliccato, mi fa deltaFoverF-baselineLinear
            time=parent.t;
            inizio=parent.tF; %inizio della risposta al farmaco
            fine=parent.tL; %fine della risposta al farmaco
            L=parent.stop; %ultimo campione del segnale
            L=L-fine; %numero campioni tra fine risposta e fine segnale
            L=round(0.75*L);
            fine=fine+L; %considero come fine della risposta non il momento del lavaggio, 
                         %ma il momento in cui è già avvenuto il 75% del tratto da tL
                         %alla fine del segnale.
            pad=fine-inizio-1;
            media=mean(parent.deltaFoF); %ricalcolo la media su tutto il segnale
            cl.taglio=[media(1,parent.start:inizio),media(1,fine:parent.stop)];    
            M=mean(cl.taglio);
            cl.taglio=[media(1,parent.start:inizio),M*ones(1,pad),media(1,fine:parent.stop)]';
            cl.YE=expsmooth(cl.taglio,1,100);
            cl.Y=cl.YE;

            subplot(2,2,2);
            plot(time,cl.taglio,'y')
            hold on
            plot(time,cl.YE)
            title('Exponential Approximation of the baseline')
            xlabel('t')
            ylabel('dF/F')

            uicontrol('Parent',f,'Style','pushbutton','String','Linear Approximation',...
                            'Position',[120,1,100,20],'Units','normalized','Visible','on',...
                            'CallBack',@(ButtonK,event)pointSelection(cl,time));

            cl.RButton=uicontrol('Parent',f,'Style','popupmenu','String',{'Exponential','Linear'},...
                            'Position',[600,10,100,20],'Units','normalized','Visible','on',...
                            'Callback',@(s,e)selection(cl));
            cl.ButtonConfirm=uicontrol('Parent',f,'Style','pushbutton','String','Confirm',...
                            'Position',[700,10,100,20],'Units','normalized','Visible','on',...
                            'Callback',@(s,e)confirm(cl,parent));
        end

        function pointSelection(cl,time)
            [x,y] = getpts(cl.ax);
            m=(y(2)-y(1))/(x(2)-x(1));
            q=y(1)-m*x(1);
            cl.YL=m*time+q;
            subplot(2,2,4)
            plot(time,cl.taglio,'y')
            hold on
            plot(time,cl.YL)
            title('Linear Approximation of the baseline')
            xlabel('t')
            ylabel('dF/F')
        end

        function selection(cl)
            value = cl.RButton.Value;
            str = cl.RButton.String;
            type=str{value};
            
            switch type
                case 'Exponential'
                    cl.Y=cl.YE;
                    disp('Esponential Photobleaching correction')
                case 'Linear'
                    cl.Y=cl.YL;
                    disp('Linear Photobleaching correction')
            end
        end

        function confirm(cl,parent)
            if size(parent.deltaFoFCut,2)==size(cl.Y,2)
                pb=cl.Y;
            else
                pb=cl.Y';
            end
                parent.deltaFoFCut=parent.deltaFoFCut-pb;
                parent.deltaFoF=parent.deltaFoFCut;
                
                media=mean(parent.deltaFoF);
                
                plot(cl.ax, parent.t,media);
            
        end
            

    end
end
