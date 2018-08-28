function optimModel(dataDir, saveDir, jobID, D, modelClass, prevFitFile)
  
parpool('SpmdEnabled',false)

%% setup
if nargin<1 || isempty(dataDir)
%     dataDir = '/Users/rachel/Documents/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
    dataDir = '/Local/Users/denison/Google Drive/NYU/Projects/Temporal_Attention/Code/Expt_Scripts/Behav/data';
end
if nargin<2 || isempty(saveDir)
    saveDir = 'fit';
end
if nargin<3 || isempty(jobID)
    jobStr = '';
else
    jobStr = sprintf('_job%d', jobID);
end
if nargin<4 || isempty(D)
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
if nargin<5
    modelClass = '';
end
if nargin<6
    prevFitFile = [];
end

% store things for modelCost
D(1).saveDir = saveDir;
D(1).jobStr = jobStr;

% load previous fit
% prevFitFile = 'fit_workspace_20171108_interim';
if ~isempty(prevFitFile)
    usePreviousFit = 1;
    prevfit = load(sprintf('%s/%s.mat', saveDir, prevFitFile));
else
    usePreviousFit = 0;
end

%% initial grid search
doGridSearch = false;
if doGridSearch
    nSamples = 10;
    
    [opt0, x0, lb, ub, ranges] = x2opt([], modelClass);
    xSamples = [];
    xSamplesCosts = [];
    for iSample = 1:nSamples
        xSample = nan(size(x0));
        for iParam = 1:numel(x0)
            r = ranges(iParam,:);
            xSample(iParam) = r(1) + (r(2)-r(1)).*rand;
        end
        [cost, model, data, R2] = modelCost(xSample, D, modelClass, 0);
        
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
    [opt0, x0] = x2opt([], modelClass);
%     [opt0, x0, lb, ub] = x2opt([], modelClass);
end

% make function to take extra params
f = @(x)modelCost(x,D,modelClass);

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
opt = x2opt(x, modelClass);
p = setParametersFA(opt, modelClass);
[cost, model, data, R2] = modelCost(x, D, modelClass);
timestamp = datestr(now);

%% save
modelStr = sprintf('_%s', p.modelClass);
save(sprintf('%s/fit_workspace_%s%s%s', saveDir, datestr(now,'yyyymmddTHHMM'), jobStr, modelStr))

% function stop = outfun(~,optimValues,~)
%     stop = false;
%     fprintf('Iter: %d, Func count: %d\n', optimValues.iteration, optimValues.funccount)
% end
end

