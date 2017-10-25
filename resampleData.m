function D = resampleData(dataDir)

%% setup
if nargin==0
    dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
end

subjects = {'rd','hl','ho','vp'};
nSubjects = numel(subjects);
nboot = 1;

%% take a bootstrap
for iS = 1:nSubjects
    fileName = sprintf('%s/E2_SOA_cbD6_%s_run98_alldata', dataDir, subjects{iS});
    load(fileName)
    expt = E{1};
    correctIdx = strcmp(expt.trials_headers,'correct');
    nSOA = numel(soas);
    
    for iSOA = 1:nSOA
        results = R{iSOA};
        for iT = 1:2
            for iV = 1:3
                vals = results.totals.all{iV,iT}(:,correctIdx);
                m = bootstrp(nboot, @mean, vals);
                acc(iV,iT,iSOA,iS) = m;
            end
        end
    end
end

accMean = mean(acc,4);

%% calculate dprime, format and store
for iT = 1:2
    for iV = 1:3
        for iSOA = 1:nSOA
            D.accMean{iT}(iV,iSOA) = accMean(iV,iT,iSOA);
            D.dpMean{iT}(iV,iSOA) = rd_dprime(accMean(iV,iT,iSOA),[],'2afc','adjust');
        end
    end
end

D.t1t2soa = soas;

