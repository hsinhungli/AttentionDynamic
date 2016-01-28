function [opt, x, lb, ub] = x2opt(x)

if nargin==0
    x = [];
end

%% initial param vals
% sensory
p.tau_e         = 20;  %20         %time constant filter for excitatory response (ms)
p.tau_r2        = 80;              %time constant filter for firing rate (ms)
p.sigma         = .5; % .1         %semisaturation constant

% voluntary attention
p.attOnset      = -50;             % voluntary attention on, relative to stim onset (ms)
p.attOffset     = 10;              % voluntary attention off, relative to stim offset (ms)
p.vAttWeights   = [1 0]; % [1 0]   % [high low]
p.tau_attV      = 50;  %50         %time constant voluntary attention (ms)
p.aMV           = 9;

% involuntary attention
p.biph1         = 25;
p.biph2         = 3;
p.aMI           = 5; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
p.aIOR          = 1; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
p.asigma        = .3;
p.tau_attI      = 50;  %50         %time constant involuntary attention (ms)

% fitting
p.fitScaling    = 0.1;

%% initialize x if needed
if isempty(x)
    pFields = fields(p);
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
% sensory
opt.tau_e       = x(1);
opt.tau_r2      = x(2);
opt.sigma       = x(3);

% voluntary attention
opt.attOnset    = x(4);
opt.attOffset   = x(5);
opt.vAttWeights = x(6:7); 
opt.tau_attV    = x(8);
opt.aMV         = x(9);

% involuntary attention
opt.biph1       = x(10);
opt.biph2       = x(11); 
opt.aMI         = x(12); 
opt.aIOR        = x(13); 
opt.asigma      = x(14);
opt.tau_attI    = x(15); 

% fitting
opt.fitScaling  = x(16);

%% set bounds on x
lb = ones(size(x))*-Inf;
ub = ones(size(x))*Inf;

b.attOnset = [-500 0];
b.attOffset = [0 500];

% this is by hand
lb(4) = b.attOnset(1);
ub(4) = b.attOnset(2);

lb(5) = b.attOffset(1);
ub(5) = b.attOffset(2);
    

