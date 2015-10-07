function [domD,domD_p,durationDist,durationDist_vr,ptime_v] = getDominanceDuration(p,data1,data2,filter_duration,threshold_ratio)
%This function filter the data with a box function, of which length
%determined by "filter_duration", and then compute the dominance duration
%of each phase. The valid phase was threshold either by ratio of response
%of duration.
% domD: dominance duration, one for each iteration (for computing Levelt's
%II)
% durationDist: Distribution of dominance duration (pooled).
% durationDist_vr: Distribution of dominance duration, only use valid phase (pooled).
% ptime_v:proportion of time counted as valid.

%threshold: shortest dominance duration
%data1 = squeeze(p.r{3}(1,:));
%data2 = squeeze(p.r{3}(2,:));
% filter_duration = 200;
% threshold_t = 200;
% threshold_ratio = 2;

%smoothing
kernel = ones(1,filter_duration/p.dt);
kernel = kernel./sum(kernel);
data1  = conv(data1,kernel,'valid');
data2  = conv(data2,kernel,'valid');

%
domD = nan(1,2);
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
    
    phaseduration = (offsetIdx - onsetIdx)*p.dt; %duration of each phase
    domD(iter)   = mean(phaseduration); %Dominance duration for each iteration (for Levelt's II)
    durationDist = [durationDist phaseduration];
    onset        = [onset onsetIdx];
    offset       = [offset offsetIdx];
    phase        = [phase ones(1,length(phaseduration))*iter];
end
domD_p = mean(domD); %Dominance duration pooled over iteration

nphs  = length(durationDist);
ratio = nan(1,length(onset));
for phs = 1:nphs
    temp1 = data1(onset(phs):offset(phs))./data2(onset(phs):offset(phs));
    ratio1 = nanmean(temp1);
    temp2 = data2(onset(phs):offset(phs))./data1(onset(phs):offset(phs));
    ratio2 = nanmean(temp2);
    ratio(phs) = max([ratio1 ratio2]);
end

%Define a threshold using response ratio
Idx = ratio>threshold_ratio;
durationDist_vr = durationDist(Idx);
phase_v = phase(Idx);
ptime_v = sum(durationDist_vr)/p.tlist(end);

% Idx = durationDist>threshold_t;
% durationDist_vt = durationDist(Idx);
% Idx = durationDist>threshold_t & ratio>threshold_ratio;
% durationDist_v = durationDist(Idx);




