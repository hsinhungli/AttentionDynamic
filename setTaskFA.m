function p = setTaskFA(cond,p)

w = p.vAttWeights;

% set attention weights for F1 and F2
switch cond
    case 'no-endo'
        attWeights = [0 0];
    case 'endoF1'
        attWeights = [w(1) w(2)]; % 1 = high, 2 = low
    case 'endoF2'
        attWeights = [w(2) w(1)];
    case 'endoF1F2'
        switch p.neutralAttOp
            case 'mean'
                attWeights = [mean(w) mean(w)];
            case 'max'
                attWeights = [max(w) max(w)];
        end
    otherwise
        attWeights = [min(w) min(w)];
end

% start and end times of attention
attStart = p.stimOnset + p.attOnset;
attEnd = p.stimOnset + p.stimDur + p.attOffset;

% make voluntary attention input 
timeSeries = zeros([2 p.nt]);
timeSeries(1,(attStart:p.dt:attEnd)/p.dt) = attWeights(1); % F1
timeSeries(2,(attStart:p.dt:attEnd)/p.dt) = attWeights(2); % F2

p.task = timeSeries;
