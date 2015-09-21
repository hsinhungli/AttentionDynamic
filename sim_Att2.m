R1 = 0:.01:2;
R2 = 1*ones(size(R1));
sigma = 2;
n     = 2;
am    = 1;
inp1  = halfExp(R1,n);
inp2  = halfExp(R2,n);

attR1 = halfExp(1 + am*(inp1 - inp2) ./ (inp1 + sigma^n),1);
attR2 = halfExp(1 + am*(inp2 - inp1) ./ (inp2 + sigma^n),1);

figure;
plot(R1,attR1); hold on
plot(R1,attR2);
%plot(R1R2, fliplr(attR1)); hold on
%plot(R1R2,ones(size(R1R2)),'--')
ylim([0 3])
%xlim([-1 1])
xlabel('R1','FontSize',15)
ylabel('aGain','FontSize',15)
legend({'attention to ori1','attention to ori2'},'FontSize',16)