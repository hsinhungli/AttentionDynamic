% rumModelParallel

opt = [];

soas = [100:50:500 800];
rsoa = 1:10;
nsoa = numel(rsoa);

%% run soas in parallel
parfor isoa = 1:nsoa
    [pperfv{isoa}, pp{isoa}, pev{isoa}] = runModelTA(opt, rsoa(isoa));
end

%% combine ev
for isoa = 1:nsoa
    ev(:,isoa,:,:,:) = pev{isoa}; 
end

%% plot multiple conditions
condnames = {'endoT1','endoT2'};
perfv = plotPerformanceTA(condnames, soas(rsoa), mean(ev,5));

    