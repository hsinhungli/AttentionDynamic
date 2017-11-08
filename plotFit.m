% plotFit.m

%% load a fit
% load fit/fit_workspace_20160504T0032_job82376421.mat % span
% load fit/fit_workspace_20160504T0404_job82414651.mat % no span
% load fit/fit_workspace_20160503T0855.mat % transient-span
% load fit/fit_workspace_20171106_interim.mat % 1-attLat
load fit/fit_workspace_20171107_interim.mat % transient-span

%% setup
plotErrorBar = 0;
xlims = [0 900];
nSeq = numel(D);

%% get error bar
for iSeq = 1:nSeq
    for iT = 1:2
        eb(:,:,iT,iSeq) = D(iSeq).dpSte{iT}(1:2,:);
    end
end

%% calculate cueing effect
dataCueEff = squeeze(data(1,:,:,:) - data(2,:,:,:));
modelCueEff = squeeze(model(1,:,:,:) - model(2,:,:,:));

%% plot
ylims = [0 2]; %[-.5 3]; % [0 2]
soas = D.t1t2soa;
for iSeq = 1:nSeq
    figure('Position',[100 100 580 550])
    colors = get(gcf,'DefaultAxesColorOrder');
    colors(3,:) = [.5 .5 .5];
    for iT = 1:2
        subplot(3,2,[iT iT+2])
        hold on
        p0 = plot(soas, model(:,:,iT,iSeq)','LineWidth',3);
        if plotErrorBar
            p1 = errorbar(repmat(soas',1,2), data(:,:,iT,iSeq)', eb(:,:,iT,iSeq)','o',...
                'MarkerSize',7,'LineWidth',2,'MarkerFaceColor','w');
        else
            p1 = plot(soas, data(:,:,iT,iSeq)','o','MarkerSize',7,'LineWidth',2,'MarkerFaceColor','w');
        end
        for i = 1:numel(p1)
            set(p0(i),'color',colors(i,:))
            set(p1(i),'color',colors(i,:))
        end
        xlim(xlims)
        ylim(ylims)
        xlabel('soa')
        ylabel('dprime')
        title(sprintf('T%d',iT))
        set(gca,'LineWidth',1)
    end
    if numel(p1)==2
        legend('valid','invalid')
    elseif numel(p1)==3
        legend('valid','invalid','neutral')
    end
    legend boxoff
    
    for iT = 1:2
        subplot(3,2,iT+4)
        hold on
        plot(xlims, [0 0], '--k')
        p1 = plot(soas, modelCueEff(:,iT,iSeq),'Color','k','LineWidth',3);
        p2 = plot(soas, dataCueEff(:,iT,iSeq),'.','MarkerSize',25,'Color','k','MarkerFaceColor','w');
        xlim(xlims)
        ylim([-.4 .8])
        xlabel('soa')
        ylabel('dprime valid-invalid')
        set(gca,'LineWidth',1)
    end
    if nSeq>1
        rd_supertitle2(sprintf('Seq %d', iSeq))
    end
end

%% save fig
print_pdf(sprintf('fit/plot_%s',datestr(now,'yyyymmdd')))
