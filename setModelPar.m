function p = setModelPar(cond,p)
% [IdxL] = [find(p.theta==120) find(p.x==p.stimCenterL)];
% [IdxR] = [find(p.theta==30) find(p.x==p.stimCenterR)];

switch cond
    case 1 %Dichoptic Gratings + Attention
        p.aend          = 0;
        p.changeAtt     = 1;
    case 2 %Dichoptic Gratings + noAttention
        p.aend          = 0;
        p.changeAtt     = 0;
    case 3 %Plaid + Attention
        p.aend          = 0;
        p.changeAtt     = 1;
    case 4 %Plaid + noAttention
        p.aend          = 0;
        p.changeAtt     = 0;
end
%end