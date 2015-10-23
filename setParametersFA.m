function p = setParametersFA

%% Temporal Parameters
%Expeirment parameters
p.dt            = 2;                        %time-step (ms)
p.T             = 2.1*1000;                  %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tau             = 10;                     %time constant (ms)
p.tau_a           = 99;                     %time constant adaptation (ms)
p.tau_att         = 200;                    %time constant attention (ms)
p.tau_attI        = 50; % 50                %time constant involuntary attention (ms)
p.tau_attV        = 50; % 100               %time constant voluntary attention (ms)
p.tau_h           = 50;  %200               %time constant inhibitory component of involuntary attention (ms)
p.tau_e           = 20; %20 %80             %time constant filter for excitatory response (ms)
p.tau_r2          = 80;                     %time constant filter for firing rate (ms)
p.tau_n           = 100;                    %time constant noise (ms)
p.d_noiseamp      = 0; % 0.0015;
filter_e          = (p.tlist/p.tau_e).*exp(1-p.tlist/p.tau_e); % alpha
p.filter_e        = filter_e/sum(filter_e);     %temporal filter for excitatory response
filter_r2         = exp(-p.tlist/p.tau_r2); % exponential
p.filter_r2       = filter_r2/sum(filter_r2);     %temporal filter for firing rate
p.nAttICascades   = 2;                      % involuntary attention, number of cascades to turn exponential into gamma
p.nHCascades      = 4;                      % h, number of cascades to turn exponential into gamma

%% Spatial & Neuronal Parameters
p.x             = 0;                %Sampling of space
p.nx            = numel(p.x);
p.ntheta        = 2;                %Sampling of orientation
p.baselineMod   = 0;
p.baselineAtt   = 1;
p.p             = 2;
p.sigma         = .5; % .1              %semisaturation constant
p.wa            = 0;               %weights of self-adaptation
p.wh            = 3; %1.5;               %weight of inhibitory involuntary attention

%% Attention
p.aMI     = 4; % 5 (spatial sim), 4 (stronger IOR)
p.aMV     = 9;
p.ap      = 4;
p.asigma  = .3;
p.aKernel = [1; -1];
p.aIOR    = 1; % 1 (spatial sim), 1.3 (stronger IOR)
aW               = repmat(makeBiphasic(0:p.dt/1000:0.8,25,3),2,1)*p.aMI;
aW(aW<0)         = aW(aW<0)*p.aIOR;
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
p.vAttWeights = [1 0];            % [high low]
p.neutralAttOp = 'max';             % 'mean','max'; attention weight assigned in the neutral condition
p.bounds = [0 0];                   % evidence accumulation bounds for perceptual decision (when measuring accuracy)
p.ceiling = 8.8; %[];                     % evidence ceiling (when measuring eveidence)
