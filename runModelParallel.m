% runModelParallel

opt = [];

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

%% plot multiple conditions
condnames = {'endoT1','endoT2'};
perfv = plotPerformanceTA(condnames, soas(rsoa), mean(ev,5));

    