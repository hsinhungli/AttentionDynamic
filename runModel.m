%close all; drawnow;
condnames  =  {'B/A','B/iA','P/A','P/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
p          = setParameters;
saveData   = 0;

%% Set conditions/contrasts to simulate
% Pick contrasts to run
% logspace(-1.699,log10(.5),7)
% 0.0200    0.0342    0.0585    0.1000    0.1710    0.2924    0.5000
contrasts =...
    [.1;...
     .1]; %put fixed variable in the second row

% Pick conditions to run
rcond     = 1;   %conditions to run
ncond     = numel(rcond);
rcontrast = 1;   %contrast levels to run
ncontrast = numel(rcontrast);
p_pool         = cell(ncond*ncontrast,1); %data (p) of each simulated condition will be saved here

plotFig   = 1;
if plotFig 
    plotduration = 20*1000;
    pIdx = p.tlist<plotduration;
    subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
end
condtag  = regexprep(num2str(rcond),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));

%% loop through all conditions to run
count = 0;
for cond = rcond
    
    %% Decide stimuli configuration for this condition
    p = setModelPar(cond, p);
    
    %% Loop through contrast levels
    for c = rcontrast
        
        p.cond = cond;
        p.contrast = contrasts(:,c);
        fprintf('cond: %s contrast: %1.2f %1.2f \n\n', condnames{cond}, p.contrast(1), p.contrast(2))
        count = count+1;
        p = initTimeSeries(p);
        p = setStim(cond,p);
        stim{cond,c,1} = p.stimL; %This has to change for monocular plaid
        stim{cond,c,2} = p.stimR; %This has to change for monocular plaid
        
        %Stimulus inputs to monocular layers
        for lay = 1:2
            p.i{lay} = stim{cond,c,lay};
        end
        
        %run the model
        %ShowIdx = 1;
        p       = n_model(p);
        
        %% compute WTA index
        p = getIndex(p,0,1,1,0);
        
        %save the p
        if saveData==1
        p = rmfield(p,{'d','s','f','d_n'});
        end
        p_pool{count} = p;
        
        %% Draw time series_1
        if plotFig == 1
            cpsFigure(2,.8);
            set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{cond}, p.contrast(1), p.contrast(2)));
            for lay = 1:p.nLayers
                subplot(2,3,subplotlocs(lay))
                cla; hold on;
                temp1 = squeeze(p.r{lay}(1,:));
                temp2 = squeeze(p.r{lay}(2,:));
                pL = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[1 0 1]);
                pR = plot(p.tlist(pIdx)/1000,temp2(pIdx),'color',[0 0 1]);
                
                ylabel('Firing rate')
                xlabel('Time (s)')
                title(layernames(lay))
                set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])+.1]);
                drawnow;
            end
            subplot(2,3,5)
            plot(p.tlist(pIdx)/1000,p.att(1,pIdx),'color',[1 0 1]); hold on;
            plot(p.tlist(pIdx)/1000,p.att(2,pIdx),'color',[0 0 1]);
            title('Attention')
            tightfig;
            
            %% Draw time sereis_2
            cpsFigure(1,1.5);
            set(gcf,'Name',sprintf('%s contrast: %1.1f %1.1f', condnames{cond}, p.contrast(1), p.contrast(2)));
            
            %To view the two rivarly time series
            subplot(4,1,1);hold on
            title('Summation Layer')
            %imagesc(p.tlist(pIdx)/1000,.5,p.phaseIdx)
            colormap([.8 .65 .65;.65 .65 .8;])
            xlim([1 max(p.tlist(pIdx)/1000)])
            lay = 3;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
            plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
            set(gca,'FontSize',12)
            
            %Left eye
            subplot(4,1,2);hold on
            title('LE')
            lay=1;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
            plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
            
            %Right eye
            subplot(4,1,3);hold on
            title('RE')
            lay=2;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist(pIdx)/1000, temp1(pIdx),'r:','LineWidth',1)
            plot(p.tlist(pIdx)/1000, temp2(pIdx),'b:','LineWidth',1)
            xlabel('Time (sec)', 'FontSize',12)
            drawnow;
        end
    end
end

if saveData==1
    sprintf('Saving file')
    save(dataName,'p_pool');
end
