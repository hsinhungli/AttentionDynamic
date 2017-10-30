% testDistributeAttention2.m

%% setup
span = 1000;
neutralT1Weight = .5;
exoSOA = 120;
exoProp = 0.5;

cuedTimes = [1 2 0];
nCuedTimes = numel(cuedTimes);
soas = 100:100:1000;

%% run
for iCue = 1:nCuedTimes
    cuedTime = cuedTimes(iCue);
    for iSOA = 1:numel(soas)
        soa = soas(iSOA);
        [attn(iSOA,:,iCue), attnExo(iSOA,:,iCue)] = ...
            distributeAttention2(span, cuedTime, soa, neutralT1Weight, exoSOA, exoProp);
    end
end

%% plot
for i=2
    figure
    for iCue = 1:nCuedTimes
        subplot(1,nCuedTimes,iCue)
        hold on
        plot(soas, attn(:,:,iCue))
        if i==2
            plot(soas, attnExo(:,:,iCue))
        end
        ylim([-.2 1.2])
    end
    if i==1
        legend('attn1', 'attn2')
    else
        legend('attn1', 'attn2', 'exo1', 'exo2')
    end
end