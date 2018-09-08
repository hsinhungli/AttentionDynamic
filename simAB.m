% simAB.m

%% i/o
gd = '/Users/rachel/Google Drive';
% gd = '/Local/Users/denison/Google Drive';

figDir = sprintf('%s/NYU/Grants_&_Apps/Grants/Attention_Dynamics/Figures/pdf', gd);

%% load
load('fit/fit_workspace_20180812T1741_job8116424_span.mat','opt','modelClass')

%% settings
opt.aMI = 35;
opt.aIOR = 4;

%% run
rsoa = [1 3 5 7 9 10]; % [100 200 300 400 500 800]
rseq = 1:2; % [1 1] and [1 2] (distractors are on other axis)
rcond = 1; % no-endo

[perfv, p, ev] = runModelTA(opt, modelClass, rsoa, rseq, rcond);

perf = squeeze(mean(ev,5))';

%% plot
lags = [1 2 3 4 5 8];
figure
plot(soas, perf)

figure
plot(lags, perf(:,2), '.-', 'MarkerSize', 30)
xlim([.5 8.5])
ylim([0 5e-5])
xlabel('Lag (items)')
ylabel('Performance (au)')
title('T2')
set(gca,'LineWidth',1,'TickDir','out','YTickLabel',0:20:100)
box off

print_pdf('ABSim_T2Perf.pdf', figDir)

%% example timeseries
% turn on plot fig
rsoa = 5; % 300
rseq = 1; % [1 1]
rcond = 1; % no-endo
[perfv, p, ev] = runModelTA(opt, modelClass, rsoa, rseq, rcond);

h = gcf;
ax = h.Children;
ax(5).YLim = [-.025 .025]; % AI

ax(6).Children(1).Color = [71 98 159]/255;
ax(5).Children(1).Color = [112 153 208]/255;

for i = 1:numel(ax(3).Children)
    ax(3).Children(i).Color = [34 139 34]/255; % med green
end
for i = 1:numel(ax(2).Children)
    ax(2).Children(i).Color = [110 110 110]/255;
end

for i = 1:numel(ax)
    ax(i).TickDir = 'out';
    ax(i).LineWidth = 1;
end

print_pdf('ABSim_Timeseries_soa300_noendo.pdf', figDir)