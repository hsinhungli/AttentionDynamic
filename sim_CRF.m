p = setParameters;

% Pick contrasts
numContrasts = 15;
cRange       = [1e-3 1];
logCRange    = log10(cRange);
logContrasts = linspace(logCRange(1),logCRange(2),numContrasts);
contrasts    = 10.^logContrasts;
C = contrasts;

E = halfExp(C,p.p(1));
I = halfExp(C,p.p(1));
Ib = halfExp(C,p.p(1));
sigma = halfExp(p.sigma(1), p.p(1));

R = E ./ (I + Ib + sigma);
figure;
semilogx(contrasts, R, '-o'); hold on;

%%
C = 0:.1:2;
theta = 0;
k = .1;

r = 1 ./(1+exp(-(C-theta)/k));
plot(C,r)