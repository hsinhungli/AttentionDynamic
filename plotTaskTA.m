% plotTaskTA

soas = [200 500 800];

for i = 1:numel(soas)
    p.soa = soas(i);
    
    % distribute voluntary attention
    if p.distributeVoluntary
        totalAtt = 1 + p.soa/p.span;
        if totalAtt>2
            totalAtt = 2;
        end
        if strcmp(condname, 'endoT1T2')
            p.vAttWeights = distributeAttention(totalAtt, 0, [], p.neutralT1Weight);
        else
            p.vAttWeights = distributeAttention(totalAtt, 1, 1);
        end
        p.vAttWeight1 = p.vAttWeights(1);
        p.vAttWeight2 = p.vAttWeights(2);
    end
    
    % set task
    p = setTaskTA('endoT1',p);
    a(:,i) = p.task(1,:);
    
    p = setTaskTA('endoT2',p);
    a(:,numel(soas)+i) = p.task(1,:);
end

figure
for i = 1:numel(soas)*2
    subplot(numel(soas)*2,1,i)
    plot(p.tlist,a(:,i));
    xlim([-200 1000])
end