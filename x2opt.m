function [opt, x, lb, ub, ranges] = x2opt(x, modelClass)

if nargin<1
    x = [];
end
if nargin<2
    modelClass = '';
end

%% process modelClass
modelParts = strsplit(modelClass,'_');
modelClass = modelParts{1};

if isempty(modelClass)
    % 'span','transient-span','1-attLat','1-attK','t2DecRef','3S','valo'
    modelClass = 'valo';
end

%% initial param vals
% sensory
switch modelClass
    case 'transient-span'
        p.tau           = 90;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 2;  %80, 100            %time constant filter for firing rate (ms)
        p.sigma         = 1.86; % .5, .1         %semisaturation constant
    case 'span'
        p.tau           = 75;%63;  %70, 20         %time constant filter for excitatory response (ms)
        p.tau_r2        = 68;%56;  %100            %time constant filter for firing rate (ms)
        p.sigma         = 1.8;%2.1; % .5, .1         %semisaturation constant
    case '1-att'
        p.tau           = 63;
        p.tau_r2        = 56;
        p.sigma         = 1.6;
    case '1-attK'
        p.tau           = 88;
        p.tau_r2        = 62;
        p.sigma         = 1.6;
    case '1-attLat'
        p.tau           = 78;
        p.tau_r2        = 164;
        p.sigma         = 1.9;
    case 't2DecRef'
        p.tau           = 16;
        p.tau_r2        = 241;
        p.sigma         = 1.3;
    case '3S'
        p.tau           = 80;
        p.tau_r2        = 63;
        p.sigma         = 2.2;      
    case 'valo'
        p.tau           = 75;
        p.tau_r2        = 68;
        p.sigma         = 1.8;
    otherwise
        error('modelClass not found')
end
% p.p             = 1.5;

% sensory 2
switch modelClass
    case 'span'
        p.sigma2        = .075;
    case '1-attLat'
        p.sigma2        = .035;
    case '1-attK'
        p.sigma2        = .096;
    case 't2DecRef'
        p.sigma2        = .74;
    case '3S'
        p.sigma2        = .12;
    otherwise
        p.sigma2        = .08; %.1
end

% sensory 3
switch modelClass
    case '3S'
        p.sigma3        = .073;
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
        p.tau_attV      = 62;
        p.aMV           = 26; % 3.5,2.5
%         p.vAttScale2    = .21;
        p.span          = 885;
        p.attOnset      = -83;
        p.attOffsett    = 61;
    case '1-att'
        p.tau_ra        = 50;
        p.aM            = 1;
%         p.exoSOA  = 120;
        p.exoDur        = 50;
        p.exoProp       = 1;
    case '1-attK'
        p.tau_ra        = 25;
        p.aM            = 30;
        p.aIOR          = .02;
        p.span          = 1053;
        p.attOnset      = -51;
        p.attOffsett    = 15;
    case '1-attLat'
%         p.tau_ra  = 50;
        p.aM      = 100;
        p.vAttScale2    = .65;
        p.span          = 1200;
    case 't2DecRef'
        p.tau_attV      = 54;
        p.aMV           = 27; 
%         p.vAttScale2    = .21;
        p.span          = 713;
        p.attOnset      = -71;
        p.attOffsett    = 67;       
    case '3S'
        p.tau_attV      = 60;
        p.aMV           = 28; 
%         p.vAttScale2    = .21;
        p.span          = 737;
        p.attOnset      = -70;
        p.attOffsett    = 41; 
    case 'valo'
        p.tau_attV      = 62;
        p.aMV           = 26; 
%         p.vAttScale2    = .21;
        p.span          = 700;
        p.attOnset      = -83;
        p.attOffsett    = 61;     
        p.attnProp      = .75;
end
p.neutralT1Weight = .5;

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
        p.tau_attI      = 50;  %50         %time constant involuntary attention (ms)
        p.aMI           = 96;%2.5; % 5 (spatial sim), 4 (stronger IOR), 4 (temporal sim)
%         p.aIE           = 0;
        p.aIOR          = .93;%.36; % 1 (spatial sim), 1.3 (stronger IOR), 1.12 (temporal sim)
        p.asigma        = 19;%.22;  %.3
    case {'1-att','1-attLat'}
%         p.ap            = 4;
        p.asigma        = 1.2;
    case '1-attK'
        p.asigma        = 27;
    case 't2DecRef'
        p.tau_attI      = 1.7;
        p.aMI           = 1.17e5;
        p.asigma        = 26;
    case '3S'
        p.tau_attI      = 2.2;
        p.aMI           = 208;
        p.asigma        = 24;
    case 'valo'
        p.tau_attI      = 2;
        p.aMI           = 50;
        p.asigma        = 19;
end

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
        p.decisionRefractoryPeriod = 289;
end


% fitting
switch modelClass
    case 'transient-span'
        p.scaling1 = 2.4; %5*10^5; %77; % 4.2, 4.5
        p.scaling2 = 1.9; %4*10^5; %60; % 3.3
    case 'span'
        p.scaling1 = 1.7;%.31; % 4.5
        p.scaling2 = 1.4;%.31; % 3.6
    case '1-att'
        p.scaling1 = .5; % 4.5
        p.scaling2 = .5; % 3.6
    case '1-attK'
        p.scaling1 = 1.9; 
        p.scaling2 = 1.5; 
    case '1-attLat'
        p.scaling1 = 1.2; 
        p.scaling2 = 1;
    case 't2DecRef'
        p.scaling1 = 19;
        p.scaling2 = 15;
    case '3S'
        p.scaling1 = .75;
        p.scaling2 = .63;
    case 'valo'
        p.scaling1 = 1.7;
        p.scaling2 = 1.4;
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

