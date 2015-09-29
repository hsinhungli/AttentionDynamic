function p = initTimeSeriesTA(p)

p.d   = zeros(p.ntheta,p.nt); %Drive
p.s   = zeros(p.ntheta,p.nt); %Suppressive Drive
p.r   = zeros(p.ntheta,p.nt); %Firing Rate
p.f   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
p.a   = zeros(p.ntheta,p.nt); %Adaptation term
p.d_n = zeros(p.ntheta,p.nt); %Noise

p.att = ones(p.ntheta,p.nt);   %Attentional gain factor
p.attI = ones(p.ntheta,p.nt);  %Involuntary attentional gain factor
p.attV = ones(p.ntheta,p.nt);  %Voluntary attentional gain factor
p.h = zeros(p.ntheta,p.nt);    %Involuntary attentional impulse response

p.task = zeros(p.ntheta,p.nt); %Task

