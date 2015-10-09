function cascade = cascadeExp(cascade, input, tau, dt, idx, nCascades)

% cascade is n x time x number of cascades
% idx is the current time point

cascade(:,idx,1) = cascade(:,idx-1,1) + (dt/tau)*(-cascade(:,idx-1,1) + input); % initialize with input
for iC = 2:nCascades
    cascade(:,idx,iC) = cascade(:,idx-1,iC) + (dt/tau)*(-cascade(:,idx-1,iC) + cascade(:,idx,iC-1));
end
