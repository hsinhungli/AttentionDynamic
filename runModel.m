clear all;close all; drawnow;
condnames  =  {'B/A','B/iA','M/A','M/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
note = 'Only adaptation. No noise. Run BA condition to test different input range: Levelt 4. Similar to Shpiro 2007';
saveData   = 1;

%% Set conditions/contrasts to simulate
% Pick contrasts to run
% logspace(-1.699,log10(.5),7)
% 0.0200    0.0342    0.0585    0.1000    0.1710    0.2924    0.5000
contrasts =...
    [.08 .1 .12 .13 .15;...
     .12 .12 .12 .12 .12]; %put fixed variable in the second row
%contrasts = [.2;.2];
% Pick conditions to run
rstim     = 1;   %conditions to run
nstim     = length(rstim);
rcontrast = 1:5;   %contrast levels to run
ncontrast = length(rcontrast);
[stimList,contrastList] = ndgrid(rstim,rcontrast);
ncond = length(stimList);

p_pool    = cell(nstim*ncontrast,1); %data (p) of each simulated condition will be saved here

plotFig   = 1;
condtag  = regexprep(num2str(rstim),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));
initTime = GetSecs;

%% loop through all conditions to run
parfor cond = 1:ncond
    
    %% Decide stimuli configuration for this condition
    tempcond = stimList(cond);
    tempcontrast = contrastList(cond);
    p        = setParameters;
    p        = setModelPar(tempcond, p);
    p.cond       = tempcond;
    p.contrast   = contrasts(:,tempcontrast);
    fprintf('cond: %s contrast: %1.2f %1.2f \n\n', condnames{p.cond}, p.contrast(1), p.contrast(2))
    p = initTimeSeries(p);
    p = setStim(p.cond,p);
    
    %Stimulus inputs to monocular layers
    p.i{1} = p.stimL;
    p.i{2} = p.stimR;
    
    %run the model
    %ShowIdx = 1;
    p       = n_model(p);
    
    %% compute WTA index
    %p = getIndex(p,0,1,1,0);
    
    %save the p
    if saveData==1
        p = rmfield(p,{'d','s','f','d_n'});
    end
    p_pool{cond} = p;
end

endTime = GetSecs;
duration = endTime - initTime;
disp(duration/60);
%% Draw time series_1
plotFig = 1;
if plotFig == 1
    for cond = 1:ncond
            
            p = p_pool{cond};
            plotduration = 30*1000;
            pIdx = p.tlist<plotduration;
%             subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
%             cpsFigure(2,.8);
%             set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p.cond}, p.contrast(1), p.contrast(2)));
%             for lay = 1:p.nLayers
%                 subplot(2,3,subplotlocs(lay))
%                 cla; hold on;
%                 if lay==4
%                     temp1 = squeeze(p.inh{1}(1,:))*p.w_opp;
%                     ptemp = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[0 0 0]);
%                 elseif lay==5
%                     temp1 = squeeze(p.inh{2}(1,:))*p.w_opp;
%                     ptemp = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[0 0 0]);
%                 else
%                     temp1 = squeeze(p.r{lay}(1,:));
%                     temp2 = squeeze(p.r{lay}(2,:));
%                     pL = plot(p.tlist(pIdx)/1000,temp1(pIdx),'color',[1 0 1]);
%                     pR = plot(p.tlist(pIdx)/1000,temp2(pIdx),'color',[0 0 1]);
%                 end
%                 ylabel('Firing rate')
%                 xlabel('Time (s)')
%                 title(layernames(lay))
%                 set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])+.1]);
%                 drawnow;
%             end
%             subplot(2,3,5)
%             plot(p.tlist(pIdx)/1000,p.att(1,pIdx),'color',[1 0 1]); hold on;
%             plot(p.tlist(pIdx)/1000,p.att(2,pIdx),'color',[0 0 1]);
%             title('Attention')
%             tightfig;
            
            %% Draw time sereis_2
%             cpsFigure(1,1.5);
%             set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p.cond}, p.contrast(1), p.contrast(2)));
%             
%             %To view the two rivarly time series
%             subplot(4,1,1);hold on
%             title('Summation Layer')
%             %imagesc(p.tlist(pIdx)/1000,.5,p.phaseIdx)
%             colormap([.8 .65 .65;.65 .65 .8;])
%             lay = 3;
%             temp1 = squeeze(p.r{lay}(1,:));
%             temp2 = squeeze(p.r{lay}(2,:));
%             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
%             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
%             xlim([0 max(p.tlist(pIdx)/1000)])
%             ylim([0 max([temp1(:)' temp2(:)'])+.1])
%             set(gca,'FontSize',12)
%             
%             %Left eye
%             subplot(4,1,2);hold on
%             title(sprintf('LE contrast:%2.4f',p_pool{cond}.contrast(1)))
%             lay=1;
%             temp1 = squeeze(p.r{lay}(1,:));
%             temp2 = squeeze(p.r{lay}(2,:));
%             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
%             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
%             xlim([0 max(p.tlist(pIdx)/1000)])
%             ylim([0 max([temp1(:)' temp2(:)'])+.1])
%             
%             %Right eye
%             subplot(4,1,3);hold on
%             title(sprintf('RE contrast:%2.4f',p_pool{cond}.contrast(2)))
%             lay=2;
%             temp1 = squeeze(p.r{lay}(1,:));
%             temp2 = squeeze(p.r{lay}(2,:));
%             plot(p.tlist(pIdx)/1000, temp1(pIdx),'r:','LineWidth',1)
%             plot(p.tlist(pIdx)/1000, temp2(pIdx),'b:','LineWidth',1)
%             xlim([0 max(p.tlist(pIdx)/1000)])
%             ylim([0 max([temp1(:)' temp2(:)'])+.1])
%             xlabel('Time (sec)', 'FontSize',12)
%             tightfig;
%             drawnow;
            
            cpsFigure(1,.4); hold on;
            title(sprintf('SummationL contrast:%2.4f',p_pool{cond}.contrast(2)))
            %imagesc(p.tlist(pIdx)/1000,.5,p.phaseIdx)
            colormap([.8 .65 .65;.65 .65 .8;])
            lay = 3;
            temp1 = squeeze(p.r{3}(1,:));
            temp2 = squeeze(p.r{3}(2,:));
            plot(p.tlist(pIdx)/1000, temp1(pIdx),'r-')
            plot(p.tlist(pIdx)/1000, temp2(pIdx),'b-')
            xlim([0 max(p.tlist(pIdx)/1000)])
            ylim([0 max([temp1(:)' temp2(:)'])+.1])
            set(gca,'FontSize',12)
    end
end

if saveData==1
    sprintf('Saving file')
    p.note = note;
    save(dataName,'p_pool');
end
