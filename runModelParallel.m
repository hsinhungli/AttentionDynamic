function [perfv, p, ev] = runModelParallel(opt, modelClass)

if nargin < 1
    opt = [];
end
if nargin < 2
    modelClass = '';
end

% opt = [];
% w = load('fit/fit_workspace_20160416T0400.mat');
% w = load('fit/fit_workspace_20171108T2029_job2922634_transientSpan.mat');
% opt = w.opt;

par = 'soa+attcond'; % 'soa+attcond','soa','seq'

% soas
soas = [100:50:500 800];
rsoa = 1:10;
nsoa = numel(rsoa);

% att conds
condnames  =  {'no-endo','endoT1','endoT2','endoT1T2','exoT1','exoT2','exoT1T2'};
rcond = 2:4; %2:3, 2:4;
ncond = numel(rcond);

% seqs
stimseqs  = {[1 1],[1 2],[1 3],[1 4]};
rseq = 3; %1:4;
nseq = numel(rseq);

%% run in parallel
switch par
    case 'soa+attcond'
        parconds = fullfact([nsoa, ncond]);
        nparconds = size(parconds,1);
        parfor ipc = 1:nparconds
            isoa = parconds(ipc,1);
            icond = parconds(ipc,2);
            [pperfv{ipc}, pp{ipc}, pev{ipc}] = runModelTA(opt, modelClass, rsoa(isoa), [], rcond(icond));
        end
    case 'soa'
        parfor isoa = 1:nsoa
            [pperfv{isoa}, pp{isoa}, pev{isoa}] = runModelTA(opt, modelClass, rsoa(isoa));
        end
    case 'seq'
        parfor iseq = 1:nseq
            [pperfv{iseq}, pp{iseq}, pev{iseq}] = runModelTA(opt, modelClass, [], rseq(iseq));
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
        p = pp{end}; % specify a p
        perfv = plotPerformanceTA(condnames(rcond), soas(rsoa), mean(ev,5));
    case 'soa'
        for isoa = 1:nsoa
            if numel(size(pev{1}))==5
                ev(:,isoa,:,1,:) = pev{isoa};
            else
                ev(:,isoa,:,:,:) = pev{isoa};
            end
        end
        p = pp{end};
        perfv = plotPerformanceTA(condnames(rcond), soas(rsoa), mean(ev,5));
    case 'seq'
        perfv = pperfv;
        p = pp;
        ev = pev;
        for iseq = 1:nseq
            plotPerformanceTA(condnames(rcond), soas(rsoa), ev{iseq});
        end
    otherwise
        error('par not found')
end


    