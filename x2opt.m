function [opt, x, lb, ub] = x2opt(x)

if nargin==0
    x = [];
end

%% initial param vals
% sensory
% p.tau           = 90;  %70, 20         %time constant filter for excitatory response (ms)
% p.tauwm         = 20;              %time constant filter for working memory (ms)
% p.tau_r2        = 80;  %100            %time constant filter for firing rate (ms)
p.sigma         = 1.8; % .5, .1         %semisaturation constant
% p.p             = 1.5;

% sensory 2
p.sigma2        = .1; %.1

% working memory
% p.sigmawm       = .01; % 0.1
% p.tau_wmW       = 200;                   % temporal receptive field

% voluntary attention
% p.attOnset      = -50;             % voluntary attention on, relative to stim onset (ms)
% p.attOffset     = 10;              % voluntary attention off, relative to stim offset (ms)
% p.vAttWeight1   = 1;               % high
% p.vAttWeight2   = 0;               % low
% p.tau_attV      = 50;  %50         %time constant voluntary attention (ms)
p.aMV           = 3.9; % 3.5,2.5
p.vAttScale2    = 1;
p.span          = 900;

% involuntary attention
% p.biph1         = 40;
% p.biph2         = 2;
% p.gam1          = 8;
% p.gam2          = .005;
p.aMI           = 150; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
p.aIE            = .2;
p.aIOR          = .2; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
p.asigma        = .3;  %.3
% p.tau_attI      = 50;  %50         %time constant involuntary attention (ms)

% decision
p.sigmad = 1;
% p.ceiling = 0.82; %.85
p.decisionWindowDur = 300;
p.decisionLatency   = -50;

% fitting
p.scaling1 = .5*10^5; %77; % 4.2, 4.5
p.scaling2 = .43*10^5; %60; % 3.3
% p.offset1  = 0;
% p.offset2  = 0;
p.diffOrientOffset = -0.5;

%% initialize x if needed
pFields = fields(p);
if isempty(x)
    idx = 1;
    for iF = 1:numel(pFields)
        f = pFields{iF};
        vals = p.(f);
        for iV = 1:numel(vals)
            x(idx) = vals(iV);
            idx = idx+1;
        end
    end
end

%% assign x values to opt fields
for iF = 1:numel(pFields)
    f = pFields{iF};
    opt.(f) = x(iF);
end

%% set bounds on x
lb = ones(size(x))*-Inf;
ub = ones(size(x))*Inf;

b.tau           = [0 1000]; 
b.tau_r2        = [0 1000]; 
b.attOnset      = [-500 0];
b.attOffset     = [0 500];
b.biph1         = [1 100];
b.biph2         = [1 10];

b.sigma         = [0 10];
b.sigmawm       = [0 10];
b.tau_wmW       = [0 1000];
b.vAttWeight1   = [0 1];
b.vAttWeight2   = [0 1];
b.aMV           = [0 Inf];
b.aMI           = [0 Inf];
b.aIOR          = [0 Inf];
b.asigma        = [0 10];
b.fitScaling    = [0 Inf];

for iF = 1:numel(pFields)
    f = pFields{iF};
    if isfield(b, f)
        lb(iF) = b.(f)(1);
        ub(iF) = b.(f)(2);
    end
end

