function cost = modelCost(x, D)

%% run model
opt = x2opt(x);
perf = runModelTA(opt);

%% scale fit
for iT = 1:2
    model(:,:,iT) = perf{iT}*opt.fitScaling;
end

%% load data
for iT = 1:2
    data(:,:,iT) = D.dpMean{iT}(1:2,:);
end

%% compare model to data
error = model - data;
cost = sum(error(:).^2);

%% display current state
disp(x)
