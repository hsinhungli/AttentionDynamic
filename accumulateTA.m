function p = accumulateTA(p)
%
% p = accumulateTA(p)

%% Setup
if isempty(p.ceiling)
    evidenceCeiling = 0;
else
    evidenceCeiling = 1;
end

%% Accumulate
switch p.model
    case {1, 4}
        evidence = zeros(p.ntheta, size(p.decisionWindows,2), p.nstim);
        for iStim = 1:p.nstim
            dw = p.decisionWindows(iStim,:);
            evidence(:,:,iStim) = cumsum(p.r2.*repmat(dw,p.ntheta,1),2);
        end
    case 2
        evidence = cumsum(p.rwm,2);
    otherwise
        error('p.model not recognized')
end

% evidence ceiling
if evidenceCeiling
    evidence(evidence>p.ceiling) = p.ceiling;
end

%% Determine which decision was selected
% correct decision = 1, incorrect decision = -1
% take the first boundary crossing
for iStim = 1:p.nstim
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
guesses = (round(rand(p.nstim,1))-0.5)*2;
decision(decision==0) = guesses(decision==0);

%% Store things
p.evidence = evidence; 
p.decision = decision;

