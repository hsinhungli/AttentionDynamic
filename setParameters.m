function p = setParameters

%% Temporal Parameters

%Expeirment parameters
p.dt            = 1;          %minimum time-step in Euler method(ms)
p.T             = 20*1000;    %total duration to simulate (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tau             = [10 10 10 10 10];           %time constant (ms)
p.tau_a           = [3000 3000 3000 3000 3000]; %time constant adaptation (ms)
p.tau_inh         = 5;
p.tau_att         = 200;                      %time constant attention (ms)
p.tau_n           = 100;                      %time constant noise (ms)
p.d_noiseamp      = [0.02 0.02 0 0 0]*0;    %noise amplitude of each layer (implemented at excitatory drive; set to zero for noise-free system)
p.tau_a           = [1500 1500 1500 1500 1500]; %time constant adaptation (ms)
p.tau_inh         = 5;
p.tau_att         = 200;                      %time constant attention (ms)
p.tau_n           = 100;                      %time constant noise (ms)
p.d_noiseamp      = [0 0 0 0 0];    %noise amplitude of each layer (implemented at excitatory drive; set to zero for noise-free system)

%% Spatial & Neuronal Parameters
p.x             = 0;                %Sampling of space
p.nx            = numel(p.x);
p.ntheta        = 2;                %Sampling of orientation
p.baselineMod   = [0 0 0 0 0];
p.baselineAtt   = 1;
p.p             = [1 1 1 1 1]*2;    %exponentiation of each layer

p.p             = [1 1 1 1 1]*2;      %exponentiation of each layer
p.sigma         = [.5 .5 .5 .5 .5]; %semisaturation constant of each layer
p.wa            = [1 1 1 1 1];      %weights of self-adaptation
p.w_int         = 1;                %weights of interocular normalization (serve as input normalization here)
p.w_opp         = .4;               %weights of feedback from opponency layer
p.fbtype        = 's';              %Determine how to implement inhibition from opponency layers
p.nLayers       = 5;                %1-2 moncular layers; 3 summation layer; 4-5 opponency layers

%% Attention Layer
p.aM      = .3; %weight of attentional modulation
p.ap      = 2;  %exponentiation
p.asigma  = .2; %semisaturation constant
p.aKernel = [1 -1;-1 1]; %Receltive field of attention neurons

%% Parameters for index computation

end