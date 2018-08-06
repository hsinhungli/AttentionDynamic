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
    if isempty(p.decisionWindowDur)
        % integrate until next stimulus or end of trial
        if iStim==p.nstim
            idx = round((decisionOnsets(iStim)/p.dt):size(p.stim,2)); % last stim - integrate to the end
        else
            idx = round((decisionOnsets(iStim)/p.dt):(decisionOnsets(iStim)/p.dt)+decisionWindowDur/p.dt);
        end
    else
        % fixed decision window
        idx = round((decisionOnsets(iStim)/p.dt):(decisionOnsets(iStim)/p.dt)+decisionWindowDur/p.dt);
    end
    p.decisionWindows(iStim,idx) = 1;
end

% adjust for specific models - only handles 2 stim!!
switch p.modelClass
    case '3S'
        if p.soa < p.decisionWindowDur
            % reset T1 decision window
            p.decisionWindows(1,:) = 0;
            % let T1 decision window end at second stim
            decisionWindowDur = p.soa - exoCueSOA;
            idx = round((decisionOnsets(1)/p.dt):(decisionOnsets(1)/p.dt)+decisionWindowDur/p.dt);
            p.decisionWindows(1,idx) = 1;
        end
end

