%clear all;
close all; drawnow;
p = setParameters;
quickcheck = 1;
if quickcheck == 1
    numContrasts = 9;
else
    numContrasts = 25;
end
cRange = [.01 1];

% Pick contrasts
logCRange = log10(cRange);
logContrasts = linspace(logCRange(1),logCRange(2),numContrasts);
contrasts = 10.^logContrasts;
contrasts_mask = ones(1,numContrasts)*cRange(2);

baselineUnmod = 0;
alpha = 1;
n     = p.p(1);
nLay  = 5;
sigma_mon = p.sigma(1);
sigma_bin = p.sigma(3);
sigma_opp = p.sigma(5);
w_int     = p.w_int;
attG      = 1;

iA_amp_opts = {[0 0]; [0 1]; [1 1]}; 
iB_amp_opts = {[1 0]; [1 0]; [1 1]}; 
%A and B are two orientation channels

%% Run Monocular Layers First and then Run Summation Layers
for cond = 1:2
    
    %% Define Input(stimuli) for monocular layers
    for lay = 1:2
        iA{lay} = iA_amp_opts{cond}(lay)*contrasts_mask;
        iB{lay} = iB_amp_opts{cond}(lay)*contrasts;
    end
    
    %Get Excitation for monocular layers
    for lay = 1:2
        %defining inputs (stimulus and recurrent connections)
        if lay==1     %left eye
            inpA = iA{lay};
            inpB = iB{lay};
        elseif lay==2 %right eye
            inpA = iA{lay};
            inpB = iB{lay};
        end
        eA{lay} = halfExp(inpA, n);
        eB{lay} = halfExp(inpB, n);
    end
    
    %Get Suppresion and Normalization for each monocular layer
    for lay = 1:2
        switch lay
            case 1
                sigma = halfExp(ones(1, numContrasts)*sigma_mon,n);
                pool = [eA{1}; eB{1}; eA{2}*w_int; eB{2}*w_int; sigma];
            case 2
                sigma = halfExp(ones(1, numContrasts)*sigma_mon,n);
                pool = [eA{1}*w_int; eB{1}*w_int; eA{2}; eB{2}; sigma];
        end
        
        %Normalization
        ieA{lay}=sum(pool);
        ieB{lay}=sum(pool);
        isA{lay}=zeros(1, numContrasts);
        isB{lay}=zeros(1, numContrasts);
        
        rA{lay} = alpha*attG*eA{lay} ./ (attG*ieA{lay} + isA{lay} ) + baselineUnmod;
        rB{lay} = alpha*attG*eB{lay} ./ (attG*ieB{lay} + isB{lay} ) + baselineUnmod;
    end
    
    %plot
    figure(1)
    set(gcf,'Name','Monocular Layers')
    for lay = 1:2
        switch cond
            case 1
                lstyle='-';
                leg{cond}='Att';
            case {2,3}
                lstyle='--';
                leg{cond}='InAtt';
        end
        subplot(1,2,lay)
        hold on;
        h(cond, lay) = plot(log10(contrasts), rA{lay}, '-o', 'color',[1 0 1]);
        h(cond, lay) = plot(log10(contrasts), rB{lay}, '-o', 'color',[0 0 1]);
        set(h(cond, lay), 'LineStyle',lstyle)
        set(h(cond, lay), 'LineStyle',lstyle)
        set(gca,'YLim', [0 1]);
        xlabel('Contrast','FontSize',14)
        ylabel('Firing Rating','FontSize',14)
        %legend(p1, leg, 'Location', 'Best')
    end
    
    
    %% Get input and excitation for summation layer
    for lay = 3
        inpA = rA{1} + rA{2};
        inpB = rB{1} + rB{2};
        
        eA{lay} = halfExp(inpA, n);
        eB{lay} = halfExp(inpB, n);
    end
    
    %Get Suppression for summation layer
    sigma = halfExp(ones(1, numContrasts)*sigma_bin,n);
    
    %Normalization
    ieA{lay}=eA{lay} + sigma;
    ieB{lay}=eB{lay} + sigma;
    isA{lay}=zeros(1, numContrasts);
    isB{lay}=zeros(1, numContrasts);
    
    rA{lay} = alpha*attG*eA{lay} ./ (attG*ieA{lay} + isA{lay} ) + baselineUnmod;
    rB{lay} = alpha*attG*eB{lay} ./ (attG*ieB{lay} + isB{lay} ) + baselineUnmod;
    
    %plot
    figure(2)
    set(gcf,'Name','summation Layers')
    for lay = 3
        switch cond
            case 1
                lstyle='-';
            case 2
                lstyle='--';
        end
        hold on;
        h(cond, lay) = plot(log10(contrasts), rA{lay}, '-o', 'color',[1 0 1]);
        h(cond, lay) = plot(log10(contrasts), rB{lay}, '-o', 'color',[0 0 1]);
        set(h(cond, lay), 'LineStyle',lstyle);
        set(gca,'YLim', [0 1]);
        xlabel('Contrast','FontSize',14)
        ylabel('Firing Rating','FontSize',14)
        %set(p(cond, lay), 'LineStyle',lstyle)
    end
    figure(3)
    set(gcf,'Name','summation Layers: E and I')
    subplot(1,2,1)
    for lay = 3
        switch cond
            case 1
                lstyle='-';
            case 2
                lstyle='--';
        end
        hold on;
        h(cond, lay) = plot(log10(contrasts), eA{lay}, '-o', 'color',[1 0 1]);
        h(cond, lay) = plot(log10(contrasts), eB{lay}, '-o', 'color',[0 0 1]);
        set(h(cond, lay), 'LineStyle',lstyle);
        set(gca,'YLim', [0 1]);
        xlabel('Contrast','FontSize',14)
        ylabel('Firing Rating','FontSize',14)
        %set(p(cond, lay), 'LineStyle',lstyle)
    end
        subplot(1,2,2)
    for lay = 3
        switch cond
            case 1
                lstyle='-';
            case 2
                lstyle='--';
        end
        hold on;
        h(cond, lay) = plot(log10(contrasts), ieA{lay}, '-o', 'color',[1 0 1]);
        h(cond, lay) = plot(log10(contrasts), ieB{lay}, '-o', 'color',[0 0 1]);
        set(h(cond, lay), 'LineStyle',lstyle);
        %set(gca,'YLim', [0 1]);
        xlabel('Contrast','FontSize',14)
        ylabel('Firing Rating','FontSize',14)
        %set(p(cond, lay), 'LineStyle',lstyle)
    end
    
    
    %% Get input and excitation for Opponency layer
    for lay = 4:5
        
        if lay == 4 %opponency layer (left-right)
            inpA = rA{1} - rA{2};
            inpB = rB{1} - rB{2};
        elseif lay == 5 %%opponency layer (right-left)
            inpA = rA{2} - rA{1};
            inpB = rB{2} - rB{1};
        end
        
        eA{lay} = halfExp(inpA, n);
        eB{lay} = halfExp(inpB, n);
    end
    
    %Get Suppression for each opponency layer
    for  lay = 4:5
        sigma = halfExp(ones(1, numContrasts)*sigma_opp,n);
        pool = [eA{4}; eB{4}; eA{5}; eB{5}; sigma];
        %Normalization
        ieA{lay}=sum(pool);
        ieB{lay}=sum(pool);
        isA{lay}=zeros(1, numContrasts);
        isB{lay}=zeros(1, numContrasts);
        
        rA{lay} = alpha*attG*eA{lay} ./ (attG*ieA{lay} + isA{lay} ) + baselineUnmod;
        rB{lay} = alpha*attG*eB{lay} ./ (attG*ieB{lay} + isB{lay} ) + baselineUnmod;
        
    end
    
    %plot
    figure(4)
    set(gcf,'Name','Opponency Layers')
    for lay = 4:5
        switch cond
            case 1
                lstyle='-';
                leg{cond}='Att';
            case 2
                lstyle='--';
                leg{cond}='InAtt';
        end
        subplot(1,2,lay-3)
        hold on;
        h(cond, lay) = plot(log10(contrasts), rA{lay}, '-o', 'color',[1 0 1]);
        h(cond, lay) = plot(log10(contrasts), rB{lay}, '-o', 'color',[0 0 1]);
        set(h(cond, lay), 'LineStyle',lstyle);
        set(h(cond, lay), 'LineStyle',lstyle);
        set(gca,'YLim', [0 1]);
        xlabel('Contrast','FontSize',14)
        ylabel('Firing Rating','FontSize',14)
        %legend(p1, leg, 'Location', 'Best')
    end
    
