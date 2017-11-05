% ideal_response_vector_empirical.m

%% setup
opt = [];
rsoa = 10;
rseqs = 1:4;
rcond = 1;

%% run
for iSeq = 1:numel(rseqs)
    rseq = rseqs(iSeq);
    [perfv, p(iSeq), ev] = runModelTA(opt, rsoa, rseq, rcond);
end

for iSeq = 1:numel(rseqs)
    r2 = p(iSeq).r2;
    r2(:,1:500) = 0; % ignore first stimulus response, which is always stim 1
    idx = find(sum(r2)==max(sum(r2)));
    resp(iSeq,:) = r2(:,idx);
end

%% save
[nStim, nRF] = size(p(1).rfresp);
save(sprintf('rf/resp_stim%d_rf%d_empirical_r2.mat', nStim, nRF), 'resp', 'p')
