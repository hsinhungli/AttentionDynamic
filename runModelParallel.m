function [perfv, p, ev] = runModelParallel(opt)

% opt = [];

% w = load('fit/fit_workspace_20160416T0400.mat');
% opt = w.opt;

par = 'soa+attcond'; % 'soa'

% soas
soas = [100:50:500 800];
rsoa = 1:10;
nsoa = numel(rsoa);

% att conds
condnames  =  {'no-endo','endoT1','endoT2','endoT1T2','exoT1','exoT2','exoT1T2'};
rcond = 2:4;
ncond = numel(rcond);

%% run in parallel
switch par
    case 'soa+attcond'
        parconds = fullfact([nsoa, ncond]);
        nparconds = size(parconds,1);
        parfor ipc = 1:nparconds
            isoa = parconds(ipc,1);
            icond = parconds(ipc,2);
            [pperfv{ipc}, pp{ipc}, pev{ipc}] = runModelTA(opt, rsoa(isoa), [], rcond(icond));
        end
    case 'soa'
        parfor isoa = 1:nsoa
            [pperfv{isoa}, pp{isoa}, pev{isoa}] = runModelTA(opt, rsoa(isoa));
        end
    otherwise
        error('par not found')
end

%% combine ev
% ev(:,isoa,icond,icontrast,iseq)
ev = [];
switch par
    case 'soa+attcond'
        for icond = 1:ncond
            for isoa = 1:nsoa
                ipc = (icond-1)*nsoa + isoa;
                if numel(size(pev{1}))==5
                    ev(:,isoa,icond,1,:) = pev{ipc};
                else
                    ev(:,isoa,icond,:,:) = pev{ipc};
                end
            end
        end
    case 'soa'
        for isoa = 1:nsoa
            if numel(size(pev{1}))==5
                ev(:,isoa,:,1,:) = pev{isoa};
            else
                ev(:,isoa,:,:,:) = pev{isoa};
            end
        end
    otherwise
        error('par not found')
end

%% plot multiple condition
perfv = plotPerformanceTA(condnames(rcond), soas(rsoa), mean(ev,5));

%% specify a p
p = pp{end};

    