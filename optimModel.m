function optimModel(dataDir, saveDir, jobID, D)
  
parpool('SpmdEnabled',false)

%% setup
if nargin==0
    dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
%     dataDir = '/Local/Users/denison/Google Drive/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
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
    nSubjects = 5; % 4, 5
    fileDate = '20180731'; % '20160128','20180731'
    switch dataType
        case 'ave'
            dataFile = sprintf('E2_SOA_cbD6_run98_N%d_workspace_%s.mat', nSubjects, fileDate);
            D = load(sprintf('%s/%s', dataDir, dataFile));
        case 'seq'
            % load axis-orient data
            dataNames = {'SOSA','DOSA','SODA','DODA'};
            for id = 1:numel(dataNames)
                dataFile = sprintf('E2_SOA_cbD6_run98_N%d_%s_workspace_%s.mat', ...
                    nSubjects, dataNames{id}, fileDate);
                D(id) = load(sprintf('%s/%s', dataDir, dataFile));
            end
    end
end

% store things for modelCost
D(1).saveDir = saveDir;
D(1).jobStr = jobStr;

% load previous fit
usePreviousFit = false;
if usePreviousFit
    % prevfit = load(sprintf('%s/fit_workspace_20160429T0059.mat', saveDir));
    prevfit = load(sprintf('%s/fit_workspace_20171108_interim.mat', saveDir));
end

%% initial grid search
doGridSearch = false;
if doGridSearch
    nSamples = 10;
    
    [opt0, x0, lb, ub, ranges] = x2opt;
    xSamples = [];
    xSamplesCosts = [];
    for iSample = 1:nSamples
        xSample = nan(size(x0));
        for iParam = 1:numel(x0)
            r = ranges(iParam,:);
            xSample(iParam) = r(1) + (r(2)-r(1)).*rand;
        end
        [cost, model, data, R2] = modelCost(xSample, D, 0);
        
        xSamples(iSample,:) = xSample;
        xSamplesCosts(iSample,1) = cost;
    end
end

%% optimization
% initialize params
if usePreviousFit
    opt0 = prevfit.opt;
    x0 = prevfit.x;
else
    [opt0, x0] = x2opt;
%     [opt0, x0, lb, ub] = x2opt;
end

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

