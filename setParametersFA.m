function p = setParametersFA(opt)

% function p = setParametersFA(opt)
%
% opt is a structure containing values of p fields. will overwrite existing values. 

%% Deal with input
if ~exist('opt','var')
    opt = [];
end

%% Model
p.modelClass      = 'transient-span'; % 'span','transient-span'
p.rf            = 'rf/resp_stim4_rf6.mat'; % sensory RFs - encode stim and decode responses using saved RFs. [] for none.

%% Temporal Parameters
%Expeirment parameters
p.dt            = 2;                        %time-step (ms)
p.T             = 2.1*1000;                  %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tau             = 40;%40;  %2,90,20                   %time constant (ms)
p.tautr           = 5;
p.tau_a           = 99;                     %time constant adaptation (ms)
p.tau_attI        = 50;  %50                %time constant involuntary attention (ms)
p.tau_attV        = 50;  %50               %time constant voluntary attention (ms)
switch p.modelClass
    case 'transient-span'
        p.tau_r2  = 2;  %80,120                   %time constant filter for firing rate (ms)
    case 'span'
        p.tau_r2  = 70;  %120,80                   %time constant filter for firing rate (ms)
    otherwise
        error('modelClass not found')
end
p.tau_n           = 99; %100                   %time constant noise (ms)
p.d_noiseamp      = 0; % 0.0015;
p.delay           = 50;                     % delay before the start of the sustained sensory response

%% Feature space parameters
p.x             = 0;                %Sampling of space
p.nx            = numel(p.x);
p.ntheta        = 6;                % should match RF

%% Sensory layer 1
p.p             = 2;
p.sigma         = 1.8; %.5 .1      %semisaturation constant
p.wa            = 0;               %weights of self-adaptation

%% Sensory layer 2
p.sigma2        = .1; %.1

%% Attention
switch p.modelClass
    case 'transient-span'
        p.aMI     = 150; % 6 % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aMV     = 3.9; %3.9, 9, 200
        p.aIE     = .2; % excitatory part of involuntary attention kernel
        p.aIOR    = .2; %.4 % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.biph1   = 20; % 40,35,25
        p.biph2   = 2; % 2
    case 'span'
        p.aMI     = 3.9; % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aMV     = 1.6; %9, 200
        p.aIE     = 0; % excitatory part of involuntary attention kernel
        p.aIOR    = .32; %.4 % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.biph1   = 40; % 35,25
        p.biph2   = 2;
end
p.ap = 4;
p.asigma  = .3;
p.aKernel = [1; -1];

aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
aW(aW>0)  = aW(aW>0)*p.aIE;
aW(aW<0)  = aW(aW<0)*p.aIOR;
p.aW(:,:,1)      = aW;
p.aW(:,:,2)      = -aW;

%% Stimulus and task parameters
p.stimOnset = 500;                  % relative to start of trial (ms)
p.stimDur = 30; %30  
p.exoCueSOA = 100;
switch p.modelClass
    case 'transient-span'
        p.attOnset = -50 + p.delay; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 10 + p.delay; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = 1;                  % scale the magnitude of voluntary attention to T2
        p.span = 680;
    case 'span'
        p.attOnset = -50; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 100; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = .86;                  % scale the magnitude of voluntary attention to T2
        p.span = 500;
end
p.vAttWeight1 = 1; %1
p.vAttWeight2 = 0; %0
p.vAttWeights = [p.vAttWeight1 p.vAttWeight2]; % [1 0]            % [high low]
p.distributeVoluntary = 1;
p.neutralT1Weight = .5;             % bias to treat neutral like attend to T1. 0.5 is no bias
p.neutralAttOp = 'max';             % 'mean','max'; attention weight assigned in the neutral condition

%% Decision
p.sigmad            = 1;
p.tau_rd            = 100000;
% p.bounds            = [0 0];                   % evidence accumulation bounds for perceptual decision (when measuring accuracy)
p.ceiling           = [];%3.6e-5;%3.54e-4; %3, 0.8, 7.8; %[];                     % evidence ceiling (when measuring eveidence)
p.decisionWindowDur = 300; %[]
p.decisionLatency   = -50;

%% Scaling and offset (for fitting only)
p.scaling1 = 4.6;
p.scaling2 = 3.6;
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
    aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
    aW(aW>0)  = aW(aW>0)*p.aIE;
    aW(aW<0)  = aW(aW<0)*p.aIOR;
    p.aW(:,:,1)      = aW;
    p.aW(:,:,2)      = -aW;
    
    p.vAttWeights    = [p.vAttWeight1 p.vAttWeight2];
end

