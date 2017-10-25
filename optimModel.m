function optimModel(dataDir, saveDir, jobID, D)
  
%% setup
if nargin==0
    dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
    saveDir = 'fit';
end
if nargin<3
    jobStr = '';
else
    jobStr = sprintf('_job%d', jobID);
end
if nargin<4
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
end

% store things for modelCost
D.saveDir = saveDir;

% load previous fit
% prevfit = load(sprintf('%s/fit_workspace_20160429T0059.mat', saveDir));

% prepare figure for plotting
figure
turnwhite

%% optimization
% initialize params
[opt0, x0] = x2opt;
% [opt0, x0, lb, ub] = x2opt;
% opt0 = prevfit.opt;
% x0 = prevfit.x;

% make function to take extra params
f = @(x)modelCost(x,D);

% set options
% options = optimset('OutputFcn', @optimOutfun);
options = optimset('Display','iter');
% options = optimset('Display','iter','MaxFunEvals',3);
% options = optimset('Display','iter','MaxFunEvals',3, 'OutputFcn', @outfun);

% do optimization
[x,fval,exitflag,output] = fminsearch(f, x0, options);
% [x,fval,exitflag,output] = fminsearch(f, x0);
% [x,fval,exitflag,output] = fmincon(f,x0,[],[],[],[],lb,ub);

%% final state
opt = x2opt(x);
p = setParametersFA(opt);
[cost, model, data, R2] = modelCost(x, D);
timestamp = datestr(now);

%% save
save(sprintf('%s/fit_workspace_%s%s', saveDir, datestr(now,'yyyymmddTHHMM'), jobStr))

% function stop = outfun(~,optimValues,~)
%     stop = false;
%     fprintf('Iter: %d, Func count: %d\n', optimValues.iteration, optimValues.funccount)
% end
end

