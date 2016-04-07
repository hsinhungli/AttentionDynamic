function p = setParametersFA(opt)

% function p = setParametersFA(opt)
%
% opt is a structure containing values of p fields. will overwrite existing values. 

%% Deal with input
if ~exist('opt','var')
    opt = [];
end

%% Model
p.model         = 1; % 1 (IOR), 2 (WM), 4 (feedback)
p.rf            = 'rf/resp_stim4_rf6.mat'; % sensory RFs - encode stim and decode responses using saved RFs. [] for none.

%% Temporal Parameters
%Expeirment parameters
p.dt            = 2;                        %time-step (ms)
p.T             = 2.1*1000;                  %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tau             = 90;  %2,90,20                   %time constant (ms)
p.tauwm           = 20;                    % time constant of working memory (ms)
p.tau_a           = 99;                     %time constant adaptation (ms)
p.tau_attI        = 50;  %50                %time constant involuntary attention (ms)
p.tau_attV        = 50;  %50               %time constant voluntary attention (ms)
p.tau_r2          = 2;  %80,120                   %time constant filter for firing rate (ms)
p.tau_n           = 99; %100                   %time constant noise (ms)
p.d_noiseamp      = 0; % 0.0015;
filter_r2         = exp(-p.tlist/p.tau_r2); % exponential
p.filter_r2       = filter_r2/sum(filter_r2);     %temporal filter for firing rate
p.nRCascades      = 1;

p.tau_i           = 80;  %20             %time constant filter for excitatory response (ms)
filter_i          = (p.tlist/p.tau_i).*exp(1-p.tlist/p.tau_i); % alpha
p.filter_i        = filter_i/sum(filter_i);     %temporal filter for input
% p.tau_att         = 99;                    %time constant attention (ms)
% p.tau_h           = 99;  %50               %time constant inhibitory component of involuntary attention (ms)
% p.nAttICascades   = 2;                      % involuntary attention, number of cascades to turn exponential into gamma
% p.nHCascades      = 4;                      % h, number of cascades to turn exponential into gamma

%% Spatial & Neuronal Parameters
p.x             = 0;                %Sampling of space
p.nx            = numel(p.x);
if isempty(p.rf)
    p.ntheta    = 2;                %Sampling of orientation
else
    p.ntheta    = 6;
end
p.baselineMod   = 0;
p.p             = 2;
p.sigma         = .5; %.5 .1              %semisaturation constant
p.wa            = 0;               %weights of self-adaptation

% p.baselineAtt   = 1;
% p.wh            = 3; %1.5;               %weight of inhibitory involuntary attention

%% Sensory layer 2
p.sigma2        = .1;
p.wF            = 2; %.05;                     % weight of S2 feedback onto S1
if p.model~=4
    p.wF = 0;                           % should be zero if not Model 4
end

% p.gam1_s2W      = 2; %8
% p.gam2_s2W      = .2; %.02
% p.s2W           = repmat(makeGamma(0:p.dt/1000:1.5,[],p.gam1_s2W,p.gam2_s2W,1),p.ntheta,1);
p.biph1_s2W       = 25;
p.biph2_s2W       = 1;
p.s2W             = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1_s2W,round(p.biph2_s2W)),p.ntheta,1);

%% Working memory
p.sigmawm       = 1; %.1, .01
p.tau_wmW       = 200;                   % temporal receptive field
p.gam1_wmW      = 2; %8
p.gam2_wmW      = .2; %.02
% filter_wm       = exp(-p.tlist/p.tau_wmW); % exponential
% p.wmW           = repmat(filter_wm/sum(filter_wm),p.ntheta,1);
p.wmW             = repmat(makeGamma(0:p.dt/1000:1.5,[],p.gam1_wmW,p.gam2_wmW,1),p.ntheta,1);

% p.tau_dwm       = 200;                   % memory on the drive

