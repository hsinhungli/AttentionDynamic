function p = setStimFA(cond, p)

% start and end times of T1
stimStart = p.stimOnset;
stimEnd = p.stimOnset + p.stimDur;

% make stim
timeSeries = zeros([2 p.nt]);
timeSeries(1,(stimStart:p.dt:stimEnd)/p.dt) = 1; % F1
timeSeries(2,(stimStart:p.dt:stimEnd)/p.dt) = 1; % F2

switch cond
    case 'exoF1'
        timeSeries(1,((stimStart:p.dt:stimEnd) - p.soa)/p.dt) = 1; % F1 cue
    case 'exoF2'
        timeSeries(2,((stimStart:p.dt:stimEnd) - p.soa)/p.dt) = 1; % F2 cue
    case 'exoF1F2'
        timeSeries(:,((stimStart:p.dt:stimEnd) - p.soa)/p.dt) = 1;
end

% scale by contrast
p.stim = timeSeries .* p.contrast;
