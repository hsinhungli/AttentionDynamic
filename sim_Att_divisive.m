R1    = -1:.01:2;
R2    = .25*ones(size(R1));
R     = [R1;R2];
sigma = .2;
n     = 2;
baseline = 1;

aKernel = [1 -1; -1 1];
aDrive  = abs(aKernel*R);
aSign   = sign(aKernel*R);
attGain = baseline + aDrive.^n ./ repmat((sum(aDrive.^n) + sigma^n),2,1) .*aSign;

%figure;
plot(R1-R2,attGain')
xlabel('R1-R2')
ylabel('Attentional gain factor')
