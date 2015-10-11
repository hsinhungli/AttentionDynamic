contrasts = .02:.01:.22;
state = nan(size(contrasts));

state(contrasts>=.02 & contrasts<=.03) = 1;
state(contrasts>=.04 & contrasts<=.04) = 2;
%state(contrasts>=.03 & contrasts<=.18) = 3;%WTA
state(contrasts>=.05  & contrasts<=.11) = 4; %Oscillation
state(contrasts>=.12 & contrasts<=.22) = 5;

cpsFigure(.5,.5)
imagesc(contrasts,1,state)
xlabel('contrasts','FontSize',14)
set(gca,'YTick',[]);
axis square
tightfig;
%%
plot(log10([.03 .03]), [0 1],'k')
plot(log10([.05 .05]), [0 1],'k')
plot(log10([.11 .11]), [0 1],'k')
%plot(log10([.2 .2]), [0 1],'k')
%plot(log10([.14 .14]), [0 1],'k')
%plot(log10([.2 .2]), [0 1],'k')
xlim(log10([.01 .4]))