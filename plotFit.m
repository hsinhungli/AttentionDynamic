function fH = plotFit(D, fitFile, plotErrorBar, plotDataOnly, plotFields)

% function plotFit(D, fitFile, plotErrorBar, plotDataOnly, plotField)

%% inputs
if nargin<1
    dataDir = '/Local/Users/denison/Google Drive/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
    dataFile = 'E2_SOA_cbD6_run98_N4_norm_workspace_20171108.mat';
    D = load(sprintf('%s/%s', dataDir, dataFile));
end

if nargin<2
fitFile = 'fit/fit_workspace_20160504T0032_job82376421.mat'; % % span
% load fit/fit_workspace_20160504T0404_job82414651.mat % no span
% load fit/fit_workspace_20160503T0855.mat % transient-span
% load fit/fit_workspace_20171106_interim.mat % 1-attLat
% fitFile = 'fit/fit_workspace_20171107_interim.mat'; % transient-span
end

if nargin<3 || isempty(plotErrorBar)
    plotErrorBar = 1;
end

if nargin<4 || isempty(plotDataOnly)
    plotDataOnly = 0;
end

if nargin<5
    plotFields = []; % eg. {'rtMean','rtSte','rtDataCueEff','rtData'};
end
    

%% load a fit
load(fitFile, 'data', 'model')

%% set data to plotField if requested
if ~isempty(plotFields)
    meanVals = D.(plotFields{1});
    data0 = data;
    data = [];
    for iT = 1:numel(meanVals)
        data(:,:,iT) = meanVals{iT};
    end
    
    steField = plotFields{2};
    cueEffField = plotFields{3};
    
    if numel(plotFields)==4
        dataVals = D.(plotFields{4});
        for iT = 1:2
            ce{iT} = squeeze(dataVals{iT}(1,:,:)-dataVals{iT}(2,:,:));
        end
        D.(cueEffField) = ce;
    end
else
    steField = 'dpSte';
    cueEffField = 'dpDataCueEff';
end

%% setup
xlims = [0 900];
nSeq = numel(D);

%% get error bar
for iSeq = 1:nSeq
    for iT = 1:2
        eb(:,:,iT,iSeq) = D(iSeq).(steField){iT}(1:3,:);
        
        cueEff = D(iSeq).(cueEffField){iT};
        ebCueEff(:,iT,iSeq) = std(cueEff,0,2)./sqrt(D.nSubjects);
    end
end

%% calculate cueing effect
dataCueEff = squeeze(data(1,:,:,:) - data(2,:,:,:));
modelCueEff = squeeze(model(1,:,:,:) - model(2,:,:,:));

%% colors
colors = get(gcf,'DefaultAxesColorOrder');
colors(3,:) = [.5 .5 .5];
c = rgb2hsv(colors);
c(1:2,2) = .2;
c(1:2,3) = .95;
c(3,3) = .9;
ebcolors = hsv2rgb(c);

%% plot
ylims = [0 2]; %[-.5 3]; % [0 2]
soas = D.t1t2soa;
plotOrder = [3 2 1];
for iSeq = 1:nSeq
    fH = figure('Position',[100 100 580 550]);
    for iT = 1:2
        subplot(3,2,[iT iT+2])
        hold on
        if plotErrorBar
%             p1 = errorbar(repmat(soas,3,1)', data(plotOrder,:,iT,iSeq)', eb(plotOrder,:,iT,iSeq)','o',...
%                 'MarkerSize',7,'LineWidth',1,'MarkerFaceColor','w');
            p1 = [];
            for iV = 1:size(eb,1)
                y = squeeze(data(plotOrder(iV),:,iT,iSeq));
                e = squeeze(eb(plotOrder(iV),:,iT,iSeq));
                p1{iV} = errbar(soas, y, e,...
                    'LineWidth',7,'Color',ebcolors(plotOrder(iV),:));
            end
        end
        if plotDataOnly
            p0 = plot(soas, data(plotOrder,:,iT,iSeq)','LineWidth',3);
        else
            p0 = plot(soas, model(plotOrder,:,iT,iSeq)','LineWidth',3);
        end
        p2 = plot(soas, data(plotOrder,:,iT,iSeq)','o','MarkerSize',8,'LineWidth',2,'MarkerFaceColor','w');
        for i = 1:numel(p0)
            set(p0(i),'color',colors(plotOrder(i),:))
            set(p2(i),'color',colors(plotOrder(i),:))
        end
        xlim(xlims)
        ylim(ylims)
%         xlabel('SOA')
        if iT==1
            ylabel('Performance (\it d'')')
        end
        title(sprintf('T%d',iT))
        set(gca,'LineWidth',1)
        set(gca,'FontSize',18)
        set(gca,'TickDir','out')
        set(gca,'XTick',0:200:800)
    end
    condNames = {'valid','invalid','neutral'};
    if numel(p0)==2
        legend('valid','invalid')
    elseif numel(p0)==3
        legend(condNames(plotOrder))
    end
    legend boxoff
    
    for iT = 1:2
        subplot(3,2,iT+4)
        hold on
        plot(xlims, [0 0], '--k')
        if plotErrorBar
%             p1 = errorbar(soas, dataCueEff(:,iT,iSeq), ebCueEff(:,iT,iSeq),...
%                 '.','MarkerSize',25,'Color','k','MarkerFaceColor','w');
            p1 = errbar(soas, dataCueEff(:,iT,iSeq), ebCueEff(:,iT,iSeq),...
                'LineWidth',7,'Color',[.8 .8 .8]);
        end
        if plotDataOnly
            p0 = plot(soas, dataCueEff(:,iT,iSeq),'Color','k','LineWidth',3);
        else
            p0 = plot(soas, modelCueEff(:,iT,iSeq),'Color','k','LineWidth',3);
        end
        p2 = plot(soas, dataCueEff(:,iT,iSeq),'.','MarkerSize',30,'Color','k','MarkerFaceColor','w');
        xlim(xlims)
        ylim([-.4 .8])
        xlabel('SOA (ms)')
        if iT==1
            ylabel('Valid - invalid (\Delta{\itd''})')
        end
        set(gca,'LineWidth',1)
        set(gca,'FontSize',18)
        set(gca,'TickDir','out')
        set(gca,'XTick',0:200:800)
        set(gca,'YTick',-.4:.4:.8)
    end
    if nSeq>1
        rd_supertitle2(sprintf('Seq %d', iSeq))
    end
end

%% save fig
% print_pdf(sprintf('fit/plot_%s',datestr(now,'yyyymmdd')))
