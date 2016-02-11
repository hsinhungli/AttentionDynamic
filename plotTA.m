function plotTA(condname, p)

%% Figure 1
% panel 1
cpsFigure(1.6,2);
set(gcf,'Name',sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
nr = 7;
nc = 2;

subplot(nr,nc,1)
hold on
plot(p.tlist/1000,p.i(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.i(2,:),'color',[0 0 1]);
ylabel('Input')
%                 set(gca,'YLim',[0 max(p.i(:))+.1*max(p.i(:))]);

subplot(nr,nc,3)
hold on
plot(p.tlist/1000,p.e(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.e(2,:),'color',[0 0 1]);
ylabel('Temporally filtered')
%                 set(gca,'YLim',[0 max(p.e(:))+.1*max(p.e(:))]);

subplot(nr,nc,5)
hold on
plot(p.tlist/1000,p.d(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.d(2,:),'color',[0 0 1]);
ylabel('Excitatory drive')
%                 set(gca,'YLim',[0 max(p.d(:))+.1*max(p.d(:))]);

subplot(nr,nc,7)
hold on
plot(p.tlist/1000,p.s(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.s(2,:),'color',[0 0 1]);
ylabel('Suppressive drive')
%                 set(gca,'YLim',[0 max(p.s(:))+.1*max(p.s(:))]);

subplot(nr,nc,9)
hold on
plot(p.tlist/1000,p.f(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.f(2,:),'color',[0 0 1]);
ylabel('Steady-state')
%                 set(gca,'YLim',[0 max(p.f(:))+.1]);

subplot(nr,nc,11)
hold on
plot(p.tlist/1000,p.r(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.r(2,:),'color',[0 0 1]);
ylabel('Firing rate')
xlabel('Time (s)')
set(gca,'YLim',[0 max(p.r(:))+.1]);

subplot(nr,nc,13)
hold on
plot(p.tlist/1000,p.r2(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.r2(2,:),'color',[0 0 1]);
ylabel('Firing rate filtered')
xlabel('Time (s)')
set(gca,'YLim',[0 max(p.r(:))+.1]);

% panel 2
subplot(nr,nc,2)
hold on
plot(p.tlist/1000,p.stim(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.stim(2,:),'color',[0 0 1]);
ylabel('Stimulus')

subplot(nr,nc,4)
hold on
plot(p.tlist/1000,p.task(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.task(2,:),'color',[0 0 1]);
ylabel('Task')

subplot(nr,nc,6)
hold on
plot(p.tlist/1000,p.h(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.h(2,:),'color',[0 0 1]);
ylabel('Inv. suppression (h)')

subplot(nr,nc,8)
hold on
plot(p.tlist/1000,p.attI(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.attI(2,:),'color',[0 0 1]);
ylabel('Involuntary att')

subplot(nr,nc,10)
hold on
plot(p.tlist/1000,p.attV(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.attV(2,:),'color',[0 0 1]);
ylabel('Voluntary att')

subplot(nr,nc,12)
hold on
plot(p.tlist/1000,p.att(1,:),'color',[1 0 1]);
plot(p.tlist/1000,p.att(2,:),'color',[0 0 1]);
ylabel('Attention')

subplot(nr,nc,14)
hold on
plot(p.tlist/1000, zeros(size(p.tlist)), 'k')
plot(p.tlist(p.decisionWindows(1,:))/1000,p.evidence(:,:,1),'color',[1 0 1]);
plot(p.tlist(p.decisionWindows(2,:))/1000,p.evidence(:,:,2),'color',[1 0 1]);
ylabel('Evidence')

rd_supertitle(sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
%                 tightfig