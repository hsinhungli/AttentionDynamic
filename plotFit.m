% plotFit.m

%% load a fit
% load fit/fit_workspace_20160504T0032_job82376421.mat % span
load fit/fit_workspace_20160504T0404_job82414651.mat % no span

%% setup
plotErrorBar = 0;
xlims = [0 900];

%% get error bar
for iT = 1:2
    eb(:,:,iT) = D.dpSte{iT}(1:3,:);
end

%% calculate cueing effect
dataCueEff = squeeze(data(1,:,:) - data(2,:,:));
modelCueEff = squeeze(model(1,:,:) - model(2,:,:));

%% plot
soas = D.t1t2soa;
figure
colors = get(gcf,'DefaultAxesColorOrder');
for iT = 1:2
    subplot(3,2,[iT iT+2])
    hold on
    plot(soas, model(:,:,iT)','LineWidth',3)
    if plotErrorBar
        p1 = errorbar(repmat(soas',1,3), data(:,:,iT)', eb(:,:,iT)','.','MarkerSize',25,'LineWidth',2);
    else
        p1 = plot(soas, data(:,:,iT)','.','MarkerSize',25,'LineWidth',2);
    end
    for i = 1:numel(p1)
        set(p1(i),'color',colors(i,:))
    end
    xlim(xlims)
    ylim([0 2])
    xlabel('soa')
    ylabel('dprime')
    title(sprintf('T%d',iT))
end
if numel(p1)==2
    legend('valid','invalid')
elseif numel(p1)==3
    legend('valid','invalid','neutral')
end

for iT = 1:2
    subplot(3,2,iT+4)
    hold on
    plot(xlims, [0 0], '--k')
    p1 = plot(soas, modelCueEff(:,iT),'Color','k','LineWidth',3);
    p2 = plot(soas, dataCueEff(:,iT),'.','MarkerSize',25,'Color','k','MarkerFaceColor','w');
    xlim(xlims)
    ylim([-.4 .8])
    xlabel('soa')
    ylabel('dprime valid-invalid')
end