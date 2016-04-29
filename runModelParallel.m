function [perfv, p, ev] = runModelParallel(opt)

% opt = [];

% w = load('fit/fit_workspace_20160416T0400.mat');
% opt = w.opt;

soas = [100:50:500 800];
rsoa = 1:10;
nsoa = numel(rsoa);

%% run soas in parallel
parfor isoa = 1:nsoa
    [pperfv{isoa}, pp{isoa}, pev{isoa}] = runModelTA(opt, rsoa(isoa));
end

%% combine ev
ev = [];
for isoa = 1:nsoa
    if numel(size(pev{1}))==5
        ev(:,isoa,:,1,:) = pev{isoa};
    else
        ev(:,isoa,:,:,:) = pev{isoa};
    end
end

%% plot multiple condition
condnames = {'endoT1','endoT2'};
perfv = plotPerformanceTA(condnames, soas(rsoa), mean(ev,5));

%% specify a p
p = pp{end};

    