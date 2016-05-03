function [cost, model, data, R2] = modelCost(x, D)

%% run model
opt = x2opt(x);
% [perf, p] = runModelTA(opt);
[perf, p] = runModelParallel(opt);

%% format model and data
if iscell(p)
    par = 'seq';
    nseq = numel(p);
    figNames = {'seq1','seq2','seq3','seq4'};
else
    par = 'soa';
    figNames = {'fig'};
end

switch par
    case 'soa'
        %% organize model performance
        for iT = 1:2
            model(:,:,iT) = perf{iT};
        end
        
        %% scale fit
        model(:,:,1) = model(:,:,1)*p.scaling1 + p.offset1;
        model(:,:,2) = model(:,:,2)*p.scaling2 + p.offset2;
        
        %% load data
        for iT = 1:2
            data(:,:,iT) = D.dpMean{iT}(1:2,:);
        end
    case 'seq'
        p = p{1};
        
        %% organize model performance
        for iS = 1:nseq
            for iT = 1:2
                model(:,:,iT,iS) = perf{iS}{iT};
            end
        end
        
        %% scale fit
        model(:,:,1,:) = model(:,:,1,:)*p.scaling1 + p.offset1;
        model(:,:,2,:) = model(:,:,2,:)*p.scaling2 + p.offset2;
        model(:,:,:,[2 4]) = model(:,:,:,[2 4]) + p.diffOrientOffset;
        
        %% load data
        for iS = 1:nseq
            for iT = 1:2
                data(:,:,iT,iS) = D(iS).dpMean{iT}(1:2,:);
            end
        end
end

%% compare model to data
error = model - data;
cost = sum(error(:).^2);

sstot = sum((data(:)-mean(data(:))).^2);
R2 = 1 - cost/sstot;

%% display current state
disp(x)
fprintf('R2 = %1.3f\n', R2)

%% plot
switch par
    case 'soa'
        soas = D.t1t2soa;
        figure(gcf)
        clf
        for iT = 1:2
            subplot(1,2,iT)
            hold on
            plot(soas, data(:,:,iT)','.','MarkerSize',20)
            plot(soas, model(:,:,iT)')
            ylim([0 2])
            xlabel('soa')
            ylabel('dprime')
            title(sprintf('T%d',iT))
        end
        legend('valid','invalid')
    case 'seq'
        soas = D(1).t1t2soa;
        for iS = 1:nseq
            figure(iS)
            clf
            for iT = 1:2
                subplot(1,2,iT)
                hold on
                plot(soas, data(:,:,iT,iS)','.','MarkerSize',20)
                plot(soas, model(:,:,iT,iS)')
                ylim([-0.5 3])
                xlabel('soa')
                ylabel('dprime')
                title(sprintf('T%d',iT))
            end
        end
        legend('valid','invalid')
end

%% save
saveDir = D.saveDir;
save(sprintf('%s/fit_workspace_%s_interim', saveDir, datestr(now,'yyyymmdd')))
rd_saveAllFigs([],figNames, [], saveDir)
