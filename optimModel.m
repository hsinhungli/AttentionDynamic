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
[opt0, x0] = x2opt;
% [opt0, x0, lb, ub] = x2opt;

% make function to take extra params
f = @(x)modelCost(x,D);

% do optimization
[x,fval,exitflag,output] = fminsearch(f, x0);
% x = fmincon(@f,x0,[],[],[],[],lb,ub);

%% final state
opt = x2opt(x);
p = setParametersFA(opt);
[cost, model, data] = modelCost(x, D);
timestamp = datestr(now);

%% save
save(sprintf('fit/fit_workspace_%s', datestr(now,'yyyymmddTHHMM')))

%% plot
soas = D.t1t2soa;
figure
for iT = 1:2
    subplot(1,2,iT)
    hold on
    plot(soas, data(:,:,iT)','.','MarkerSize',20)
    plot(soas, model(:,:,iT)')
    ylim([0 2])
    xlabel('soa')
    ylabel('dprime / evidence')
    title(sprintf('T%d',iT))
end
legend('valid','invalid')

