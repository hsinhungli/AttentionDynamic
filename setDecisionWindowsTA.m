function p = setDecisionWindowsTA(cond, p)

%% Setup
if isempty(strfind(cond, 'exo'))
    exoCueSOA = 0;
else
    exoCueSOA = p.exoCueSOA;
end
if isempty(p.decisionWindowDur)
    decisionWindowDur = p.soa - exoCueSOA;
else
    decisionWindowDur = p.decisionWindowDur;
end
decisionOnsets = [p.stimOnset p.stimOnset+p.soa] + p.decisionLatency;

%% Define decision windows
p.decisionWindows = zeros(p.nstim,p.nt);
for iStim = 1:p.nstim
%     if iStim==p.nstim
%         idx = round((stimStarts(iStim)/p.dt):size(p.stim,2)); % last stim - integrate to the end
%     else
        idx = round((decisionOnsets(iStim)/p.dt):(decisionOnsets(iStim)/p.dt)+decisionWindowDur/p.dt);
%     end
    p.decisionWindows(iStim,idx) = 1;
end

