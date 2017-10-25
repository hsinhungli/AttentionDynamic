% analyzeBootstrap

%% setup
fitDir = 'fit/bootstrap';

jobs = {'8249238','8252953','8269382','8278891'};
jobTasks = {1:10,11:100,101:201,202:203};
nJob = numel(jobs);

measure = 'span';

%% get values from all bootstrapped jobs
missingTasks = [];
idx = 1;
for iJob = 1:nJob
    job = jobs{iJob};
    tasks = jobTasks{iJob};
    nTasks = numel(tasks);
    
    for iTask = 1:nTasks
        task = tasks(iTask);
        jobName = sprintf('job%s%d', job, task);
        
        file = dir(sprintf('%s/*%s.mat', fitDir, jobName));
        if isempty(file)
            missingTasks = [missingTasks task];
        else
            fit = load(sprintf('%s/%s', fitDir, file.name));
            vals(idx) = fit.opt.(measure);
            idx = idx+1;
        end
    end
end

%% summary
ci = prctile(vals,[2.5 16 84 97.5]) % 95 and 68% confidence intervals

%% plot
figure
hist(vals)
xlabel(measure)

figure
boxplot(vals)
ylabel(measure)
        