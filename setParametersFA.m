function p = setParametersFA(opt)

% function p = setParametersFA(opt)
%
% opt is a structure containing values of p fields. will overwrite existing values. 

%% Deal with input
if ~exist('opt','var')
    opt = [];
end

%% Model
p.modelClass      = 'transient-span'; % 'span','transient-span','1-att','1-attK','1-attLat'
p.rf              = 'rf/resp_stim4_rf12.mat'; % sensory RFs - encode stim and decode responses using saved RFs. [] for none.
p.rfDecoding      = 'rf/resp_stim4_rf12.mat'; %'rf/resp_stim4_rf6_empirical_r2.mat';

%% Time
p.dt              = 2;               %time-step (ms)
p.T               = 2.1*1000;        %duration (ms)
p.nt              = p.T/p.dt+1;
p.tlist           = 0:p.dt:p.T;

%% Space and feature space
p.x               = 0;               %Sampling of space
p.nx              = numel(p.x);
p.ntheta          = 12;               % should match RF

%% Sensory layer 1
p.tautr           = 5;
p.tau             = 100;%63  %74;%40           %time constant (ms)
p.sigma           = 1.2; %2.1; %1.8; %.5 .1      %semisaturation constant
p.p               = 1.5; %1.6;%1.2;               % exponent
switch p.modelClass
    case {'transient-span','1-attLat'}
        p.delay   = 50;              % delay before the start of the sustained sensory response
    otherwise
        p.delay   = 0;
end

% noise and adaptation are turned off
p.tau_a           = 99;              %time constant adaptation (ms)
p.tau_n           = 99; %100         %time constant noise (ms)
p.d_noiseamp      = 0; % 0.0015;
p.wa              = 0;               %weights of self-adaptation

%% Sensory layer 2
p.sigma2          = .08; %.08; %.04; %.1
switch p.modelClass
    case {'transient-span'}
        p.tau_r2  = 2; %2;  %80,120      %time constant filter for firing rate (ms)
    otherwise
        p.tau_r2  = 150;  %100 %70 %120,80     %time constant filter for firing rate (ms)
end

%% Sensory layer 3
% p.p3              = 1.5;
% p.sigma3          = 1.2;
% p.tau_r3          = 100;

%% Attention
p.tau_attI        = 50;  %50         %time constant involuntary attention (ms)
p.tau_attV        = 50;  %50         %time constant voluntary attention (ms)
switch p.modelClass
    case 'transient-span'
        p.aMI     = 265; %150; % 6 % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aMV     = 18.7; %3.9, 9, 200
        p.aIE     = .1; %.2; % excitatory part of involuntary attention kernel
        p.aIOR    = .13; %.2; %.4 % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.biph1   = 20; % 40,35,25
        p.biph2   = 2; % 2
    case 'span'
        p.aMI     = 2.5; % .2 % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aMV     = 35; %43; %1.6; %9, 200
        p.aIE     = 0; %0 % excitatory part of involuntary attention kernel
        p.aIOR    = .37; %.32 %.4 % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.biph1   = 48;%53; %40 % 35,25
        p.biph2   = 3.2;%4;
    case '1-att'
        p.tau_ra  = 50;
        p.aM      = 1;
        p.exoSOA  = 120;
        p.exoDur  = 50;
        p.exoProp = 1;
    case '1-attK'
        p.tau_ra  = 50;
        p.aMI     = 25; 
        p.aMV     = 1; 
        p.aIE     = .4; 
        p.aIOR    = .4; 
        p.biph1   = 48;
        p.biph2   = 3.2;
    case '1-attLat'
        p.tau_ra  = 50;
        p.aM      = 10; % 100
    otherwise
        error('p.modelClass not recognized')
end
p.ap = 4;
p.asigma  = .3; %5;%1;%.3;
p.aKernel = [1; -1];