%% Attention
p.aMI     = 6; % 6 % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
p.aMV     = 3.9; %3.9, 9, 200
p.ap      = 4;
p.asigma  = .3;
p.aKernel = [1; -1];
p.aIE     = 0; % excitatory part of involuntary attention kernel
p.aIOR    = .4; %.4 % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
p.biph1   = 40; % 40,35,25
p.biph2   = 2; % 2
p.gam1    = 8;
p.gam2    = .005;
switch p.model
    case 1
        aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
        aW(aW>0)  = aW(aW>0)*p.aIE;
        aW(aW<0)  = aW(aW<0)*p.aIOR;
    case 2
        aW        = repmat(makeGamma(0:p.dt/1000:0.8,[],p.gam1,p.gam2,1),p.ntheta,1)*p.aMI;
    case 4
        aW        = zeros(p.ntheta, length(0:p.dt/1000:0.8));
    otherwise
        error('p.model not recognized')
end
p.aW(:,:,1)      = aW;
p.aW(:,:,2)      = -aW;
p.aBaseline      = 0; % 0.001;

%% Stimulus and task parameters
p.stimOnset = 500;                  % relative to start of trial (ms)
p.stimDur = 30; %30  
p.exoCueSOA = 100;
p.attOnset = -50; %-50                  % voluntary attention on, relative to stim onset (ms)
p.attOffset = 10; %10                 % voluntary attention off, relative to stim offset (ms)
p.vAttWeight1 = 1;
p.vAttWeight2 = 0;
p.vAttWeights = [p.vAttWeight1 p.vAttWeight2]; % [1 0]            % [high low]
p.vAttScale2 = 1;                  % scale the magnitude of voluntary attention to T2
p.neutralAttOp = 'max';             % 'mean','max'; attention weight assigned in the neutral condition

%% Decision
% p.tau_e         = 1000;
p.sigmad            = .1;
p.tau_rd            = 10000;
p.bounds            = [0 0];                   % evidence accumulation bounds for perceptual decision (when measuring accuracy)
p.ceiling           = []; %3, 0.8, 7.8; %[];                     % evidence ceiling (when measuring eveidence)
p.decisionWindowDur = 300; %[]

%% Scaling and offset (for fitting only)
p.scaling1 = 4.2;
p.scaling2 = 3.3;
p.offset1 = 0;
p.offset2 = 0;

%% Set params from opt
if ~isempty(opt)
    fieldNames = fields(opt);
    for iF = 1:numel(fieldNames)
        f = fieldNames{iF};
        p.(f) = opt.(f);
    end
    
    % update params that depend on opt params
    % sensory (S1)
%     filter_e          = (p.tlist/p.tau_e).*exp(1-p.tlist/p.tau_e); % alpha
%     p.filter_e        = filter_e/sum(filter_e);     %temporal filter for excitatory response
    filter_r2         = exp(-p.tlist/p.tau_r2); % exponential
    p.filter_r2       = filter_r2/sum(filter_r2);     %temporal filter for firing rate
    
    % sensory layer 2 (S2)
%     p.s2W           = repmat(makeGamma(0:p.dt/1000:1.5,[],p.gam1_s2W,p.gam2_s2W,1),p.ntheta,1);
    p.s2W             = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1_s2W,round(p.biph2_s2W)),p.ntheta,1);
    
    % WM
%     filter_wm       = exp(-p.tlist/p.tau_wmW); % exponential
%     p.wmW           = repmat(filter_wm/sum(filter_wm),p.ntheta,1);
    p.wmW             = repmat(makeGamma(0:p.dt/1000:1.5,[],p.gam1_wmW,p.gam2_wmW,1),p.ntheta,1);
    
    switch p.model
        case 1
            aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
            aW(aW>0)  = aW(aW>0)*p.aIE;
            aW(aW<0)  = aW(aW<0)*p.aIOR;
        case 2
            aW        = repmat(makeGamma(0:p.dt/1000:0.8,[],p.gam1,p.gam2,1),p.ntheta,1)*p.aMI;
        case 4
            aW        = zeros(p.ntheta, length(0:p.dt/1000:0.8));
        otherwise
            error('p.model not recognized')
    end
    p.aW(:,:,1)      = aW;
    p.aW(:,:,2)      = -aW;
    
    p.vAttWeights    = [p.vAttWeight1 p.vAttWeight2];
end

