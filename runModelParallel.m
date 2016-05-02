function [perfv, p, ev] = runModelParallel(opt)

% opt = [];
parallelize = 'seq'; % 'soa','seq'

switch parallelize
    case 'soa'
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
        
    case 'seq'
        rseq = 1:4;
        nseq = numel(rseq);
        
        %% run seqs in parallel
        parfor iseq = 1:nseq
            [pperfv{iseq}, pp{iseq}, pev{iseq}] = runModelTA(opt, [], rseq(iseq));
        end
        
        %% assign outputs
        perfv = pperfv;
        p = pp;
        ev = pev;
        
    otherwise
        error('parallelize option not found')
end

    