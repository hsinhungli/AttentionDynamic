% plotTaskTA

%% version 1: vss poster
soas = [200 500 800];

for i = 1:numel(soas)
    p.soa = soas(i);
    
    % distribute voluntary attention
    if p.distributeVoluntary
        totalAtt = 1 + p.soa/p.span;
        if totalAtt>2
            totalAtt = 2;
        end
        if strcmp(condname, 'endoT1T2')
            p.vAttWeights = distributeAttention(totalAtt, 0, [], p.neutralT1Weight);
        else
            p.vAttWeights = distributeAttention(totalAtt, 1, 1);
        end
        p.vAttWeight1 = p.vAttWeights(1);
        p.vAttWeight2 = p.vAttWeights(2);
    end
    
    % set task
    p = setTaskTA('endoT1',p);
    a(:,i) = p.task(1,:);
    
    p = setTaskTA('endoT2',p);
    a(:,numel(soas)+i) = p.task(1,:);
end

figure
for i = 1:numel(soas)*2
    subplot(numel(soas)*2,1,i)
    plot(p.tlist,a(:,i));
    xlim([-200 1000])
end

%% version 2: sfn poster
rsoa = [3 9 10];
nsoa = numel(rsoa);

rcond = 2:4;
ncond = numel(rcond);

for isoa = 1:nsoa
    for icond = 1:ncond
        [perfv, p(isoa,icond), ev] = runModelTA([], rsoa(isoa), [], rcond(icond));
    end
end

h = figure('Position',[500 80 750 230]);
for isoa = 1:nsoa
    for icond = 1:ncond
        task = p(isoa,icond).task(1,:);
        
        subplot(ncond,nsoa,(icond-1)*nsoa+isoa)
        plot(p(1,1).tlist, task)
    end
end

ax = h.Children;

xlims = [300 1700];
ylims = [0 1];

% set axis properties
for i = 1:numel(ax)
    ax(i).XLim = xlims;
    ax(i).YLim = ylims;
    ax(i).Visible = 'off';
%     ax(i).FontSize = 14;
%     ax(i).LineWidth = 1;
end
for i = 1:3
    ax(i).Children(1).Color = [0 0 0];
end
for i = 4:6
    ax(i).Children(1).Color = [.27 .27 .27];
end
for i = 7:9
    ax(i).Children(1).Color = [.4 .4 .4];
end
ax(7).Visible = 'on';
ax(7).Box = 'off';
ax(7).XTick = [];
ax(7).YTick = [0 1];
ax(7).LineWidth = 1;
ax(7).TickDir = 'out';

% print_pdf('task_t1t2n_soa200-500-800.pdf')

