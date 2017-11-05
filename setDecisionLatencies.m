function p = setDecisionLatencies(p)

if nargin==0
    p.decisionRefractoryPeriod = 250;
    p.decisionWindowDur = 300;
    p.delay = 0;
    p.soa = 250;
    p.singleWindowSOA = 150;
%     condname = 'endoT1';
end

if p.soa > p.decisionWindowDur + p.decisionRefractoryPeriod
    % read out at the time of the stimuli if possible
    p.decisionLatency = [0 0];
elseif p.soa <= p.singleWindowSOA
    % same decision window
    p.decisionLatency = [0 -p.soa];
else
    p.decisionLatency = [0 -p.soa+p.decisionWindowDur+p.decisionRefractoryPeriod];
end

p.decisionLatency = p.decisionLatency + p.delay;