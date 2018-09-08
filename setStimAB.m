function p = setStimAB(cond, p)

% start and end times of T1
stimStart = p.stimOnset;
stimEnd = p.stimOnset + p.stimDur;

% AB settings
streamSOA = 100; 
nCushion = 2;
streamAmp = 0.5;
streamStarts = (stimStart - nCushion*streamSOA):streamSOA:...
    (stimStart + p.soa + nCushion*streamSOA);
nStream = numel(streamStarts);

% initialize time series
timeSeries = zeros([p.ntheta p.nt]);

% make target stim
timeSeries(p.stimseq(1),unique(round((stimStart:p.dt:stimEnd)/p.dt))) = 1; % T1
timeSeries(p.stimseq(2),unique(round(((stimStart:p.dt:stimEnd) + p.soa)/p.dt))) = 1; % T2

% make AB stim
for iStream = 1:nStream
    streamStart = streamStarts(iStream);
    streamEnd = streamStart + p.stimDur;
    if streamStart~=stimStart && streamStart~=stimStart+p.soa
%         orient = randi(4);
        orient = 3;
        timeSeries(orient, unique(round((streamStart:p.dt:streamEnd)/p.dt))) = streamAmp; % distractor
    end
end

% scale by contrast
% p.stim = timeSeries .* p.contrast;
p.stim = timeSeries;