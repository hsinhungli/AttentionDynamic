% interpretParams.m

%% load fits
load fit/fit_workspace_8MODELS_20180822.mat

%% setup
fit = S1;

rsoa = 10;
rcond = 2;
thresh = .01;

%% run model
[perf, p] = runModelTA(fit.opt, fit.modelClass, rsoa, [], rcond);

%% total attentional modulation
switch fit.modelClass
    case '1-attK'
        % AV
        avRange = [min(p.attV(:)) max(p.attV(:))]*p.aM;
        aiRange = [NaN NaN];
    otherwise
        % AV
        avRange = [min(p.attV(:)) max(p.attV(:))]*p.aMV;
        
        % AI
        aiRange = [min(p.attI(:)) max(p.attI(:))]*p.aMI;
end

% print
fprintf('AV min = %1.4f, max = %1.4f\n', avRange)
fprintf('AI min = %1.4f, max = %1.4f\n', aiRange)

%% peak latency and duration of attentional modulation
stimOnsets = 500 + [0 p.soa];

% AV
ts = mean(p.attV);
pos = ts>max(ts)*thresh;
neg = ts<min(ts)*thresh;
lobes = {pos, neg};
avDur = []; % [pos neg]
avLat = []; % [pos neg]
for iL = 1:numel(lobes)
    idx = [];
    lobe = lobes{iL};
    starts = find(diff(lobe)==1);
    ends = find(diff(lobe)==-1);
    durs = (ends-starts)*p.dt;
    if isempty(durs)
        avDur(iL) = NaN;
        avLat(iL) = NaN;
    else
        [avDur(iL),idx] = max(durs);
        avLat(iL) = (starts(idx) + find(abs(ts(starts(idx):ends(idx)))==...
            max(abs(ts(starts(idx):ends(idx))))) - 2)*p.dt - stimOnsets(idx);
    end
end

% AI
ts = mean(p.attI);
pos = ts>max(ts)*thresh;
neg = ts<min(ts)*thresh;
lobes = {pos, neg};
aiDur = []; 
aiLat = [];
for iL = 1:numel(lobes)
    idx = [];
    lobe = lobes{iL};
    starts = find(diff(lobe)==1);
    ends = find(diff(lobe)==-1);
    durs = (ends-starts)*p.dt;
    if isempty(durs)
        aiDur(iL) = NaN;
        aiLat(iL) = NaN;
    else
        [aiDur(iL),idx] = max(durs);
        aiLat(iL) = (starts(idx) + find(abs(ts(starts(idx):ends(idx)))==...
            max(abs(ts(starts(idx):ends(idx))))) - 2)*p.dt - stimOnsets(idx);
    end
end

% figure
% hold on
% plot(mean(p.attI))
% plot(pos*.005)

% print
fprintf('AV duration, pos = %1.0f ms, neg = %1.0f ms\n', avDur)
fprintf('AI duration, pos = %1.0f ms, neg = %1.0f ms\n', aiDur)
fprintf('AV latency, pos = %1.0f ms, neg = %1.0f ms\n', avLat)
fprintf('AI latency, pos = %1.0f ms, neg = %1.0f ms\n', aiLat)
