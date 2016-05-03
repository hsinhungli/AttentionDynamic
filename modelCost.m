function [cost, model, data, R2] = modelCost(x, D)

%% run model
opt = x2opt(x);
% [perf, p] = runModelTA(opt);
[perf, p] = runModelParallel(opt);

%% organize model performance
for iT = 1:2
    model(:,:,iT) = perf{iT};
end

%% scale fit
model(:,:,1) = model(:,:,1)*p.scaling1 + p.offset1;
model(:,:,2) = model(:,:,2)*p.scaling2 + p.offset2;

%% load data
for iT = 1:2
    data(:,:,iT) = D.dpMean{iT}(1:3,:);
%     eb(:,:,iT) = D.dpSte{iT}(1:3,:);
end

%% compare model to data
error = model - data;
cost = sum(error(:).^2);

sstot = sum((data(:)-mean(data(:))).^2);
R2 = 1 - cost/sstot;

%% display current state
disp(x)
fprintf('R2 = %1.3f\n', R2) 

%% plot
soas = D.t1t2soa;
figure(gcf)
clf
colors = get(gcf,'DefaultAxesColorOrder');
for iT = 1:2
    subplot(1,2,iT)
    hold on
    plot(soas, data(:,:,iT)','.','MarkerSize',20)
%     errorbar(repmat(soas',1,3), data(:,:,iT)', eb(:,:,iT)','.','MarkerSize',20)
    p1 = plot(soas, model(:,:,iT)');
    for i = 1:numel(p1)
        set(p1(i),'color',colors(i,:))
    end
    ylim([0 2])
    xlabel('soa')
    ylabel('dprime')
    title(sprintf('T%d',iT))
end
legend('valid','invalid')

%% save
saveDir = D.saveDir;
figNames = {'plot'};
save(sprintf('%s/fit_workspace_%s_interim', saveDir, datestr(now,'yyyymmdd')))
rd_saveAllFigs([],figNames, [], saveDir)

