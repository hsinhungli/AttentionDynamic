function p = setTaskTA(cond,p)

w = p.vAttWeights;

% set attention weights for T1 and T2
switch p.modelClass
    case '1-att'
        attWeights = w; % 1 = T1, 2 = T2
        
        exoWeights = p.iAttWeights;
        exoStart = p.stimOnset + p.exoSOA;
        exoEnd = exoStart + p.exoDur;
        
        % make involuntary attention input (same across features)
        timeSeries = zeros([p.ntheta p.nt 2]);
        timeSeries(:,unique(round((exoStart:p.dt:exoEnd)/p.dt)), 1) = exoWeights(1); % T1
        timeSeries(:,unique(round(((exoStart:p.dt:exoEnd) + p.soa)/p.dt)), 2) = exoWeights(2); % T2
        timeSeries = max(timeSeries,[],3);
        
        p.attIInput = timeSeries;
    otherwise
        switch cond
            case 'no-endo'
                attWeights = [0 0];
            case 'endoT1'
                attWeights = [w(1) w(2)]; % 1 = high, 2 = low
            case 'endoT2'
                attWeights = [w(2) w(1)];
            case 'endoT1T2'
                if p.distributeVoluntary
                    attWeights = w;
                else
                    switch p.neutralAttOp
                        case 'mean'
                            attWeights = [mean(w) mean(w)];
                        case 'max'
                            attWeights = [max(w) max(w)];
                    end
                end
            otherwise
                attWeights = [0 0];
        end
end
attWeights(2) = attWeights(2)*p.vAttScale2;

% start and end times of attention to T1
attStart = p.stimOnset + p.attOnset;
attEnd = p.stimOnset + p.stimDur + p.attOffset;

% make voluntary attention input (same across features)
timeSeries = zeros([p.ntheta p.nt 2]);
timeSeries(:,unique(round((attStart:p.dt:attEnd)/p.dt)), 1) = attWeights(1); % T1
timeSeries(:,unique(round(((attStart:p.dt:attEnd) + p.soa)/p.dt)), 2) = attWeights(2); % T2
timeSeries = max(timeSeries,[],3);

p.task = timeSeries;
