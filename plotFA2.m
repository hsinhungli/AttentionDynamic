function plotFA2(condname, p)

% for plotting time series from temporal attention experiments - just the
% first feature.

%% Figure 1
figTitle = sprintf('%s contrast: %1.2f soa: %d seq: %d %d', condname, p.contrast, p.soa, p.stimseq);

% panel 1
cpsFigure(.5,1.2);
set(gcf,'Name',figTitle);
nr = 7;
nc = 1;
xlims = [0 2];

subplot(nr,nc,1)
hold on
plot(p.tlist/1000,p.stim','color',[0 0 0]);
% plot(p.tlist/1000,p.i','color',[244 164 96]/255);
xlim(xlims)
set(gca,'XTickLabel',[])
ylabel('Stimulus')

subplot(nr,nc,2)
hold on
plot(p.tlist/1000,p.attV','color',[153 124 107]/255);
xlim(xlims)
% ylim([0 1])
ylim([-.1 .1])
set(gca,'XTickLabel',[])
ylabel('AV')

subplot(nr,nc,3)
hold on
plot(p.tlist/1000,p.attI','color',[185 178 170]/255);
xlim(xlims)
ylim([-.2 .2])
set(gca,'XTickLabel',[])
ylabel('AI')

subplot(nr,nc,4)
hold on
plot(p.tlist/1000,p.r','color',[112 191 65]/255);
plot(p.tlist/1000,p.rtr','color',[34 139 34]/255);
xlim(xlims)
ylim([0 max(p.r(:))*1.1])
set(gca,'XTickLabel',[])
ylabel('S1')

subplot(nr,nc,5)
hold on
plot(p.tlist/1000,p.r2','color',[58 154 217]/255);
xlim(xlims)
ylim([0 max(p.r2(:))*1.1])
set(gca,'XTickLabel',[])
ylabel('S2')

subplot(nr,nc,6)
hold on
plot(p.tlist/1000,p.r3','color',[110 119 143]/255);
xlim(xlims)
ylim([0 max(p.r3(:))*1.1])
set(gca,'XTickLabel',[])
ylabel('S3')

% subplot(nr,nc,6)
% hold on
% plot(p.tlist/1000,p.rwm(:,:,1)','color',[110 119 143]/255);
% plot(p.tlist/1000,p.rwm(:,:,2)','color',[110 119 143]/255);
% xlim(xlims)
% set(gca,'XTickLabel',[])
% ylabel('WM')
% set(gca,'YLim',[0 max(p.rwm(:))+.1]);

subplot(nr,nc,7)
hold on
plot(p.tlist/1000, zeros(size(p.tlist)), 'k')
plot(p.tlist/1000,p.evidence(:,:,1)','color',[53 68 88]/255);
plot(p.tlist/1000,p.evidence(:,:,2)','color',[53 68 88]/255);
plot(p.tlist/1000,p.decisionWindows(:,1:length(p.tlist))*max(abs(p.evidence(:)))*1.1,'color',[127 127 127]/255);
xlim(xlims)
set(gca,'XTick',[-0.5 0 0.5 1 1.5 2])
ylabel('Decision')
xlabel('Time (s)')

rd_supertitle(figTitle);
%                 tightfig