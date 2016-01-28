function [p] = n_model_FA(p)
%This function is called by runModelFA.m

idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
%     counterdisp(t);
    idx = idx+1;
    %% Computing the responses of a layer
    %defining inputs (stimulus)
    % use the stimulus that's been convolved with a temporal filter
    inp = p.e(:,idx);
    
    %updating noise
    p.d_n(:,idx) = p.d_n(:,idx-1) + (p.dt/p.tau_n)*...
        (-p.d_n(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
%     drive = halfExp(inp,p.p) .* p.att(:,idx-1) + p.d_n(:,idx);
    %drive : stimulus_contrast * attention + noise
%     p.d(:,idx) = halfExp(drive, 1); %rectification
    drive = halfExp(inp,p.p); %%% leaving out w and a
    p.d(:,idx) = halfExp(1+p.att(:,idx-1)).*drive;
    
    % normalization pool
    pool = p.d(:,idx);
    
    %Compute Suppressive Drive
    p.s(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma;
    
    %Normalization
    p.f(:,idx) = p.d(:,idx) ./ ...
        (p.s(:,idx) + halfExp(sigma, p.p) + halfExp(p.a(:,idx-1)*p.wa, p.p)) ...
        + p.baselineMod;
    %Adaptation, p.a, is implemented as Wilson 2003 here. %Subject to change
    %p.f{lay}(:,idx) = halfExp(p.f{lay}(:,idx)+ p.f_n{lay}(:,idx),1); %Add niose at the firing rate
    
    %update firing rates
    p.r(:,idx) = p.r(:,idx-1) + (p.dt/p.tau)*(-p.r(:,idx-1) + p.f(:,idx));
    
    %update adaptation
    p.a(:,idx) = p.a(:,idx-1) + (p.dt/p.tau_a)*(-p.a(:,idx-1) + p.r(:,idx));
    
    
    %% Update attention map
    % voluntary
    attnGainV = p.task(:,idx-1);
    p.attV(:,idx) = p.attV(:,idx-1) + (p.dt/p.tau_attV)*(-p.attV(:,idx-1) + attnGainV);
    
%     if idx==640
%         a = 1;
%         a = 2;
%     end
    
    % involuntary
    if idx > length(p.aW)
        r = p.r(:,idx-length(p.aW):idx-1);
    else
        r = nan(size(p.aW(:,:,1)));
        r(:,end-idx+2:end) = p.r(:,1:idx-1);
    end
    for iPhase = 1:2
        inp0    = halfExp(r.*fliplr(p.aW(:,:,iPhase)), p.ap);
        inp(:,iPhase)     = sum(inp0(:,max(end-idx+2,1):end),2); % sum across time
    end
    aDrive  = inp*p.aKernel; % on channel - off channel
    aE      = halfExp(1 + p.attV(:,idx)*p.aMV).*(aDrive + p.aBaseline);
    aS      = repmat((sum(aDrive) + p.asigma^p.ap),p.ntheta,1); % S + sigma^2
    
%     aDrive  = abs(p.aKernel*inp);
%     aSign   = sign(p.aKernel*inp);
%     attnGainI = halfExp(1 + p.aM*p.attV(:,idx), p.ap).* p.attV ./ repmat((sum(aDrive) + p.asigma^p.ap),p.ntheta,1) .*aSign,1);
    
    attnGainI = aE./aS;
    p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + attnGainI);

    % total
    p.att(:,idx) = p.attI(:,idx);
end

    function y = sigmoid(x,theta, k)
        y = 1./(1+exp(-k*(x-theta)));
    end
end