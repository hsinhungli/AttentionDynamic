function [opt, x, lb, ub, ranges] = x2opt(x, modelClass)

if nargin<1
    x = [];
end
if nargin<2
    modelClass = [];
end

if isempty(modelClass)
    % 'span','transient-span','1-attLat','1-attK','t2DecRef'
    modelClass = 't2DecRef';
end

%% initial param vals
% sensory
switch modelClass
    case 'transient-span'
        p.tau           = 90;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 2;  %80, 100            %time constant filter for firing rate (ms)
        p.sigma         = 1.86; % .5, .1         %semisaturation constant
    case 'span'
        p.tau           = 74;%63;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 70;%56;  %100            %time constant filter for firing rate (ms)
        p.sigma         = 1.7;%2.1; % .5, .1         %semisaturation constant
    case '1-att'
        p.tau           = 63;
        p.tau_r2        = 56;
        p.sigma         = 1.6;
    case '1-attK'
        p.tau           = 90;
        p.tau_r2        = 63;
        p.sigma         = 1.4;
    case '1-attLat'
        p.tau           = 78;
        p.tau_r2        = 164;
        p.sigma         = 1.9;
    case 't2DecRef'
        p.tau           = 20;
        p.tau_r2        = 300;
        p.sigma         = 1.7;
    case '3S'
        p.tau           = 74;
        p.tau_r2        = 300;
        p.sigma         = 1.7;       
    otherwise
        error('modelClass not found')
end
% p.p             = 1.5;

% sensory 2
switch modelClass
    case '1-attLat'
        p.sigma2        = .035;
    case '1-attK'
        p.sigma2        = .1;
    case 't2DecRef'
        p.sigma2        = .5;
    otherwise
        p.sigma2        = .08; %.1
end

% sensory 3
switch modelClass
    case '3S'
        p.sigma3        = .1;
end

% voluntary attention
% p.attOnset      = -50;             % voluntary attention on, relative to stim onset (ms)
% p.attOffsett     = 10;              % voluntary attention off, relative to stim offset (ms)
% p.vAttWeight1   = 1;               % high
% p.vAttWeight2   = 0;               % low
% p.tau_attV      = 50;  %50         %time constant voluntary attention (ms)
switch modelClass
    case 'transient-span'
        p.aMV           = 5.8; % 3.5,2.5
        p.vAttScale2    = .78;
        p.span          = 827;
    case 'span'
        p.tau_attV      = 50;
        p.aMV           = 20; % 3.5,2.5
%         p.vAttScale2    = .21;
        p.span          = 650;
        p.attOnset      = -70;
        p.attOffsett    = 60;
    case '1-att'
        p.tau_ra        = 50;
        p.aM            = 1;
%         p.exoSOA  = 120;
        p.exoDur        = 50;
        p.exoProp       = 1;
    case '1-attK'
        p.tau_ra        = 24;
        p.aM            = 30;
        p.aIOR          = .02;
        p.span          = 1030;
        p.attOnset      = -50;
        p.attOffsett    = 16;
    case '1-attLat'
%         p.tau_ra  = 50;
        p.aM      = 100;
        p.vAttScale2    = .65;
        p.span          = 1200;
    case 't2DecRef'
        p.tau_attV      = 50;
        p.aMV           = 20; 
%         p.vAttScale2    = .21;
        p.span          = 650;
        p.attOnset      = -70;
        p.attOffsett    = 60;       
    case '3S'
        p.tau_attV      = 50;
        p.aMV           = 20; 
%         p.vAttScale2    = .21;
        p.span          = 650;
        p.attOnset      = -70;
        p.attOffsett    = 60; 
end
% p.neutralT1Weight = .15;

% involuntary attention
% p.biph1         = 48;
% p.biph2         = 3.3;
switch modelClass
    case 'transient-span'
        p.aMI           = 150; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
        p.aIE            = .2;
        p.aIOR          = .15; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.asigma        = .21;  %.3
    case 'span'
        p.aMI           = 100;%2.5; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
%         p.aIE           = 0;
        p.aIOR          = 2;%.36; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.asigma        = 30;%.22;  %.3
    case {'1-att','1-attLat'}
%         p.ap            = 4;
        p.asigma        = 1.2;
    case '1-attK'
        p.asigma        = 27;
    case 't2DecRef'
        p.aMI           = 100000;
        p.tau_attI      = 2;
        p.asigma        = 30;
    case '3S'
        p.aMI           = 250;
        p.tau_attI      = 2;
        p.asigma        = 30;
end
% p.tau_attI      = 50;  %50         %time constant involuntary attention (ms)

% decision
% p.sigmad = 1;
% p.ceiling = 0.82; %.85
switch modelClass
    case 'transient-span'
        p.decisionWindowDur = 384; %300
        p.decisionLatency   = -37; %-50
    case '1-attLat'
        p.decisionWindowDur = 800;
        p.decisionRefractoryPeriod = -400;
        p.singleWindowSOA   = 300; % use a single decision window for this SOA or below
    case 't2DecRef'
        p.decisionRefractoryPeriod = 450;
end


% fitting
switch modelClass
    case 'transient-span'
        p.scaling1 = 2.4; %5*10^5; %77; % 4.2, 4.5
        p.scaling2 = 1.9; %4*10^5; %60; % 3.3
    case 'span'
        p.scaling1 = 1.9;%.31; % 4.5
        p.scaling2 = 1.6;%.31; % 3.6
    case '1-att'
        p.scaling1 = .5; % 4.5
        p.scaling2 = .5; % 3.6
    case '1-attK'
        p.scaling1 = 1.8; 
        p.scaling2 = 1.5; 
    case '1-attLat'
        p.scaling1 = 1.2; 
        p.scaling2 = 1;
    case 't2DecRef'
        p.scaling1 = 19;
        p.scaling2 = 16;
    case '3S'
        p.scaling1 = 19;
        p.scaling2 = 16;
end
% p.offset1  = 0;
% p.offset2  = 0;
% p.diffOrientOffset = -0.45;

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

%% set ranges for x samples
r.tau           = [1 300]; 
r.tau_r2        = [1 300]; 
r.sigma         = [.05 5];
r.sigma2        = [.05 5];
r.p             = [1 4];

r.aMV           = [0 50];
r.aMI           = [10 1000];
r.aIE           = [.02 2];
r.aIOR          = [.02 2];
r.asigma        = [.02 2];

r.vAttScale2    = [.3 3];
r.span          = [200 2000];
r.neutralT1Weight = [0 1];

r.sigmad        = [.05 5];

r.decisionWindowDur = [100 1000];
r.decisionLatency = [-100 100];

r.scaling1      = [.1 10];
r.scaling2      = [.1 10];

for iF = 1:numel(pFields)
    f = pFields{iF};
    if isfield(r, f)
        ranges(iF,1) = r.(f)(1);
        ranges(iF,2) = r.(f)(2);
    end
end

