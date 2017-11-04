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
plotFig    = 0;
plotPerformance = 0;

% Conditions
contrasts = [0 .01 .02 .04 .08 0.16 0.32 0.64 1];
soas      = [100:50:500 800];
stimseqs  = {[1 1],[1 2],[1 3],[1 4]};

% Pick conditions to run
rcontrast = 8; %1:numel(contrasts);   %contrast levels to run
ncontrast = numel(rcontrast);

if ~exist('rcond','var') || isempty(rcond)
    rcond = 2:3; %2:4;   %conditions to run
end
ncond = numel(rcond);

if ~exist('rsoa','var') || isempty(rsoa)
    rsoa = 1:numel(soas); %[1 3 5 7 9 10]; %1:numel(soas);   %soa levels to run
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

%% all the setup (for debugging)
% ev = zeros(2,nsoa,ncond,ncontrast);
% icond = 1; icontrast = 1; isoa = 1; iseq = 1;
% cond = rcond(icond);
% condname = condnames{cond};
% c = rcontrast(icontrast);
% s = rsoa(isoa);

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
                    switch p.modelClass
                        case '1-att'
                            [p.vAttWeights, p.iAttWeights] = ...
                                distributeAttention2(p.span, condname, p.soa, p.neutralT1Weight, p.exoSOA, p.exoProp);
                        otherwise
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
                for iStim = 1:2
                    p.evidence(:,:,iStim) = p.rd(iStim,:);
                end
                p.ev = squeeze(p.evidence(:,end,:))';
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
