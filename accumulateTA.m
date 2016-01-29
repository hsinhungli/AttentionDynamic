function p = accumulateTA(cond, p)
%
% p = accumulateTA(p)
%
% separate decision window for each stimulus
% assume that the accumulation starts at stimulus onset and lasts until the
% next stimulus. use the same interval for the final stimulus.

%% Setup
if isempty(strfind(cond, 'exo'))
    exoCueSOA = 0;
%     exoCueSOA = p.exoCueSOA;
else
    exoCueSOA = p.exoCueSOA;
end
decisionWindowDur = p.soa - exoCueSOA;
stimStarts = [p.stimOnset p.stimOnset+p.soa];
nStim = numel(stimStarts);
if isempty(p.ceiling)
    evidenceCeiling = 0;
else
    evidenceCeiling = 1;
end

%% Accumulate
decisionWindows = [];
for iStim = 1:nStim
    decisionWindows(iStim,:) = round((stimStarts(iStim):stimStarts(iStim)+decisionWindowDur)./p.dt); % indices
end
decisionWindows = unique(decisionWindows','rows')';  

evidence = zeros([size(decisionWindows) nStim]);
for iStim = 1:nStim
    dw = decisionWindows(iStim,:);
    evidence(:,:,iStim) = cumsum(p.r2(:,dw),2);
end

% evidence ceiling
if evidenceCeiling
    evidence(evidence>p.ceiling) = p.ceiling;
end

%% Determine which decision was selected
% correct decision = 1, incorrect decision = -1
% take the first boundary crossing
for iStim = 1:nStim
    cc = find(evidence(1,:,iStim) >= p.bounds(1), 1, 'first'); % look only at first feature row in this simulation
    ic = find(evidence(1,:,iStim) <= p.bounds(2), 1, 'first');
    
    if isempty(cc) && isempty(ic) % no crossing
        d = 0;
    elseif isempty(ic) && cc > 0  % only correct crossing
        d = 1;
    elseif isempty(cc) && ic > 0 % only incorrect crossing
        d = -1;
    else
        d = (cc < ic) - (ic < cc); % both cross, find the earliest
    end
    decision(iStim) = d;
end

% if there is no decision from evidence, guess randomly
guesses = (round(rand(nStim,1))-0.5)*2;
decision(decision==0) = guesses(decision==0);

%% Store things
p.decisionWindows = decisionWindows;
p.evidence = squeeze(evidence(1,:,:)); % look only at first feature row in this simulatio
p.decision = decision;

