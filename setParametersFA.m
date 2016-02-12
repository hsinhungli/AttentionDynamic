function p = setParametersFA(opt)

% function p = setParametersFA(opt)
%
% opt is a structure containing values of p fields. will overwrite existing values. 

%% Deal with input
if ~exist('opt','var')
    opt = [];
end

%% Model
p.model         = 1; % 1 (IOR) or 2 (WM)
p.rf            = []; %'rf/resp_stim2_rf6.mat'; % sensory RFs - encode stim and decode responses using saved RFs. [] for none.

%% Temporal Parameters
%Expeirment parameters
p.dt            = 2;                        %time-step (ms)
p.T             = 2.1*1000;                  %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tauwm           = 10;                    % time constant of working memory (ms)
p.tau_a           = 99;                     %time constant adaptation (ms)
p.tau_attI        = 50;  %50                %time constant involuntary attention (ms)
p.tau_attV        = 50;  %50               %time constant voluntary attention (ms)
p.tau_e           = 20;  %20             %time constant filter for excitatory response (ms)
p.tau_r2          = 80;                     %time constant filter for firing rate (ms)
p.tau_n           = 99; %100                   %time constant noise (ms)
p.d_noiseamp      = 0; % 0.0015;
filter_e          = (p.tlist/p.tau_e).*exp(1-p.tlist/p.tau_e); % alpha
p.filter_e        = filter_e/sum(filter_e);     %temporal filter for excitatory response
filter_r2         = exp(-p.tlist/p.tau_r2); % exponential
p.filter_r2       = filter_r2/sum(filter_r2);     %temporal filter for firing rate

p.tau             = 10;                     %time constant (ms)
p.tau_att         = 99;                    %time constant attention (ms)
p.tau_h           = 99;  %50               %time constant inhibitory component of involuntary attention (ms)
p.nAttICascades   = 2;                      % involuntary attention, number of cascades to turn exponential into gamma
p.nHCascades      = 4;                      % h, number of cascades to turn exponential into gamma

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
p.sigma         = .5; % .1              %semisaturation constant
p.wa            = 0;               %weights of self-adaptation

p.baselineAtt   = 1;
p.wh            = 3; %1.5;               %weight of inhibitory involuntary attention

%% Working memory
p.sigmawm       = .1;
p.tau_dwm       = 200;                   % memory on the drive
p.tau_wmW       = 80;                   % temporal receptive field
filter_wm       = exp(-p.tlist/p.tau_wmW); % exponential
p.wmW           = repmat(filter_wm/sum(filter_wm),p.ntheta,1);

%% Attention
p.aMI     = .1; % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
p.aMV     = 36; %9
p.ap      = 4;
p.asigma  = .3;
p.aKernel = [1; -1];
p.aIOR    = 1.12; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
p.biph1   = 25;
p.biph2   = 3;
p.gam1    = 8;
p.gam2    = .005;
switch p.model
    case 1
        aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,p.biph2),p.ntheta,1)*p.aMI;
        aW(aW<0)  = aW(aW<0)*p.aIOR;
    case 2
        aW        = repmat(makeGamma(0:p.dt/1000:0.8,[],p.gam1,p.gam2,1),p.ntheta,1)*p.aMI;
    otherwise
        error('p.model not recognized')
end

% g1 = makeGamma(0:800,[],12,10,1);
% g2 = makeGamma(0:800,[],12,25,1);
% aW = repmat(g1-g2*0.4,2,1);
p.aW(:,:,1)      = aW;
p.aW(:,:,2)      = -aW;
p.aBaseline      = 0.001;

%% Stimulus and task parameters
p.stimOnset = 500;                  % relative to start of trial (ms)
p.stimDur = 30;   
p.attOnset = -50;                  % voluntary attention on, relative to stim onset (ms)
p.attOffset = 10;                  % voluntary attention off, relative to stim offset (ms)
p.vAttWeights = [1 0]; % [1 0]            % [high low]
p.neutralAttOp = 'max';             % 'mean','max'; attention weight assigned in the neutral condition
p.bounds = [0 0];                   % evidence accumulation bounds for perceptual decision (when measuring accuracy)
p.ceiling = []; %7.8; %[];                     % evidence ceiling (when measuring eveidence)
p.exoCueSOA = 100;

%% Set params from opt
if ~isempty(opt)
    fieldNames = fields(opt);
    for iF = 1:numel(fieldNames)
        f = fieldNames{iF};
        p.(f) = opt.(f);
    end
    
    % update params that depend on opt params
    filter_e          = (p.tlist/p.tau_e).*exp(1-p.tlist/p.tau_e); % alpha
    p.filter_e        = filter_e/sum(filter_e);     %temporal filter for excitatory response
    filter_r2         = exp(-p.tlist/p.tau_r2); % exponential
    p.filter_r2       = filter_r2/sum(filter_r2);     %temporal filter for firing rate
    
    aW               = repmat(makeBiphasic(0:p.dt/1000:0.8,round(p.biph1),round(p.biph2)),2,1)*p.aMI;
    aW(aW<0)         = aW(aW<0)*p.aIOR;
    p.aW(:,:,1)      = aW;
    p.aW(:,:,2)      = -aW;
end

