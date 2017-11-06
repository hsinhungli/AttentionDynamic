function [opt, x, lb, ub] = x2opt(x)

if nargin==0
    x = [];
end

modelClass = '1-attLat';

%% initial param vals
% sensory
switch modelClass
    case 'transient-span'
        % p.tau           = 90;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 2;  %80, 100            %time constant filter for firing rate (ms)
%         p.sigma         = 1.8; % .5, .1         %semisaturation constant
    case 'span'
        p.tau           = 63;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 56;  %100            %time constant filter for firing rate (ms)
        p.sigma         = 2.1; % .5, .1         %semisaturation constant
    case '1-att'
        p.tau           = 63;
        p.tau_r2        = 56;
        p.sigma         = 1.6;
    case '1-attK'
        p.tau           = 63;
        p.tau_r2        = 100;
        p.sigma         = 2.1;
    case '1-attLat'
        p.tau           = 100;
        p.tau_r2        = 150;
        p.sigma         = 2.1;
    otherwise
        error('modelClass not found')
end
% p.p             = 1.5;

% sensory 2
switch modelClass
    case '1-attLat'
        p.sigma2        = .04; 
    otherwise
        p.sigma2        = .08; %.1
end


% voluntary attention
% p.attOnset      = -73;             % voluntary attention on, relative to stim onset (ms)
% p.attOffset     = 59;              % voluntary attention off, relative to stim offset (ms)
% p.vAttWeight1   = 1;               % high
% p.vAttWeight2   = 0;               % low
% p.tau_attV      = 50;  %50         %time constant voluntary attention (ms)
switch modelClass
    case 'transient-span'
%         p.aMV           = 5.6; % 3.5,2.5
%         p.vAttScale2    = .77;
%         p.span          = 875;
    case 'span'
        p.aMV           = 36; % 3.5,2.5
        p.vAttScale2    = .21;
        p.span          = 1083;
    case '1-att'
        p.tau_ra  = 50;
        p.aM      = 1;
%         p.exoSOA  = 120;
        p.exoDur  = 50;
        p.exoProp = 1;
    case '1-attK'
        p.tau_ra  = 50;
        p.aMI     = 25;
        p.aMV     = 1;
        p.aIE     = .4;
        p.aIOR    = .4;
    case '1-attLat'
%         p.tau_ra  = 50;
        p.aM      = 100;
        p.vAttScale2    = 1;
        p.span          = 1000;
end
p.neutralT1Weight = .35;

% involuntary attention
% p.biph1         = 48;
% p.biph2         = 3.3;
switch modelClass
    case 'transient-span'
%         p.aMI           = 150; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
%         p.aIE            = .2;
%         p.aIOR          = .2; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
%         p.asigma        = .2;  %.3
    case 'span'
        p.aMI           = 2.5; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aIE           = 0;
        p.aIOR          = .36; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.asigma        = .22;  %.3
    case {'1-att','1-attK','1-attLat'}
%         p.ap            = 4;
        p.asigma        = 1;
end
% p.tau_attI      = 50;  %50         %time constant involuntary attention (ms)

% decision
% p.sigmad = 1;
% p.ceiling = 0.82; %.85
switch modelClass
    case '1-attLat'
        p.decisionWindowDur         = 800;
        p.decisionRefractoryPeriod  = -400;
        p.singleWindowSOA           = 300; 
    otherwise
% p.decisionWindowDur = 284;
% p.decisionLatency   = -62;
end

% fitting
switch modelClass
    case 'transient-span'
        p.scaling1 = 7; %5*10^5; %77; % 4.2, 4.5
        p.scaling2 = 5; %4*10^5; %60; % 3.3
    case 'span'
        p.scaling1 = .31; % 4.5
        p.scaling2 = .31; % 3.6
    case '1-att'
        p.scaling1 = .5; % 4.5
        p.scaling2 = .5; % 3.6
    case '1-attK'
        p.scaling1 = 2.2; 
        p.scaling2 = 2; 
    case '1-attLat'
        p.scaling1 = .6; 
        p.scaling2 = .5;
end
% p.offset1  = 0;
% p.offset2  = 0;
% p.diffOrientOffset = -0.46;

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

b.p             = [0 10];
b.sigma         = [0 10];
b.vAttWeight1   = [0 1];
b.vAttWeight2   = [0 1];
b.aMV           = [0 Inf];
b.aMI           = [0 Inf];
b.aIOR          = [0 Inf];
b.ap            = [0 10];
b.asigma        = [0 10];
b.fitScaling    = [0 Inf];

b.tau_ra        = [0 1000];
b.aM            = [0 Inf];
b.exoDur        = [0 300];
b.exoProp       = [0 1];


for iF = 1:numel(pFields)
    f = pFields{iF};
    if isfield(b, f)
        lb(iF) = b.(f)(1);
        ub(iF) = b.(f)(2);
    end
end

