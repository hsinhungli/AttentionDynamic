function p = setStimTA(cond, p)

% start and end times of T1
stimStart = p.stimOnset;
stimEnd = p.stimOnset + p.stimDur;

% make stim
timeSeries = zeros([2 p.nt]);
timeSeries(1,(stimStart:p.dt:stimEnd)/p.dt) = 1; % T1
timeSeries(1,((stimStart:p.dt:stimEnd) + p.soa)/p.dt) = 1; % T2

switch cond
    case 'exoT1'
        timeSeries(1,((stimStart:p.dt:stimEnd) - p.exoCueSOA)/p.dt) = 1; % T1 cue
    case 'exoT2'
        timeSeries(1,((stimStart:p.dt:stimEnd) + p.soa - p.exoCueSOA)/p.dt) = 1; % T2 cue
    case 'exoT1T2'
        timeSeries(1,((stimStart:p.dt:stimEnd) - p.exoCueSOA)/p.dt) = 1; % T1 cue
        timeSeries(1,((stimStart:p.dt:stimEnd) + p.soa - p.exoCueSOA)/p.dt) = 1; % T2 cue
end

% scale by contrast
p.stim = timeSeries .* p.contrast;