end







%         %Small Stimuli, stimuli within the attention field
%         figure; cla;
%         subplot(1,2,1)
%         Cs=contrasts*0;
%         E=halfExp(C,n);
%         Ie=halfExp([C],n);
%         Is=halfExp([Cs],n);
%         sigma=halfExp(C50, n);
%
%         attG=1;
%         R = alpha*attG*E ./ (attG*Ie + Is + sigma) + baselineUnmod;
%         semilogx(contrasts, R, '-o'); hold on;
%
%         attG=.7;
%         R = alpha*attG*E ./ (attG*Ie + Is + sigma) + baselineUnmod;
%         semilogx(contrasts, R, '-ro'); hold on;
%         ylim([0 alpha+.1]);
%
%         %Large Stimuli, stimuli extend out of the attention field
%         subplot(1,2,2)
%         Cs=contrasts*.6;
%         E=halfExp(C,n);
%         Ie=halfExp([C],n);
%         Is=halfExp([Cs],n);
%         sigma=halfExp(C50, n);
%
%         attG=1;
%         R = alpha*attG*E ./ (attG*Ie + Is + sigma) + baselineUnmod;
%         semilogx(contrasts, R, '-o'); hold on;
%
%         attG=.7;
%         R = alpha*attG*E ./ (attG*Ie + Is + sigma) + baselineUnmod;
%         semilogx(contrasts, R, '-ro'); hold off;
%         ylim([0 alpha+.1]);

