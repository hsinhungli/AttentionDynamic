function [cost, model, data, R2] = modelCost(x, D)

%% run model
opt = x2opt(x);
[perf, p] = runModelTA(opt);

%% organize model performance
for iT = 1:2
    model(:,:,iT) = perf{iT};
end

%% scale fit
model(:,:,1) = model(:,:,1)*p.scaling1 + p.offset1;
model(:,:,2) = model(:,:,2)*p.scaling2 + p.offset2;

%% load data
for iT = 1:2
    data(:,:,iT) = D.dpMean{iT}(1:2,:);
end

%% compare model to data
error = model - data;
cost = sum(error(:).^2);

sstot = sum((data(:)-mean(data(:))).^2);
R2 = 1 - cost/sstot;

%% display current state
disp(x)

%% plot
soas = D.t1t2soa;
figure(gcf)
clf
for iT = 1:2
    subplot(1,2,iT)
    hold on
    plot(soas, data(:,:,iT)','.','MarkerSize',20)
    plot(soas, model(:,:,iT)')
    ylim([0 2])
    xlabel('soa')
    ylabel('dprime / evidence')
    title(sprintf('T%d',iT))
end
legend('valid','invalid')

