function p = setStimTA(p)

% start and end times of T1
stimStart = p.stimOnset;
stimEnd = p.stimOnset + p.stimDur;

% make stim
timeSeries = zeros([2 p.nt]);
timeSeries(1,(stimStart:p.dt:stimEnd)/p.dt) = 1; % T1
timeSeries(1,((stimStart:p.dt:stimEnd) + p.soa)/p.dt) = 1; % T2

% scale by contrast
p.stim = timeSeries .* p.contrast;
