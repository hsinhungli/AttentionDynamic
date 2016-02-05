% runModelFA.m

% modified from runModelTA.m
% 2015-10-20 (RD)

% clear all

%% Set conditions/contrasts to simulate
condnames  =  {'no-att','exoF1','exoF2','endoF1','endoF2'};
p          = setParametersFA;
saveData   = 0;
plotFig    = 1;

% Pick contrasts to run
% logspace(-1.699,log10(.5),7)
% 0.0200    0.0342    0.0585    0.1000    0.1710    0.2924    0.5000
contrasts = [0.16 0.32 0.64];
soas = 100:50:800;

% Pick conditions to run
rcond     = [1 2 4];   %conditions to run
ncond     = numel(rcond);
rcontrast = 3;   %contrast levels to run
ncontrast = numel(rcontrast);
rsoa = 1;   %soa levels to run
nsoa = numel(rsoa);
p_pool         = cell(ncond*ncontrast*nsoa,1); %data (p) of each simulated condition will be saved here

condtag  = regexprep(num2str(rcond),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));

%% loop through all conditions to run
count = 0;
ev = zeros(2,nsoa,ncond,ncontrast);
for icond = 1:numel(rcond)
    cond = rcond(icond);
    condname = condnames{cond};
    
    %% Loop through contrast levels
    for icontrast = 1:numel(rcontrast)
        c = rcontrast(icontrast);
        for isoa = 1:numel(rsoa)
            s = rsoa(isoa);
            p.cond = cond;
            p.contrast = contrasts(:,c);
            p.soa = soas(:,s);
            fprintf('cond: %s contrast: %1.2f soa: %d \n\n', condname, p.contrast, p.soa)
            count = count+1;
            p = initTimeSeriesFA(p);
            p = setStimFA(condname,p);
            p = setTaskFA(condname,p);
            
            %Stimulus inputs
            p.i = p.stim;
            
            % convolve input with a temporal filter
            p.e = [];
            for i=1:size(p.i,1)
                p.e(i,:) = conv(p.i(i,:), p.filter_e);
            end
            p.e = p.e(:,1:p.nt);
            
            %run the model
            p = n_model_FA(p);
            
            % convolve output with a temporal filter
            p.r2 = [];
            for i=1:size(p.i,1)
                p.r2(i,:) = conv(p.r(i,:), p.filter_r2);
            end
            p.r2 = p.r2(:,1:p.nt);
            
            %accumulate evidence
            p = accumulateTA(condname,p);
            ev(:,isoa,icond,icontrast) = p.evidence(end,:);
            
            %save the p
            if saveData==1
                p = rmfield(p,{'d','s','f','d_n'});
            end
            p_pool{count} = p;
            
            %% Draw time series_1
            if plotFig == 1
                plotTA(condname, p)
                plotFA(condname, p)
            end
        end
    end
end

%% plot multiple conditions
for icontrast = 1:numel(rcontrast)
    plotPerformanceTA(condnames(rcond), soas(rsoa), ev(:,:,:,icontrast))
end

%% save data
if saveData==1
    sprintf('Saving file')
    save(dataName,'p_pool');
end
% fprintf('\n')