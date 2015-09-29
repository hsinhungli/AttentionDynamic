% runModelTA.m

% modified from runModel.m
% 2015-09-28 (RD)

%% Set conditions/contrasts to simulate
condnames  =  {'endoT1','endoT2','endoT1T2','no-endo'};
p          = setParametersTA;
saveData   = 0;
plotFig    = 1;

% Pick contrasts to run
% logspace(-1.699,log10(.5),7)
% 0.0200    0.0342    0.0585    0.1000    0.1710    0.2924    0.5000
contrasts = [0.1 1];
soas = [250 800];

% Pick conditions to run
rcond     = 1;   %conditions to run
ncond     = numel(rcond);
rcontrast = 2;   %contrast levels to run
ncontrast = numel(rcontrast);
rsoa = 1;   %soa levels to run
nsoa = numel(rsoa);
p_pool         = cell(ncond*ncontrast*nsoa,1); %data (p) of each simulated condition will be saved here

condtag  = regexprep(num2str(rcond),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));

%% loop through all conditions to run
count = 0;
for cond = rcond
    
    condname = condnames{cond};
    
    %% Decide stimuli configuration for this condition
%     p = setModelParTA(condname, p);
    
    %% Loop through contrast levels
    for c = rcontrast
        for s = rsoa
            p.cond = cond;
            p.contrast = contrasts(:,c);
            p.soa = soas(:,s);
            fprintf('cond: %s contrast: %1.2f soa: %d \n\n', condname, p.contrast, p.soa)
            count = count+1;
            p = initTimeSeriesTA(p);
            p = setStimTA(p);
            p = setTaskTA(condname,p);
            
            %Stimulus inputs
            p.i = p.stim;
            
            % convolve with temporal filter
            for i=1:size(p.i,1)
                p.e(i,:) = conv(p.i(i,:), p.filter); %%% can this be done inside n_model_TA with a differential eq?
            end
            p.e = p.e(:,1:p.nt);
            
            %run the model
            p = n_model_TA(p);
            
            %save the p
            if saveData==1
                p = rmfield(p,{'d','s','f','d_n'});
            end
            p_pool{count} = p;
            
            %% Draw time series_1
            if plotFig == 1
                %% Figure 1
                % panel 1
                cpsFigure(1.6,2);
                set(gcf,'Name',sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));

                subplot(6,2,1)
                hold on
                plot(p.tlist/1000,p.i(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.i(2,:),'color',[0 0 1]);
                ylabel('Input')
%                 set(gca,'YLim',[0 max(p.i(:))+.1*max(p.i(:))]);
                
                subplot(6,2,3)
                hold on
                plot(p.tlist/1000,p.e(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.e(2,:),'color',[0 0 1]);
                ylabel('Temporally filtered')
%                 set(gca,'YLim',[0 max(p.e(:))+.1*max(p.e(:))]);
                
                subplot(6,2,5)
                hold on
                plot(p.tlist/1000,p.d(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.d(2,:),'color',[0 0 1]);
                ylabel('Excitatory drive')
%                 set(gca,'YLim',[0 max(p.d(:))+.1*max(p.d(:))]);
                
                subplot(6,2,7)
                hold on
                plot(p.tlist/1000,p.s(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.s(2,:),'color',[0 0 1]);
                ylabel('Suppressive drive')
%                 set(gca,'YLim',[0 max(p.s(:))+.1*max(p.s(:))]);
                
                subplot(6,2,9)
                hold on
                plot(p.tlist/1000,p.f(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.f(2,:),'color',[0 0 1]);
                ylabel('Steady-state')
%                 set(gca,'YLim',[0 max(p.f(:))+.1]);
                
                subplot(6,2,11)
                hold on
                plot(p.tlist/1000,p.r(1,:),'color',[1 0 1]);
                plot(p.tlist/1000,p.r(2,:),'color',[0 0 1]);
                ylabel('Firing rate')
                xlabel('Time (s)')
                set(gca,'YLim',[0 max(p.r(:))+.1]);
                   
                % panel 2
                subplot(6,2,2)
                hold on
                plot(p.tlist/1000,p.stim(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.stim(2,:),'color',[0 0 1]);
                ylabel('Stimulus')
                
                subplot(6,2,4)
                hold on
                plot(p.tlist/1000,p.task(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.task(2,:),'color',[0 0 1]);
                ylabel('Task')
                
                subplot(6,2,6)
                hold on
                plot(p.tlist/1000,p.h(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.h(2,:),'color',[0 0 1]);
                ylabel('Inv. suppression (h)')
                
                subplot(6,2,8)
                hold on
                plot(p.tlist/1000,p.attI(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.attI(2,:),'color',[0 0 1]);
                ylabel('Involuntary att')
                
                subplot(6,2,10)
                hold on
                plot(p.tlist/1000,p.attV(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.attV(2,:),'color',[0 0 1]);
                ylabel('Voluntary att')
                
                subplot(6,2,12)
                hold on
                plot(p.tlist/1000,p.att(1,:),'color',[1 0 1]); 
                plot(p.tlist/1000,p.att(2,:),'color',[0 0 1]);
                ylabel('Attention')
                
                rd_supertitle(sprintf('%s contrast: %1.2f soa: %d', condname, p.contrast, p.soa));
%                 tightfig
            end
        end
    end
end

if saveData==1
    sprintf('Saving file')
    save(dataName,'p_pool');
end
% fprintf('\n')
