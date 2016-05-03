function optimModel(dataDir, saveDir)

%% setup
if nargin==0
    dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
    saveDir = 'fit';
end

% load data
dataType = 'ave'; % 'ave','seq'
switch dataType
    case 'ave'
        dataFile = 'E2_SOA_cbD6_run98_N4_workspace_20160128.mat';
        D = load(sprintf('%s/%s', dataDir, dataFile));
    case 'seq'
        % load axis-orient data
        dataNames = {'SOSA','DOSA','SODA','DODA'};
        for id = 1:numel(dataNames)
            dataFile = sprintf('E2_SOA_cbD6_run98_N4_%s_workspace_20160128.mat', dataNames{id});
            D(id) = load(sprintf('%s/%s', dataDir, dataFile));
        end
end

% store things for modelCost
D.saveDir = saveDir;

% load previous fit
w = load('fit/fit_workspace_20160501_interim.mat');

% prepare figure for plotting
figure
turnwhite

%% optimization
% initialize params
% [opt0, x0] = x2opt;
% [opt0, x0, lb, ub] = x2opt;
opt0 = w.opt; 
x0 = w.x;

% make function to take extra params
f = @(x)modelCost(x,D);

% set output function
% options = optimset('OutputFcn', @optimOutfun);

% do optimization
[x,fval,exitflag,output] = fminsearch(f, x0);
% [x,fval,exitflag,output] = fminsearch(f, x0, options);
% [x,fval,exitflag,output] = fmincon(f,x0,[],[],[],[],lb,ub);

%% final state
opt = x2opt(x);
p = setParametersFA(opt);
[cost, model, data, R2] = modelCost(x, D);
timestamp = datestr(now);

%% save
save(sprintf('%s/fit_workspace_%s', saveDir, datestr(now,'yyyymmddTHHMM')))

