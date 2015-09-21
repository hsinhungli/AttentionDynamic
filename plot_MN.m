mp_pool = p_pool;
condnames =  {'mnB/A','mnB/iA','mnSR',[],'mnP/A', 'mnP/iA', 'mnR/A', 'mnR/iA'};
p.m_noisefilter_t = 60;                    %measurement noise
p.m_noiseamp      = [.4 .4 0 0 0];        
p.m_noisebaseline = .2;
for lay = 1:p.nLayers
    p.m_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.m_noiseamp,p.m_noisefilter_t) + p.m_noisebaseline; %Noise of measurement
end
for i = rcond
    for lay = 1:p.nLayers
        mp_pool{i}.mr{lay} = halfExp(p_pool{i}.r{lay} , 1) + p.m_n{lay};
        %mp_pool{i}.mr{lay} = p_pool{i}.r{lay};
    end
end
for cond = rcond
    %% Draw time sereis_2
    cpsFigure(1,1.5);
    set(gcf,'Name',condnames{cond});
    subplot(3,1,1);hold on
    title('LE & RE')
    for lay = 1:2
        temp1 = squeeze(mp_pool{cond}.mr{lay}(1,:));
        temp2 = squeeze(mp_pool{cond}.mr{lay}(2,:));
        switch lay
            case 1
                plot(p.tlist/1000, temp1,'r-','LineWidth',1.5)
                if ismember(cond, [3 4])
                    plot(p.tlist/1000, temp2,'b-','LineWidth',1.5)
                end
            case 2
                if ismember(cond, [3 4])
                    plot(p.tlist/1000, temp1,'r--','LineWidth',1.5)
                end
                plot(p.tlist/1000, temp2,'b--','LineWidth',1)
        end
        set(gca,'FontSize',12)
    end
    subplot(3,1,2);hold on
    title('LE')
    lay=1;
    temp1 = squeeze(mp_pool{cond}.mr{lay}(1,:));
    temp2 = squeeze(mp_pool{cond}.mr{lay}(2,:));
    plot(p.tlist/1000, temp1,'r-','LineWidth',1.5)
    plot(p.tlist/1000, temp2,'b-','LineWidth',1.5)
    %plot(p.tlist/1000, max([temp1';temp2']),'k');
    subplot(3,1,3);hold on
    title('RE')
    lay=2;
    temp1 = squeeze(mp_pool{cond}.mr{lay}(1,:));
    temp2 = squeeze(mp_pool{cond}.mr{lay}(2,:));
    plot(p.tlist/1000, temp1,'r:','LineWidth',1)
    plot(p.tlist/1000, temp2,'b:','LineWidth',1)
    xlabel('Time (sec)', 'FontSize',12)
    drawnow;
    
    %% compute WTA index
    if ismember(cond,[5 6])
        temp1 = squeeze(mp_pool{cond}.mr{1}(1,:));
        temp2 = squeeze(mp_pool{cond}.mr{1}(2,:));
    else
        temp1 = squeeze(mp_pool{cond}.mr{1}(1,:));
        temp2 = squeeze(mp_pool{cond}.mr{2}(2,:));
    end
    temp1(p.tlist<2000) = [];
    temp2(p.tlist<2000) = [];
    mp_pool{cond}.wta(c) = nanmean(abs(temp1-temp2)./(temp1+temp2));
    mp_pool{cond}.corrIdx(c) = corr(temp1',temp2');
    mp_pool{cond}.meanAmp(c) = mean([temp1 temp2]);
    
end
%%
cpsFigure(ncond*.5,.7);
epochlength = 6000;
aSignal = [];
rSignal = [];
for i = 1:ncond
    subplot(1,ncond,i);
    if ismember(rcond(i),[5 6])
        data1 = mp_pool{rcond(i)}.mr{1}(1,:);
        data2 = mp_pool{rcond(i)}.mr{1}(2,:);
    else
        data1 = mp_pool{rcond(i)}.mr{1}(1,:);
        data2 = mp_pool{rcond(i)}.mr{2}(2,:);
    end
    [tempEpoch,tempEpochr,domD] = getEpoch(mp_pool{rcond(1)},data1,data2,epochlength);
    domDuration(rcond(i)) = domD/1000;
    x = 1:size(tempEpoch,2);
    x = ((x/max(x))*epochlength-epochlength/2)/1000;
    aSignal(i,:) = mean(tempEpoch);
    rSignal(i,:) = mean(tempEpochr);
    plot(x,aSignal(i,:),'LineWidth',1.2);hold on;
    plot(x,rSignal(i,:),'k','LineWidth',1.2);
    rivalryIdx(i) = abs(max(aSignal(i,:)) - min(rSignal(i,:)))/abs(max(aSignal(i,:)) + min(rSignal(i,:)));
    xlim([min(x) max(x)])
    ylim([0 1.5])
    title(condnames(rcond(i)),'FontSize', 12)
end
cpsFigure(1,1);
for i = 1:ncond
    bar(i,domDuration(rcond(i)), 'FaceColor', [.6 .6 .6]); hold on
end
%ylim([0 max(domDuration)+2])
ylabel('domDuration','FontSize', 12)
set(gca,'XTick',1:ncond,'FontSize', 12)
set(gca,'XTickLabel', (condnames(rcond)));
%% Plot Index
cpsFigure(1.8,1.2)
subplot1(1,4,'Gap',[0.05 0.02]);hold on;

subplot1(1)
for i = 1:ncond
    bar(i,rivalryIdx(i), 'FaceColor', [.6 .6 .6]);
end
title('Rivalry index','FontSize',14)
ylim([0 1]); xlim([0.5 ncond+.5])
set(gca,'XTick', 1:ncond,'FontSize', 10)
set(gca,'XTickLabel', (condnames(rcond)));
set(gca,'FontSize',14);

subplot1(2)
for i = 1:ncond
    bar(i,mp_pool{rcond(i)}.wta, 'FaceColor', [.6 .6 .6]);
end
title('Winner-take-all index','FontSize',14)
ylim([0 1]); xlim([0.5 ncond+.5])
set(gca,'XTick', 1:ncond,'FontSize', 10)
set(gca,'XTickLabel', (condnames(rcond)));
set(gca,'FontSize',14);

subplot1(3)
for i = 1:ncond
    bar(i,mp_pool{rcond(i)}.corrIdx, 'FaceColor', [.6 .6 .6]); hold on
end
title('Correlation','FontSize',14)
ylim([-1 1]); xlim([0.5 ncond+.5])
set(gca,'YTick', -1:.5:1,'FontSize', 10)
set(gca,'YTickLabel', -1:.5:5);
set(gca,'XTick', 1:ncond,'FontSize', 10)
set(gca,'XTickLabel', (condnames(rcond)));
set(gca,'FontSize',14);

subplot1(4)
for i = 1:ncond
    bar(i,mp_pool{rcond(i)}.meanAmp, 'FaceColor', [.6 .6 .6]); hold on
end
title('Mean Amplitude','FontSize',14)
set(gca,'FontSize',14); xlim([0.5 ncond+.5])
set(gca,'XTick', 1:ncond,'FontSize', 14)
set(gca,'XTickLabel', (condnames(rcond)));