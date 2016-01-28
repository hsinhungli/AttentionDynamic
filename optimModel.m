% optimModel.m

%% setup
% load data
dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
dataFile = 'E2_SOA_cbD6_run98_N4_workspace_20160128.mat';
D = load(sprintf('%s/%s', dataDir, dataFile));

% prepare figure for plotting
figure
turnwhite

%% optimization
% initialize params
[opt0, x0, lb, ub] = x2opt;

% make function to take extra params
f = @(x)modelCost(x,D);

x = fminsearch(f, x0);
% x = fmincon(@f,x0,[],[],[],[],lb,ub);
opt = x2opt(x);


