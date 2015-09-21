function [dominanceDuration,durationDist,durationDist_v,ptime_v,phase_v] = getDominanceDuration(p,data1,data2,threshold_t,threshold_ratio)
%threshold: shortest dominance duration
data1 = squeeze(p.r{3}(1,:));
data2 = squeeze(p.r{3}(2,:));
filter_duration = 200;
threshold_t = 200;
threshold_ratio = 2;

%smoothing
kernel = ones(1,filter_duration/p.dt);
kernel = kernel./sum(kernel);
data1 = conv(data1,kernel,'valid');
data2 = conv(data2,kernel,'valid');

%
dominanceDuration = nan(1,2);
durationDist = [];
onset  = [];
offset = [];
phase  = [];
for iter = 1:2
    if iter ==1
        phaseIdx  = data1>data2;
    elseif iter ==2
        phaseIdx  = data2>data1;
    end
    
    %get Dominance duration
    reversalIdx  = diff([0 phaseIdx]);
    onsetIdx     = find(reversalIdx==1);
    reversalIdx  = diff([phaseIdx 0]);
    offsetIdx    = find(reversalIdx==-1);
    phaseduration = (offsetIdx - onsetIdx)*p.dt;
    dominanceDuration(iter) = mean(phaseduration);
    durationDist = [durationDist phaseduration];
    onset        = [onset onsetIdx];
    offset       = [offset offsetIdx];
    phase        = [phase ones(1,length(phaseduration))*iter];
end

nphs  = length(durationDist);
ratio = nan(1,length(onset));
for phs = 1:nphs
    temp1 = data1(onset(phs):offset(phs))./data2(onset(phs):offset(phs));
    temp2 = data2(onset(phs):offset(phs))./data1(onset(phs):offset(phs));
    ratio(phs) = max([temp1 temp2]);
end

Idx = durationDist>threshold_t;
durationDist_vt = durationDist(Idx);
Idx = ratio>threshold_ratio;
durationDist_vr = durationDist(Idx);
Idx = durationDist>threshold_t & ratio>threshold_ratio;
durationDist_v = durationDist(Idx);
phase_v = phase(Idx);
ptime_v = sum(durationDist_v)/p.tlist(end);


