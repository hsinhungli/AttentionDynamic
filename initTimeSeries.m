function p = initTimeSeries(p)

for lay=1:p.nLayers %go through maximum possible layers. This way, if there are <5 layers, the feedback can be zero.
    p.d{lay}   = zeros(p.ntheta,p.nt); %Drive
    p.s{lay}   = zeros(p.ntheta,p.nt); %Suppressive Drive
    p.r{lay}   = zeros(p.ntheta,p.nt); %Firing Rate
    p.f{lay}   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
    p.a{lay}   = zeros(p.ntheta,p.nt); %Adaptation term
    %p.dr{lay}  = zeros(p.ntheta,p.nt); %Differentiation of firing rate (r)
    if ismember(lay,[1 2])
        p.inh{lay} = zeros(p.ntheta,p.nt);
    end
    p.d_n{lay} = zeros(p.ntheta,p.nt);
end

p.att          = ones(p.ntheta,p.nt);  %Attentional gain factor
p.WTA          = zeros(p.ntheta,p.nt);

