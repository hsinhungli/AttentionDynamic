function p = initTimeSeriesFA(p)

% sensory
p.d   = zeros(p.ntheta,p.nt); %Drive
p.s   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r   = zeros(p.ntheta,p.nt); %Firing Rate
p.f   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a   = zeros(p.ntheta,p.nt); %Adaptation term
p.d_n = zeros(p.ntheta,p.nt); %Noise

% sensory layer 2
p.d2   = zeros(p.ntheta,p.nt); %Drive
p.s2   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r2   = zeros(p.ntheta,p.nt); %Firing Rate
p.f2   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a2   = zeros(p.ntheta,p.nt); %Adaptation term
p.d2_n = zeros(p.ntheta,p.nt); %Noise

% working memory 
p.dwm   = zeros(p.ntheta,p.nt,p.nstim); %Drive
p.swm   = zeros(p.ntheta,p.nt,p.nstim); %Suppressive Drive
p.rwm   = zeros(p.ntheta,p.nt,p.nstim); %Firing Rate
p.fwm   = zeros(p.ntheta,p.nt,p.nstim); %Estimated Asy firing rate
p.awm   = zeros(p.ntheta,p.nt,p.nstim); %Adaptation term
p.dwm_n = zeros(p.ntheta,p.nt,p.nstim); %Noise
p.gate  = zeros(p.nstim,p.nt);          %Gate into WM
% define the gate
stimStarts = [p.stimOnset p.stimOnset+p.soa];
for istim = 1:p.nstim
    if istim==p.nstim
        idx = round((stimStarts(istim)/p.dt):p.nt); % last stim - read out to the end
    else
        idx = round((stimStarts(istim)/p.dt):(stimStarts(istim)/p.dt)+p.soa/p.dt);
    end
    p.gate(istim,idx) = 1;
end

% attention
p.att = zeros(p.ntheta,p.nt);   %Attentional gain factor
p.attI = zeros(p.ntheta,p.nt);  %Involuntary attentional gain factor
p.attV = zeros(p.ntheta,p.nt);  %Voluntary attentional gain factor
p.h = zeros(p.ntheta,p.nt);    %Involuntary attentional impulse response

% p.attICascade = ones(p.ntheta,p.nt,p.nAttICascades);
% p.hCascade = zeros(p.ntheta,p.nt,p.nHCascades);

p.task = zeros(p.ntheta,p.nt); %Task

