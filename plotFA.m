function plotFA(condname, p)

%% Figure 1
% panel 1
cpsFigure(.5,.8);
set(gcf,'Name',sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
nr = 4;
nc = 1;

subplot(nr,nc,1)
hold on
plot(p.tlist/1000,p.stim(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.stim(2,:),'color',[0 0 1]);
xlim([0 1.5])
set(gca,'XTickLabel',[])
ylabel('Stimulus')

subplot(nr,nc,2)
hold on
plot(p.tlist/1000,p.attV(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.attV(2,:),'color',[0 0 1]);
xlim([0 1.5])
ylim([-0.5 1.5])
set(gca,'XTickLabel',[])
ylabel('R_3')

subplot(nr,nc,3)
hold on
plot(p.tlist/1000,p.attI(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.attI(2,:),'color',[0 0 1]);
xlim([0 1.5])
ylim([-0.5 1.5])
set(gca,'XTickLabel',[])
ylabel('R_2')

subplot(nr,nc,4)
hold on
plot(p.tlist/1000,p.r(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.r(2,:),'color',[0 0 1]);
xlim([0 1.5])
set(gca,'XTickLabel',[-0.5 0 0.5 1])
ylabel('R_1')
xlabel('Time (s)')
set(gca,'YLim',[0 max(p.r(:))+.1]);

rd_supertitle(sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
%                 tightfig