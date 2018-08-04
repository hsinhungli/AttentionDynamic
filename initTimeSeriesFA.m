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

% sensory layer 3
% p.d3   = zeros(p.ntheta,p.nt); %Drive
% p.s3   = zeros(p.ntheta,p.nt); %Suppressive Drive
% p.r3   = zeros(p.ntheta,p.nt); %Firing Rate
% p.f3   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
% p.a3   = zeros(p.ntheta,p.nt); %Adaptation term
% p.d3_n = zeros(p.ntheta,p.nt); %Noise

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
p.dav  = zeros(p.ntheta,p.nt); %Drive
p.sav  = zeros(p.ntheta,p.nt); %Suppressive Drive
p.fav  = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.attV = zeros(p.ntheta,p.nt); %Voluntary attentional gain factor, equivalent to r
p.task = zeros(p.ntheta,p.nt); %Task

% attention (single layer)
p.da  = zeros(p.ntheta,p.nt); %Drive
p.sa  = zeros(p.ntheta,p.nt); %Suppressive Drive
p.fa  = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.ra  = zeros(p.ntheta,p.nt);  %Firing rate = attentional gain factor
p.attIInput = zeros(p.ntheta,p.nt); %Precalculated involuntary input

% time constants
if p.timeVaryingTau
    p.tau = [p.tau zeros(1,p.nt-1)]; % Sensory layer 1
%     p.tau_r2 = [p.tau_r2 zeros(1,p.nt-1)]; % Sensory layer 2
end


