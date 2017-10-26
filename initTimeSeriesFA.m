function p = initTimeSeriesFA(p)

% sensory layer 1
p.d   = zeros(p.ntheta,p.nt); %Drive
p.s   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r   = zeros(p.ntheta,p.nt); %Firing Rate
p.f   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a   = zeros(p.ntheta,p.nt); %Adaptation term
p.d_n = zeros(p.ntheta,p.nt); %Noise
p.rCascade = zeros(p.ntheta,p.nt,p.nRCascades); %Cascade for gamma-shaped r

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

% attention
p.attI = zeros(p.ntheta,p.nt);  %Involuntary attentional gain factor
p.attV = zeros(p.ntheta,p.nt);  %Voluntary attentional gain factor

p.task = zeros(p.ntheta,p.nt); %Task

