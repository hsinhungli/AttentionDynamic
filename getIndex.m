function p = getIndex(p,filter_duration,threshold_t,threshold_ratio)

% filter_duration = 200;
% threshold_t     = 200; %ms
% threshold_ratio = 2;

%% Winner take all Index
% if ismember(p.cond,[3 4]) %Monocular Plaid
%     data1 = squeeze(p.r{1}(1,:));
%     data2 = squeeze(p.r{1}(2,:));
% else
%     data1 = squeeze(p.r{1}(1,:));
%     data2 = squeeze(p.r{2}(2,:));
% end

data1 = squeeze(p.r{3}(1,:));
data2 = squeeze(p.r{3}(2,:));

temp1 = data1(p.tlist>100);
temp2 = data2(p.tlist>100);
p.Idx_corr = corr(temp1',temp2');
p.Idx_mean = mean([temp1 temp2]);
p.Idx_wta  = nanmean(abs(temp1-temp2) ./ (temp1+temp2));
p.Idx_diff = nanmean(abs(temp1-temp2));
p.Idx_noiseamp = nanstd([data1 data2]);

p.ratio = [temp1(temp1>temp2)./temp2(temp1>temp2) temp2(temp1<temp2)./temp1(temp1<temp2)];
p.ratio = min(p.ratio,10);
p.Idx_ratio = nanmean(p.ratio);

[dominanceDuration,domD_p,durationDist,durationDist_v,ptime_v] = ...
    getDominanceDuration(p,data1,data2,filter_duration,threshold_ratio);
p.Idx_domD       = dominanceDuration/1000;
p.Idx_domD_p     = domD_p/1000;
p.durationDist   = durationDist/1000;
p.durationDist_v = durationDist_v/1000;
p.Idx_ptime_v    = ptime_v;
p.Idx_cv         = std(p.durationDist) / mean(p.durationDist);
p.Idx_cv_v       = std(p.durationDist_v) / mean(p.durationDist_v);

% The coefficient of variation of the dominance durations,
% CV, defined as the ratio between the standard deviation
% and the mean, varies between 0.4 and 0.6

%% Rivalry Index and Dominance duration: This code should only be used to replicate Zheng Neuron 2011
% if smooth == 1
%     [tempEpoch,tempEpochr,domD, durationDist, phaseIdx] = getEpoch(p,data1,data2,epochlength,filter_std,getrivalryIdx);
%     p.aSignal = mean(tempEpoch,1);
%     p.rSignal = mean(tempEpochr,1);
%     
%     p.Idx_rivalry  = abs(max(p.rSignal)-min(p.rSignal))/abs(max(p.aSignal)-min(p.aSignal));
%     p.Idx_domD     = domD/1000;
%     p.durationDist = durationDist/1000;
%     p.phaseIdx     = phaseIdx;
%     p.Idx_cv       = std(p.durationDist) / mean(p.durationDist);
%     p.aEpoch       = tempEpoch;
%     p.rEpoch       = tempEpochr;
%     
%     if length(unique(p.phaseIdx)) == 1
%         p.wta = 1;
%     else
%         p.wta = 0;
%     end
% end

