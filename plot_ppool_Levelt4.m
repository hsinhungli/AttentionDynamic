% Extract the index from simulated data and plot the index.
% CV: .4-.6; Dominance duration: 1-10 sec (Shpiro et al., 2009)
clear all;
%close all;
datafolder = './Data';
condIdx    = '1';
fileIdx    = '10101700';
fileName   = sprintf('%s/cond_%s_%s.mat',datafolder,condIdx,fileIdx);
load(fileName);
condnames  =  {'B/A','B/iA','M/A','M/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
subplotlocs  = [4 6 2 1 3]; %on a 2x3 plot

%% Plot the simulated time series
ncond = numel(p_pool);
for cond = 1:ncond
    
    p = p_pool{cond};
    plotduration = 30*1000;
    pIdx = p.tlist<plotduration;
    
    cpsFigure(1,.4); hold on;
    title(sprintf('SummationL contrast:%2.3f  %2.3f',p_pool{cond}.contrast(1),p_pool{cond}.contrast(2)));
    %imagesc(p.tlist(pIdx)/1000,.5,p.phaseIdx)
    colormap([.8 .65 .65;.65 .65 .8;])
    lay = 3;
    temp1 = squeeze(p.r{3}(1,:));
    temp2 = squeeze(p.r{3}(2,:));
    plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
    plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
    xlim([0 max(p.tlist(pIdx)/1000)])
    ylim([0 max([temp1(:)' temp2(:)'])+.1])
    set(gca,'FontSize',12)
    
%     subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
%     cpsFigure(2,.8);
%     set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p.cond}, p.contrast(1), p.contrast(2)));
%     for lay = 1:p.nLayers
%         subplot(2,3,subplotlocs(lay))
%         cla; hold on;
%         if lay==4
%             temp1 = squeeze(p.inh{1}(1,:))*p.w_opp;
%             temp2 = squeeze(p.inh{1}(1,:))*p.w_opp;
%             ptemp = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[0 0 0]);
%         elseif lay==5
%             temp1 = squeeze(p.inh{2}(1,:))*p.w_opp;
%             temp2 = squeeze(p.inh{2}(1,:))*p.w_opp;
%             ptemp = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[0 0 0]);
%         else
%             temp1 = squeeze(p.r{lay}(1,:));
%             temp2 = squeeze(p.r{lay}(2,:));
%             pL = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[1 0 1]);
%             pR = plot(p.tlist(pIdx)/1000,temp2(pIdx),'color',[0 0 1]);
%         end
%         ylabel('Firing rate')
%         xlabel('Time (s)')
%         title(layernames(lay))
%         set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])]);
%         drawnow;
%     end
%     subplot(2,3,5)
%     plot(p.tlist(pIdx)/1000,p.att(1,pIdx),'color',[1 0 1]); hold on;
%     plot(p.tlist(pIdx)/1000,p.att(2,pIdx),'color',[0 0 1]);
%     title('Attention')
%     tightfig;
    
    %% Draw time sereis_2
    %             cpsFigure(1,1.5);
    %             set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p.cond}, p.contrast(1), p.contrast(2)));
    %
    %             %To view the two rivarly time series
    %             subplot(4,1,1);hold on
    %             title('Summation Layer')
    %             %imagesc(p.tlist(pIdx)/1000,.5,p.phaseIdx)
    %             colormap([.8 .65 .65;.65 .65 .8;])
    %             lay = 3;
    %             temp1 = squeeze(p.r{lay}(1,:));
    %             temp2 = squeeze(p.r{lay}(2,:));
    %             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
    %             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
    %             xlim([0 max(p.tlist(pIdx)/1000)])
    %             ylim([0 max([temp1(:)' temp2(:)'])+.1])
    %             set(gca,'FontSize',12)
    %
    %             %Left eye
    %             subplot(4,1,2);hold on
    %             title(sprintf('LE contrast:%2.4f',p_pool{cond}.contrast(1)))
    %             lay=1;
    %             temp1 = squeeze(p.r{lay}(1,:));
    %             temp2 = squeeze(p.r{lay}(2,:));
    %             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
    %             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
    %             xlim([0 max(p.tlist(pIdx)/1000)])
    %             ylim([0 max([temp1(:)' temp2(:)'])+.1])
    %
    %             %Right eye
    %             subplot(4,1,3);hold on
    %             title(sprintf('RE contrast:%2.4f',p_pool{cond}.contrast(2)))
    %             lay=2;
    %             temp1 = squeeze(p.r{lay}(1,:));
    %             temp2 = squeeze(p.r{lay}(2,:));
    %             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r:','LineWidth',1)
    %             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b:','LineWidth',1)
    %             xlim([0 max(p.tlist(pIdx)/1000)])
    %             ylim([0 max([temp1(:)' temp2(:)'])+.1])
    %             xlabel('Time (sec)', 'FontSize',12)
    %             tightfig;
    %             drawnow;
end

%% smooth the simualted time series. 
% This is mailny for computing the dominance duration when noise is added
% in simulation. Some smoothing can combine the dominance duration that is
% extremely short and might not be meaningful to reflect perceptual report.

filter_duration = 100;
threshold_ratio = 2;
threshold_t =  0;

nsim = length(p_pool);
for i = 1:nsim
    tempp = p_pool{i};
    tempp = getIndex(tempp,filter_duration,threshold_t,threshold_ratio);
    p_pool{i} = tempp;
    contrastlevel(i) = p_pool{i}.contrast(1);
end

