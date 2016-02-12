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
xlims = [0 1.5];

subplot(nr,nc,1)
hold on
plot(p.tlist/1000,p.stim(1,:),'color',[0 0 0]);
xlim(xlims)
set(gca,'XTickLabel',[])
ylabel('Stimulus')

subplot(nr,nc,2)
hold on
plot(p.tlist/1000,p.attV(1,:),'color',[153 124 107]/255);
xlim(xlims)
ylim([-0.5 1.5])
set(gca,'XTickLabel',[])
ylabel('R3')

subplot(nr,nc,3)
hold on
plot(p.tlist/1000,p.attI(1,:),'color',[185 178 170]/255);
xlim(xlims)
ylim([-1.2 1.2])
set(gca,'XTickLabel',[])
ylabel('R2')

subplot(nr,nc,4)
hold on
plot(p.tlist/1000,p.r(1,:),'color',[112 191 65]/255);
xlim(xlims)
set(gca,'XTickLabel',[])
ylabel('R1')
set(gca,'YLim',[0 max(p.r(:))+.1]);

subplot(nr,nc,5)
hold on
plot(p.tlist/1000,p.r2(1,:),'color',[58 154 217]/255);
xlim(xlims)
set(gca,'XTickLabel',[])
ylabel('R1 filtered')
set(gca,'YLim',[0 max(p.r(:))+.1]);

subplot(nr,nc,6)
hold on
plot(p.tlist/1000,p.rwm(:,:,1)','color',[110 119 143]/255);
plot(p.tlist/1000,p.rwm(:,:,2)','color',[110 119 143]/255);
xlim(xlims)
set(gca,'XTickLabel',[])
ylabel('R4')
set(gca,'YLim',[0 max(p.rwm(:))+.1]);

subplot(nr,nc,7)
hold on
plot(p.tlist/1000, zeros(size(p.tlist)), 'k')
plot(p.tlist/1000,p.evidence(:,:,1)','color',[53 68 88]/255);
plot(p.tlist/1000,p.evidence(:,:,2)','color',[53 68 88]/255);
xlim(xlims)
set(gca,'XTickLabel',[-0.5 0 0.5 1])
ylabel('Evidence')
xlabel('Time (s)')

rd_supertitle(figTitle);
%                 tightfig