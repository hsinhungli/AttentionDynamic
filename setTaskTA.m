function p = setTaskTA(cond,p)

w = p.vAttWeights;

% set attention weights for T1 and T2
switch cond
    case 'no-endo'
        attWeights = [0 0];
    case 'endoT1'
        attWeights = [w(1) w(2)]; % 1 = high, 2 = low
    case 'endoT2'
        attWeights = [w(2) w(1)];
    case 'endoT1T2'
        switch p.neutralAttOp
            case 'mean'
                attWeights = [mean(w) mean(w)];
            case 'max'
                attWeights = [max(w) max(w)];
        end
    otherwise
        attWeights = [0 0];
end

% start and end times of attention to T1
attStart = p.stimOnset + p.attOnset;
attEnd = p.stimOnset + p.stimDur + p.attOffset;

% make voluntary attention input (same across features)
timeSeries = zeros([2 p.nt 2]);
timeSeries(:,unique(round((attStart:p.dt:attEnd)/p.dt)), 1) = attWeights(1); % T1
timeSeries(:,unique(round(((attStart:p.dt:attEnd) + p.soa)/p.dt)), 2) = attWeights(2); % T2
timeSeries = max(timeSeries,[],3);

p.task = timeSeries;