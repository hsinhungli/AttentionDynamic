% Plot the simulation of Levelt's Proposition. (The scheme by Moreno-Bote,
% 2010 JoV)

datafolder = './Data';
condIdx    = '1';
fileIdx    = '10070021';
fileName   = sprintf('%s/cond_%s_%s.mat',datafolder,condIdx,fileIdx);
load(fileName);
nsim = length(p_pool);
condnames  =  {'B/A','B/iA','P/A','P/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
%% Dominance duration: this is for the experiment that vary contrasts

filter_duration = 100;
threshold_ratio = 2;
threshold_t =  0;

nsim = length(p_pool);
for i = 1:nsim
    tempp = p_pool{i};
    tempp = getIndex(tempp,filter_duration,threshold_t,threshold_ratio);
    p_pool{i} = tempp;
end

for i = 1:nsim
    domDuration(i,:) = p_pool{i}.Idx_domD;
    contrast(i,:)    = p_pool{i}.contrast;
    fraction(i)      = domDuration(i,1) / sum(domDuration(i,:));
end
domDuration(isnan(domDuration)) = 0;
cpsFigure(.5,.5)
plot(fraction, domDuration(:,1), '-o',fraction, domDuration(:,2) ,'-o')
% ylim([0 10])
% xlim([0 1])
xlabel('Fraction A','FontSize',14)
ylabel('Mean duration (s)','FontSize',14)
legend({'A: varied','B: fixed'},'FontSize',14)

cpsFigure(.5,.5)
plot(contrast(:,1), fraction,'-o')
ylim([0 1])
%xlim([0 1])
xlabel('Contrast A','FontSize',14)
ylabel('Fraction A','FontSize',14)
legend({'A: varied'})
%% Plot dominance duration distributaion for each simulated condition 
% Better suited for system with noise.
cpsFigure(.6*nsim,.6);
for i = 1:nsim
    subplot(1,nsim,i)
    hist(p_pool{i}.durationDist_v,50);
    Xlim = get(gca,'XLim');
    Ylim = get(gca,'YLim');
    temp_text = sprintf('domD: %2.2f',mean(p_pool{i}.durationDist_v));
    text(Xlim(2)*.5,Ylim(2)*.7, temp_text)
    temp_text = sprintf('CV: %2.2f',p_pool{i}.Idx_cv_v);
    text(Xlim(2)*.5,Ylim(2)*.6, temp_text)
    temp_text = sprintf('valid: %2.2f',p_pool{i}.Idx_ptime_v);
    text(Xlim(2)*.5,Ylim(2)*.5, temp_text)
end
tightfig;

% %%
% cpsFigure(.6*nsim,.6);
% 
% Idx_wta = nan(1,nsim);
% for i = 1:nsim
%     Idx_wta(i) = p_pool{i}.Idx_wta;
% end
% subplot(1,5,2)
% bar(Idx_wta);
% title('WTA Index')
% 
% Idx_diff = nan(1,nsim);
% for i = 1:nsim
%     Idx_diff(i) = p_pool{i}.Idx_diff;
% end
% subplot(1,5,3)
% bar(Idx_diff);
% title('diff Index')
% 
% Idx_ratio = nan(1,nsim);
% for i = 1:nsim
%     Idx_ratio(i) = p_pool{i}.Idx_ratio;
% end
% subplot(1,5,4)
% bar(Idx_ratio);
% title('ratio Index')
% 
% Idx_mean = nan(1,nsim);
% for i = 1:nsim
%     Idx_mean(i) = p_pool{i}.Idx_mean;
% end
% subplot(1,5,5)
% bar(Idx_mean);
% title('mean Index')
% %tightfig;
