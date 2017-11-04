function [attn, attnExo] = distributeAttention2(span, condname, soa, neutralT1Weight, exoSOA, exoProp)
%
% function attn = distributeAttention2(span, cuedTime, soa, neutralT1Weight)
%
% takes into account exogenous attention
%
% INPUTS:
% span - time span over which there is limited attention, in ms
% cuedTime - cued time point (1 or 2)
% soa - proportion allocated to the cued time (0 to 1)
% neutralT1Weight - bias to treat neutral like attend to T1 (0 to 1, no bias = 0.5)
% exoSOA - the time between a stimulus and the exo response. here we model the exo response as instantaneous.
% exoProp - proportion of total attention used in an exo response (0 to 1)
%
% OUTPUTS:
% attn - 1x2 vector of attentional allocation to [T1 T2]
% attnExo - 1x2 vector of exogenous attentional allocation after each target [exoT1 exoT2]

%% check args
if nargin<1 || isempty(span)
    span = 1000;
end
if nargin<2 || isempty(condname)
    condname = 'endoT1';
end
if nargin<3 || isempty(soa)
    soa = 300;
end
if nargin<4 || isempty(neutralT1Weight)
    neutralT1Weight = 0.5;
end
if nargin<5 || isempty(exoSOA)
    exoSOA = 120;
end
if nargin<6 || isempty(exoProp)
    exoProp = 0.5;
end

totalAttn = 1;

%% determine cuedTime
switch condname
    case 'endoT1'
        cuedTime = 1;
    case 'endoT2'
        cuedTime = 2;
    case 'endoT1T2'
        cuedTime = 0;
    otherwise
        error('cond not recognized. note distributeAttention2 does not currently handle no-endo.')
end

%% times of attention events
timeT1 = 0;
timeT1Exo = timeT1 + exoSOA;
timeT2 = timeT1 + soa;
timeT2Exo = timeT2 + exoSOA;

%% allocate attention
switch cuedTime
    case 0
        % allocate according to bias to treat neutral like attend to T1 or T2
        attn(1) = totalAttn*neutralT1Weight; % bias in favor of T1
    case 1
        % allocate maximum to T1
        attn(1) = totalAttn; %totalAttn*attnProp;
    case 2
        % allocate maximum T1 that will allow attention to renew enough by
        % exo T1 so that there is maximum allocation to T2.
        % if soa is very long, attention does not need to completely
        % recover before exo T1.
        minStartingLevel = totalAttn-(timeT2-timeT1Exo)/span;
        minRecoveryLevel = min(totalAttn, minStartingLevel + exoProp);
        attn(1) = totalAttn*exoSOA/span + (totalAttn-minRecoveryLevel);
    otherwise
        error('cuedTime not recognized')
end
    
if timeT1Exo <= timeT2 % T1, T1 exo, T2, T2 exo
    % T1 exo
    availAfterT1 = totalAttn-attn(1); % available just after T1
    availAtT1Exo = availableAttention(exoSOA, span, availAfterT1);
    attnExo(1) = min(exoProp, availAtT1Exo);
    
    % T2
    availAfterT1Exo = availAtT1Exo-attnExo(1); % available just after T1 exo
    availAtT2 = availableAttention(soa-exoSOA, span, availAfterT1Exo);
    attn(2) = min(totalAttn, availAtT2);
    
    % T2 exo (irrelevant for our task, but we'll calculate it)
    availAfterT2 = availAtT2-attn(2); % available just after T2
    availAtT2Exo = availableAttention(exoSOA, span, availAfterT2);
    attnExo(2) = min(exoProp, availAtT2Exo);
else % T1, T2, T1 exo, T2 exo
    % T2
    availAfterT1 = totalAttn-attn(1); % available just after T1
    availAtT2 = availableAttention(soa, span, availAfterT1);
    attn(2) = min(totalAttn, availAtT2);
    
    % T1 exo
    availAfterT2 = availAtT2-attn(2); % available just after T2
    availAtT1Exo = availableAttention(exoSOA-soa, span, availAfterT2);
    attnExo(1) = min(exoProp, availAtT1Exo);
    
    % T2 exo (irrelevant for our task, but we'll calculate it)
    availAfterT1Exo = availAtT1Exo-attnExo(1); % available just after T1 exo
    availAtT2Exo = availableAttention(timeT2Exo-timeT1Exo, span, availAfterT1Exo);
    attnExo(2) = min(exoProp, availAtT2Exo);
end


    
