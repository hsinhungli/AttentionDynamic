function p = setStim(cond,p)

switch cond
    case {1,2} %Binocular Rivalry
        timeSeriesL = ones([1 p.nt]);
        timeSeriesR = ones([1 p.nt]);
        stimL = [1 0]'; %Orientation A
        stimR = [0 1]'; %Orientation B
        p.stimL = kron(timeSeriesL, stimL) * p.contrast(1);
        p.stimR = kron(timeSeriesR, stimR) * p.contrast(2);
    case {3,4} %Monocular Plaid
        timeSeriesL = ones([1 p.nt]);
        timeSeriesR = ones([1 p.nt]);
        stimL = [p.contrast(1) p.contrast(2)]';
        stimR = [0 0]';
        p.stimL = kron(timeSeriesL, stimL);
        p.stimR = kron(timeSeriesR, stimR);
    case {5,6} %Stimulus Rivalry
        p.timeSeriesL = ones([1 p.nt]);
        p.timeSeriesR = ones([1 p.nt]);
        p.swapIdx = mod(floor(p.tlist/300),2)+1;
        p.flickrIdx = mod(floor(p.tlist/30),2);
    case {7,8} %RP
        %         if p_pool{1}.r{3}(IdxL(1),IdxL(2),p.nt) == 0
        %             Idx = p.n{1}(IdxL(1),IdxL(2),:) >= p.n{2}(IdxR(1),IdxR(2),:);
        %         else
        %             Idx = p_pool{1}.r{3}(IdxL(1),IdxL(2),:) >= p_pool{1}.r{3}(IdxR(1),IdxR(2),:);
        %         end
        %         p.timeSeriesL = Idx;
        %         p.timeSeriesR = ~Idx;
end