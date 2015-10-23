function plotFA2(condname, p)

% for plotting time series from temporal attention experiments - just the
% first feature.

%% Figure 1
% panel 1
cpsFigure(.5,1.2);
set(gcf,'Name',sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
nr = 6;
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
ylim([-0.5 1.5])
set(gca,'XTickLabel',[])
ylabel('R2')

subplot(nr,nc,4)
hold on
plot(p.tlist/1000,p.r(1,:),'color',[112 191 65]/255);
xlim(xlims)
set(gca,'XTickLabel',[-0.5 0 0.5 1])
ylabel('R1')
set(gca,'YLim',[0 max(p.r(:))+.1]);

subplot(nr,nc,5)
hold on
plot(p.tlist/1000,p.r2(1,:),'color',[58 154 217]/255);
xlim(xlims)
ylabel('R1 filtered')
set(gca,'YLim',[0 max(p.r(:))+.1]);

subplot(nr,nc,6)
hold on
plot(p.tlist/1000, zeros(size(p.tlist)), 'k')
plot(p.tlist(p.decisionWindows(1,:))/1000,p.evidence(:,1),'color',[53 68 88]/255);
plot(p.tlist(p.decisionWindows(2,:))/1000,p.evidence(:,2),'color',[53 68 88]/255);
xlim(xlims)
ylabel('Evidence')
xlabel('Time (s)')

rd_supertitle(sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
%                 tightfig