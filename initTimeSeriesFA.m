function p = initTimeSeriesFA(p)

% sensory
p.d   = zeros(p.ntheta,p.nt); %Drive
p.s   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r   = zeros(p.ntheta,p.nt); %Firing Rate
p.f   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a   = zeros(p.ntheta,p.nt); %Adaptation term
p.d_n = zeros(p.ntheta,p.nt); %Noise

% working memory (each row is a stimulus)
p.dwm   = zeros(2,p.nt); %Drive
p.swm   = zeros(2,p.nt); %Suppressive Drive
p.rwm   = zeros(2,p.nt); %Firing Rate
p.fwm   = zeros(2,p.nt); %Estimated Asy firing rate
p.awm   = zeros(2,p.nt); %Adaptation term
p.dwm_n = zeros(2,p.nt); %Noise

% attention
p.att = zeros(p.ntheta,p.nt);   %Attentional gain factor
p.attI = zeros(p.ntheta,p.nt);  %Involuntary attentional gain factor
p.attV = zeros(p.ntheta,p.nt);  %Voluntary attentional gain factor
p.h = zeros(p.ntheta,p.nt);    %Involuntary attentional impulse response

p.attICascade = ones(p.ntheta,p.nt,p.nAttICascades);
p.hCascade = zeros(p.ntheta,p.nt,p.nHCascades);

p.task = zeros(p.ntheta,p.nt); %Task