%% Plot dominance duration for each contrast level
% Note that when there is no noise, this plot won't reflect the both-off,
% WTA and both-on regime well. Please check the original time series.
for i = 1:nsim
    Idx_domD_p(i) = p_pool{i}.Idx_domD_p;
    Idx_c(i) = p_pool{i}.contrast(1);
end
cpsFigure(.6,.6);
plot(Idx_c,Idx_domD_p,'-o');
xlabel('Dominance duration','FontSize',14)
ylabel('Stimul contrast','FontSize',14)
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
%%
% cpsFigure(.6*nsim,.6);
% % Idx_ptimev = nan(1,nsim);
% % for i = 1:nsim
% %     Idx_ptimev(i) = p_pool{i}.Idx_ptime_v;
% % end
% % subplot(1,6,1)
% % bar(Idx_ptimev);
% % title('ptimev')
% 
% Idx_rivalry = nan(1,nsim);
% for i = 1:nsim
%     Idx_noiseamp(i) = p_pool{i}.Idx_noiseamp;
% end
% subplot(1,6,1)
% bar(Idx_noiseamp);
% title('Noise amp')
% 
% Idx_wta = nan(1,nsim);
% for i = 1:nsim
%     Idx_wta(i) = p_pool{i}.Idx_wta;
% end
% subplot(1,6,2)
% bar(Idx_wta);
% title('WTA Index')
% 
% Idx_diff = nan(1,nsim);
% for i = 1:nsim
%     Idx_diff(i) = p_pool{i}.Idx_diff;
% end
% subplot(1,6,3)
% bar(Idx_diff);
% title('diff Index')
% 
% Idx_ratio = nan(1,nsim);
% for i = 1:nsim
%     Idx_ratio(i) = p_pool{i}.Idx_ratio;
% end
% subplot(1,6,4)
% bar(Idx_ratio);
% title('ratio Index')
% 
% Idx_mean = nan(1,nsim);
% for i = 1:nsim
%     Idx_mean(i) = p_pool{i}.Idx_mean;
% end
% subplot(1,6,5)
% bar(Idx_mean);
% title('mean Index')
% 
% Idx_mean = nan(1,nsim);
% for i = 1:nsim
%     Idx_corr(i) = p_pool{i}.Idx_corr;
% end
% subplot(1,6,6)
% bar(Idx_corr);
% title('corr Index')
% tightfig;
%%
% pIdx  = 17;
% tplot = 1:10000;
% 
% cpsFigure(2,.8);
% set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p_pool{pIdx}.cond}, p_pool{pIdx}.contrast(1), p_pool{pIdx}.contrast(2)));
% for lay = 1:p_pool{1}.nLayers
%     subplot(2,3,subplotlocs(lay))
%     cla; hold on;
%     if lay==4
%         temp1 = squeeze(p_pool{pIdx}.inh{1}(1,:))*p_pool{pIdx}.w_opp;
%         ptemp = plot(p_pool{pIdx}.tlist(tplot)/1000,temp1(tplot),'color',[0 0 0]);
%     elseif lay==5
%         temp1 = squeeze(p_pool{pIdx}.inh{2}(1,:))*p_pool{pIdx}.w_opp;
%         ptemp = plot(p_pool{pIdx}.tlist(tplot)/1000,temp1(tplot),'color',[0 0 0]);
%     else
%         temp1 = squeeze(p_pool{pIdx}.r{lay}(1,:));
%         temp2 = squeeze(p_pool{pIdx}.r{lay}(2,:));
%         pL = plot(p_pool{pIdx}.tlist(tplot)/1000,temp1(tplot),'color',[1 0 1]);
%         pR = plot(p_pool{pIdx}.tlist(tplot)/1000,temp2(tplot),'color',[0 0 1]);
%     end
%     ylabel('Firing rate')
%     xlabel('Time (s)')
%     title(layernames(lay))
%     %set(gca,'XLim',[0 p.T(tplot)/1000]);
%     set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])+.1]);
%     drawnow;
% end
% subplot(2,3,5)
% plot(p_pool{pIdx}.tlist(tplot)/1000,p_pool{pIdx}.att(1,tplot),'color',[1 0 1]); hold on;
% plot(p_pool{pIdx}.tlist(tplot)/1000,p_pool{pIdx}.att(2,tplot),'color',[0 0 1]);
% title('Attention')
% tightfig;
% 
% % Draw time sereis_2
% cpsFigure(1,1.5);
% set(gcf,'Name',sprintf('%s contrast: %1.1f %1.1f', condnames{p_pool{1}.cond}, p_pool{pIdx}.contrast(1), p_pool{pIdx}.contrast(2)));
% 
% %To view the two rivarly time series
% subplot(3,1,1);hold on
% title('LE & RE')
% for lay = 1:2
%     temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
%     temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
%     switch lay
%         case 1
%             plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r-','LineWidth',1.5)
%         case 2
%             plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b--','LineWidth',1)
%     end
%     set(gca,'FontSize',12)
% end
% 
% %Left eye
% subplot(3,1,2);hold on
% title('LE')
% lay=1;
% temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
% temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
% plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r-','LineWidth',1.5)
% plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b-','LineWidth',1.5)
% 
% %Right eye
% subplot(3,1,3);hold on
% title('RE')
% lay=2;
% temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
% temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
% plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r:','LineWidth',1)
% plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b:','LineWidth',1)
% xlabel('Time (sec)', 'FontSize',12)
% tightfig;
% drawnow;
