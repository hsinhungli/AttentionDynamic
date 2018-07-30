% sim_crf_with_normalization_eqs.m


n = 2; % exponent

stimWidth = 5; 
cRange = [1e-5 1]; %[1e-2 1];
nContrasts = 21;

% Sampling of space and orientation
x = -100:100;
nx = numel(x);

% Make stimuli
stimCenter = 0;
stimOrientation = 0;
stim = makeGaussian(x,stimCenter,stimWidth,1); 

% Pick contrasts
logCRange = log10(cRange);
logContrasts = linspace(logCRange(1),logCRange(2),nContrasts);
contrasts = 10.^logContrasts;

sigma = median(contrasts);

%% Option 1: f(s)*c^n
R1 = [];
R1Ratio = [];
for iContrast = 1:nContrasts
    contrast = contrasts(iContrast);
    E = stim.*contrast^n;
    S = sum(E);
    R1(:,iContrast) = E./(S + sigma^n);
    if iContrast > 1
        R1Ratio(:,iContrast-1) = R1(:,iContrast)./R1(:,iContrast-1);
    end
end

figure
plot(x,R1)
title('Option 1: f(s)*c^n')

% check contrast invariance of the tuning function
figure
plot(x,R1Ratio)
title('Option 1: f(s)*c^n')

figure
plot(logContrasts, R1(round(nx/2),:))
title('Option 1: f(s)*c^n')

%% Option 2: (f(s)*c)^n
R2 = [];
R2Ratio = [];
for iContrast = 1:nContrasts
    contrast = contrasts(iContrast);
    E = (stim.*contrast).^n;
    S = sum(E);
    R2(:,iContrast) = E./(S + sigma^n);
    if iContrast > 1
        R2Ratio(:,iContrast-1) = R2(:,iContrast)./R2(:,iContrast-1);
    end
end

figure
plot(x,R2)
title('Option 2: (f(s)*c)^n')

figure
plot(x,R2Ratio)
title('Option 2: (f(s)*c)^n')

figure
plot(logContrasts, R2(round(nx/2),:))
title('Option 2: (f(s)*c)^n')

%% What is a power law?
a1 = linspace(0,1,100);
a2 = a1.^3;

figure
plot(a1, a2);