switch p.modelClass
    case {'1-att','1-attLat'}
        % no aW
    otherwise
        aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
        aW(aW>0)  = aW(aW>0)*p.aIE;
        aW(aW<0)  = aW(aW<0)*p.aIOR;
        p.aW(:,:,1)      = aW;
        p.aW(:,:,2)      = -aW;
end

%% Stimulus and task parameters
p.stimOnset = 500;                  % relative to start of trial (ms)
p.stimDur = 30; %30  
p.exoCueSOA = 100;
switch p.modelClass
    case 'transient-span'
        p.attOnset = -50 + p.delay; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 10 + p.delay; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = 1.3;                  % scale the magnitude of voluntary attention to T2
        p.span = 1522; %680;
        p.distributeVoluntary = 1;
    case '1-attK'
        p.attOnset = -73; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 59; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = .86;                  % scale the magnitude of voluntary attention to T2
        p.span = 850;
        p.distributeVoluntary = 1;
    case '1-attLat'
        p.attOnset = 0; %-100 + p.delay; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 100; %100 + p.delay; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = 1;                  % scale the magnitude of voluntary attention to T2
        p.span = 800; % 1000
        p.distributeVoluntary = 1;    
    otherwise
        p.attOnset = -73; %-50                  % voluntary attention on, relative to stim onset (ms)
        p.attOffset = 59; %10                 % voluntary attention off, relative to stim offset (ms)
        p.vAttScale2 = .86;                  % scale the magnitude of voluntary attention to T2
        p.span = 850;
        p.distributeVoluntary = 1;
end
p.vAttWeight1 = 1; %1
p.vAttWeight2 = 0; %0
p.vAttWeights = [p.vAttWeight1 p.vAttWeight2]; % [1 0]            % [high low]
p.neutralT1Weight = 0.5; %.5;             % bias to treat neutral like attend to T1. 0.5 is no bias
p.neutralAttOp = 'max';             % 'mean','max'; attention weight assigned in the neutral condition

%% Decision
p.sigmad            = .7; %.1;
p.tau_rd            = 100000;
% p.bounds            = [0 0];                   % evidence accumulation bounds for perceptual decision (when measuring accuracy)
p.ceiling           = [];%3.6e-5;%3.54e-4; %3, 0.8, 7.8; %[];                     % evidence ceiling (when measuring eveidence)
switch p.modelClass
    case 'transient-span'
        p.decisionWindowDur = 384; %300
        p.decisionLatency   = -37; %-50
    case '1-attLat'
        p.decisionWindowDur = 800;
        p.decisionRefractoryPeriod = -400;
        p.singleWindowSOA   = 300; % use a single decision window for this SOA or below
        p.decisionLatency   = []; % set this outside, depends on cond and soa
    otherwise
        p.decisionWindowDur = [];
        p.decisionLatency   = 0;
end

%% Scaling and offset (for fitting only)
p.scaling1 = 1.1; %.31;%4.2;
p.scaling2 = .8; %.31;%3.6;
p.offset1 = 0;
p.offset2 = 0;
p.diffOrientOffset = -0.45; % when the tilts are different, you get worse

%% Set params from opt
if ~isempty(opt)
    fieldNames = fields(opt);
    for iF = 1:numel(fieldNames)
        f = fieldNames{iF};
        p.(f) = opt.(f);
    end
    
    % update params that depend on opt params
    switch p.modelClass
        case {'1-att','1-attLat'}
            % no aW
        otherwise
            aW        = repmat(makeBiphasic(0:p.dt/1000:0.8,p.biph1,round(p.biph2)),p.ntheta,1);
            aW(aW>0)  = aW(aW>0)*p.aIE;
            aW(aW<0)  = aW(aW<0)*p.aIOR;
            p.aW(:,:,1)      = aW;
            p.aW(:,:,2)      = -aW;
    end
    
    p.vAttWeights    = [p.vAttWeight1 p.vAttWeight2];
end

