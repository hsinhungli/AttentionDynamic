function p = initTimeSeriesFA(p)

% sensory layer 1
p.d   = zeros(p.ntheta,p.nt); %Drive
p.s   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r   = zeros(p.ntheta,p.nt); %Firing Rate
p.f   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a   = zeros(p.ntheta,p.nt); %Adaptation term
p.d_n = zeros(p.ntheta,p.nt); %Noise

% sensory layer 1 transient
p.dtr   = zeros(p.ntheta,p.nt); %Drive
p.str   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.rtr   = zeros(p.ntheta,p.nt); %Firing Rate
p.ftr   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate

% sensory layer 2
p.d2   = zeros(p.ntheta,p.nt); %Drive
p.s2   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r2   = zeros(p.ntheta,p.nt); %Firing Rate
p.f2   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a2   = zeros(p.ntheta,p.nt); %Adaptation term
p.d2_n = zeros(p.ntheta,p.nt); %Noise

% decision
p.dd   = zeros(p.nstim,p.nt); %Drive
p.sd   = zeros(p.nstim,p.nt); %Suppressive Drive
p.rd   = zeros(p.nstim,p.nt); %Firing Rate
p.fd   = zeros(p.nstim,p.nt); %Estimated Asy firing rate
p.ad   = zeros(p.nstim,p.nt); %Adaptation term
p.dd_n = zeros(p.nstim,p.nt); %Noise

% involuntary attention
p.dai  = zeros(p.ntheta,p.nt); %Drive
p.sai  = zeros(p.ntheta,p.nt); %Suppressive Drive
p.fai  = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.attI = zeros(p.ntheta,p.nt); %Involuntary attentional gain factor, equivalent to r
    
% voluntary attention
p.attV = zeros(p.ntheta,p.nt); %Voluntary attentional gain factor, equivalent to r
p.task = zeros(p.ntheta,p.nt); %Task

