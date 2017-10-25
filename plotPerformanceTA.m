function perfv = plotPerformanceTA(condnames, soas, perf)

% if ~isequal(condnames,{'no-endo','endoT1','endoT2','endoT1T2'})
%     fprintf('conds must be {"no-endo","endoT1","endoT2","endoT1T2"}\nnot plotting ...\n')
%     return
% end
if numel(soas)==1
    fprintf('plotPerformanceTA is for multiple SOAS, not plotting ...\n')
    perfv = [];
    return
end

plotOption = 1; % 1 = normal; 2 = during fitting; 0 = no plot

%% re-sort endo condition data into valid, invalid, neutral
if isequal(condnames,{'no-endo','endoT1','endoT2','endoT1T2'}) || isequal(condnames,{'no-endo','exoT1','exoT2','exoT1T2'})
    cueValidityNames = {'valid','invalid','both','none'};
    
    perfv{1}(1,:) = perf(1,:,2); % T1 valid
    perfv{1}(2,:) = perf(1,:,3); % T1 invalid
    perfv{1}(3,:) = perf(1,:,4); % T1 neutral - endoT1T2
    perfv{1}(4,:) = perf(1,:,1); % T1 neutral - no endo
    
    perfv{2}(1,:) = perf(2,:,3); % T2 valid
    perfv{2}(2,:) = perf(2,:,2); % T2 invalid
    perfv{2}(3,:) = perf(2,:,4); % T2 neutral - endoT1T2
    perfv{2}(4,:) = perf(2,:,1); % T2 neutral - no endo
elseif isequal(condnames,{'endoT1','endoT2'}) || isequal(condnames,{'exoT1','exoT2'})
    cueValidityNames = {'valid','invalid'};
    
    perfv{1}(1,:) = perf(1,:,1); % T1 valid
    perfv{1}(2,:) = perf(1,:,2); % T1 invalid
    
    perfv{2}(1,:) = perf(2,:,2); % T2 valid
    perfv{2}(2,:) = perf(2,:,1); % T2 invalid
elseif isequal(condnames,{'endoT1','endoT2','endoT1T2'}) || isequal(condnames,{'exoT1','exoT2','exoT1T2'})
    cueValidityNames = {'valid','invalid','both'};
    
    perfv{1}(1,:) = perf(1,:,1); % T1 valid
    perfv{1}(2,:) = perf(1,:,2); % T1 invalid
    perfv{1}(3,:) = perf(1,:,3); % T1 neutral - endoT1T2
    
    perfv{2}(1,:) = perf(2,:,2); % T2 valid
    perfv{2}(2,:) = perf(2,:,1); % T2 invalid
    perfv{2}(3,:) = perf(2,:,3); % T2 neutral - endoT1T2
else
    fprintf('conds must be {"no-endo","endoT1","endoT2","endoT1T2"} or {"endoT1","endoT2"} or {"endoT1","endoT2","endoT1T2"}\nnot plotting ...\n')
    return
end

% cuing effect and average across cue validities
for iT = 1:numel(perfv)
    cueEff{iT} = squeeze(perfv{iT}(1,:,:) - perfv{iT}(2,:,:));
    cueAve{iT} = squeeze(mean(perfv{iT},1));
end

%% plot figs
% sorted by validity
intervalNames = {'T1','T2'};
% ylims = [0 25]; % [0 12]
% ylims = [0 1];
ylims = [0 max([perfv{1}(:); perfv{2}(:)])*1.1];
xlims = [soas(1)-100 soas(end)+100];
colors = get(0,'DefaultAxesColorOrder');
axTitle = '';

% evidence
if plotOption~=0
    if plotOption==2
        figure(gcf)
        clf
    else
        figure
    end
    for iT = 1:numel(perfv)
        subplot(1,numel(perfv),iT)
        hold on
        p1 = plot(repmat(soas',1,numel(cueValidityNames)),...
            perfv{iT}', '.-', 'MarkerSize', 20);
        
        xlabel('soa')
        ylabel('evidence')
        title(intervalNames{iT})
        xlim(xlims)
        ylim(ylims)
        
        if iT==1
            legend(p1, cueValidityNames,'location','northeast')
        end
        %     rd_supertitle(subjectID);
        %     rd_raiseAxis(gca);
        %     rd_supertitle(axTitle);
    end
end

if plotOption==1
    figure
    for iT = 1:numel(perfv)
        subplot(1,numel(perfv),iT)
        hold on
        
        plot(soas, cueEff{iT})
        plot(soas, cueAve{iT},'k')
        
        xlabel('soa')
        ylabel('cuing effect / average performance')
        title(intervalNames{iT})
        xlim(xlims)
        ylim(ylims)
    end
    legend('cuing effect','average performance')
end
