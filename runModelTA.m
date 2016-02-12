function [perfv, p] = runModelTA(opt)

% modified from runModel.m
% 2015-09-28 (RD)

% clear all
if nargin==0
    opt = [];
end

%% Set params
p          = setParametersFA(opt);
% p          = setParametersFA;

%% Set conditions/contrasts to simulate
condnames  =  {'no-endo','endoT1','endoT2','endoT1T2','exoT1','exoT2','exoT1T2'};
saveData   = 0;
plotFig    = 0;

% Pick contrasts to run
% logspace(-1.699,log10(.5),7)
% 0.0200    0.0342    0.0585    0.1000    0.1710    0.2924    0.5000
contrasts = [0.16 0.64];
soas      = [100:50:500 800];
% soas     = [100:10:800];
stimseqs  = {[1 1],[1 2],[2 1],[2 2]};

% Pick conditions to run
rcond     = 2:3;   %conditions to run
ncond     = numel(rcond);
rcontrast = 2;   %contrast levels to run
ncontrast = numel(rcontrast);
rsoa      = 1:numel(soas);   %soa levels to run
nsoa      = numel(rsoa);
rseq      = 4;
nseq      = numel(rseq);
p_pool    = cell(ncond*ncontrast*nsoa,1); %data (p) of each simulated condition will be saved here

condtag  = regexprep(num2str(rcond),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));

% Load rf
rf = load(p.rf,'resp');
p.rfresp = rf.resp;

%% loop through all conditions to run
count = 0;
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
                q = rseq(iseq);
                p.cond = cond;
                p.contrast = contrasts(:,c);
                p.soa = soas(:,s);
                p.nstim = numel(p.soa)+1;
                p.stimseq = stimseqs{q};
                fprintf('cond: %s contrast: %1.2f soa: %d seq: %d %d\n\n', condname, p.contrast, p.soa, p.stimseq)
                count = count+1;
                p = initTimeSeriesFA(p);
                p = setStimTA(condname,p);
                p = setTaskTA(condname,p);
                
%                 %Stimulus inputs
%                 p.i = p.stim;
%                 
%                 % convolve input with a temporal filter
%                 p.e = [];
%                 for i=1:size(p.i,1)
%                     p.e(i,:) = conv(p.i(i,:), p.filter_e);
%                 end
%                 p.e = p.e(:,1:p.nt);
                
                %run the model
                p = n_model_FA(p);
                
                % convolve output with a temporal filter
                p.r2 = [];
                for i=1:size(p.r,1)
                    p.r2(i,:) = conv(p.r(i,:), p.filter_r2);
                end
                p.r2 = p.r2(:,1:p.nt);
                
                %accumulate evidence
                p = accumulateTA(condname,p);
                if isempty(p.rf)
                    p.ev = squeeze(p.evidence(1,end,:)); % take the first feature
                else
                    p.ev(1) = decodeEvidence(p.evidence(:,end,1)', p.rfresp); % stim 1
                    p.ev(2) = decodeEvidence(p.evidence(:,end,2)', p.rfresp); % stim 2
                end
                ev(:,isoa,icond,icontrast) = p.ev;
                
                %save the p
                if saveData==1
                    p = rmfield(p,{'d','s','f','d_n'});
                end
                p_pool{count} = p;
                
                %% Draw time series_1
                if plotFig == 1
                    %                 plotTA(condname, p)
                    plotFA2(condname, p)
                end
            end
        end
    end
end

%% plot multiple conditions
for icontrast = 1:numel(rcontrast)
    perfv = plotPerformanceTA(condnames(rcond), soas(rsoa), ev(:,:,:,icontrast));
end

%% save data
if saveData==1
    sprintf('Saving file')
    save(dataName,'p_pool');
end
% fprintf('\n')
