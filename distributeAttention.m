function attn = distributeAttention(totalAttn, cuedTime, attnProp)
%
% function attn = distributeAttention(totalAttn, cuedTime, attnProp)
%
% INPUTS:
% totalAttn - total attention available over the two time points (1 to 2
% cuedTime - cued time point (1 or 2)
% attnProp - proportion allocated to the cued time (0 to 1)
%
% OUTPUTS:
% attn - 1x2 vector of attentional allocation to [T1 T2]

%% check args
if nargin<1 || isempty(totalAttn)
    totalAttn = 1;
end
if nargin<2 || isempty(cuedTime)
    cuedTime = 1;
end
if nargin<3 || isempty(attnProp)
    attnProp = 0.75;
end

if totalAttn<1 || totalAttn>2
    error('totalAttn must be between 1 and 2')
end

cu = [cuedTime 3-cuedTime]; % [cued uncued]

%% neutral cue
if cuedTime==0
    attn = [totalAttn totalAttn]./2;
end

%% cue T1 or T2
if cuedTime~=0
    % allocate according to cue validity
    attn(cu(1)) = totalAttn*attnProp;
    attn(cu(2)) = totalAttn*(1-attnProp);
    
    % check if attn exceeds 100% at either time point
    if attn(cu(1)) > 1
        extra = attn(cu(1))-1;
        attn(cu(1)) = 1;
        attn(cu(2)) = attn(cu(2))+extra;
    end
end

%% test
% for i=1:1000
%     attn(i,:) = distributeAttention(1 + i/1000);
% end
% plot(attn)
% ylim([0 1])
% legend('cued','uncued','location','best')
% xlabel('soa')
% ylabel('attention allocated')
