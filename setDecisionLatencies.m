function decisionLatencies = setDecisionLatencies(decisionRefractoryPeriod, decisionWindowDur, soa, condname)

if nargin==0
    decisionRefractoryPeriod = 250;
    decisionWindowDur = 300;
    soa = 250;
    condname = 'endoT1';
end

if soa > decisionWindowDur + decisionRefractoryPeriod
    % read out at the time of the stimuli if possible
    decisionLatencies = [0 0];
elseif soa < decisionWindowDur
    % same decision window
    decisionLatencies = [0 -soa];
else
    decisionLatencies = [0 -soa+decisionWindowDur+decisionRefractoryPeriod];
end