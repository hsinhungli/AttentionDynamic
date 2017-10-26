function [perfv, p, ev] = runModelTA(opt, rsoa, rseq, rcond)

% modified from runModel.m
% 2015-09-28 (RD)

% clear all
if nargin==0
    opt = [];
end

%% Set params
p          = setParametersFA(opt);

%% Set conditions/contrasts to simulate
condnames  =  {'no-endo','endoT1','endoT2','endoT1T2','exoT1','exoT2','exoT1T2'};
plotFig    = 1;
plotPerformance = 1;

% Conditions
contrasts = [0 .01 .02 .04 .08 0.16 0.32 0.64 1];
soas      = [100:50:500 800];
stimseqs  = {[1 1],[1 2],[1 3],[1 4]};

% Pick conditions to run
rcontrast = 8; %1:numel(contrasts);   %contrast levels to run
ncontrast = numel(rcontrast);

if ~exist('rcond','var') || isempty(rcond)
    rcond = 2:4;   %conditions to run
end
ncond = numel(rcond);

if ~exist('rsoa','var') || isempty(rsoa)
    rsoa = [1 4 10]; %1:numel(soas);   %soa levels to run
end
nsoa = numel(rsoa);

if ~exist('rseq','var') || isempty(rseq)
    rseq = 3; % 1:2 % sequences to run
end
nseq = numel(rseq);

% Load rf
if ~isempty(p.rf)
    rf = load(p.rf,'resp');
    p.rfresp = rf.resp;
end

%% loop through all conditions to run
ev = zeros(2,nsoa,ncond,ncontrast);
for icond = 1:numel(rcond)
    cond = rcond(icond);
    condname = condnames{cond};
    
    %% Loop through contrast levels
    for icontrast = 1:ncontrast
        c = rcontrast(icontrast);
        for isoa = 1:nsoa
            s = rsoa(isoa);
            for iseq = 1:nseq
                % set conditions
                q = rseq(iseq);
                p.cond = cond;
                p.contrast = contrasts(:,c);
                p.soa = soas(:,s);
                p.nstim = numel(p.soa)+1;
                p.stimseq = stimseqs{q};
                fprintf('cond: %s contrast: %1.2f soa: %d seq: %d %d\n\n', condname, p.contrast, p.soa, p.stimseq)
                
                % distribute voluntary attention
                if p.distributeVoluntary
                    totalAtt = 1 + p.soa/p.span;
                    if totalAtt>2
                        totalAtt = 2;
                    end
                    if strcmp(condname, 'endoT1T2')
                        p.vAttWeights = distributeAttention(totalAtt, 0, [], p.neutralT1Weight);
                    else
                        p.vAttWeights = distributeAttention(totalAtt, 1, 1);
                    end
                    p.vAttWeight1 = p.vAttWeights(1);
                    p.vAttWeight2 = p.vAttWeights(2);
                end
                
                % set time series
                p = initTimeSeriesFA(p);
                p = setStimTA(condname,p);
                p = setTaskTA(condname,p);
                p = setDecisionWindowsTA(condname,p);

                %run the model
                p = n_model_FA(p);

                %accumulate evidence
%                 p = accumulateTA(p);
                if isempty(p.rf)
                    % take the difference between evidence for the correct
                    % vs. incorrect feature
                    ev_s1 = squeeze(p.evidence(:,end,1)); % stim 1
                    ev_s2 = squeeze(p.evidence(:,end,2)); % stim 2
                    corr = p.stimseq;
                    incorr = 3-p.stimseq;
                    p.ev(1) = ev_s1(corr(1)) - ev_s1(incorr(1)); % stim 1
                    p.ev(2) = ev_s2(corr(2)) - ev_s2(incorr(2)); % stim 2
                    
                    % take the first feature
%                     p.ev = squeeze(p.evidence(1,end,:)); 
                else
                    for iStim = 1:2
                        p.evidence(:,:,iStim) = p.rd(iStim,:);
                    end
                    p.ev = squeeze(p.evidence(:,end,:))';
                end
                % make evidence positive for the correct stimulus
                p.ev = p.ev.*(-1).^p.stimseq; % flip sign for CCW (odd #s)
                % store evidence
                ev(:,isoa,icond,icontrast,iseq) = p.ev;
                
                %% Draw time series
                if plotFig
                    plotFA2(condname, p)
                end
            end
        end
    end
end

%% plot multiple conditions
if plotPerformance
    for icontrast = 1:numel(rcontrast)
        perfv = plotPerformanceTA(condnames(rcond), soas(rsoa), mean(ev(:,:,:,icontrast,:),5));
    end
else
    perfv = [];
end
