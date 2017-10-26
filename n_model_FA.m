function [p] = n_model_FA(p)
%This function is called by runModelFA.m

idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
    idx = idx+1;
    
    %% Sensory layer 1 transient (S1t)
    %defining inputs (stimulus)
    inp = p.stim(:,idx);
    
    %updating drives
    if any(inp)
        drive = halfExp(p.rfresp(logical(inp),:),p.p)'*p.contrast*inp(logical(inp)); % select pre-calculated response
    else
        drive = zeros(p.ntheta,1);
    end
    p.dtr(:,idx) = drive; 
    
    % normalization pool
    pool = p.dtr(:,idx);
    
    %Compute Suppressive Drive
    p.str(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma;
    
    %Normalization
    p.ftr(:,idx) = p.dtr(:,idx) ./ ...
        (p.str(:,idx) + halfExp(sigma, p.p)); % simplified
    
    %update firing rates
    p.rtr(:,idx) = p.rtr(:,idx-1) + (p.dt/p.tautr)*(-p.rtr(:,idx-1) + p.ftr(:,idx));

    
    %% Computing the responses of sensory layer
    %defining inputs (stimulus)
    idxdelay = round(p.delay/p.dt);
    if idxdelay >= idx
        inp = zeros(size(p.stim(:,idx)));
    else
        inp = p.stim(:,idx - idxdelay); % introduce a delay before the s1 response
    end
    
    %updating noise
    p.d_n(:,idx) = p.d_n(:,idx-1) + (p.dt/p.tau_n)*...
        (-p.d_n(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
    if any(inp)
        drive = halfExp(p.rfresp(logical(inp),:),p.p)'*p.contrast*inp(logical(inp)); % select pre-calculated response
    else
        drive = zeros(p.ntheta,1);
    end
    %     drive = halfExp(drive - p.rtr(:,idx)); % subtract transient inhibition

    p.d(:,idx) = halfExp(1+p.attV(:,idx-1)*p.aMV).*halfExp(1+p.attI(:,idx-1)*p.aMI).*drive;

    % normalization pool
    pool = p.d(:,idx);
    
    %Compute Suppressive Drive
    p.s(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma;
    
    %Normalization
    p.f(:,idx) = p.d(:,idx) ./ ...
        (p.s(:,idx) + halfExp(sigma, p.p) + halfExp(p.a(:,idx-1)*p.wa, p.p));
    %Adaptation, p.a, is implemented as Wilson 2003 here.
    %p.f(:,idx) = halfExp(p.f(:,idx)+ p.f_n(:,idx),1); %Add niose at the firing rate
    
    %update firing rates
    p.r(:,idx) = p.r(:,idx-1) + (p.dt/p.tau)*(-p.r(:,idx-1) + p.f(:,idx));
    p.r(:,idx) = halfExp(p.r(:,idx) - sum(p.rtr(:,idx))); % subtract transient response
    
    %update adaptation
    p.a(:,idx) = p.a(:,idx-1) + (p.dt/p.tau_a)*(-p.a(:,idx-1) + p.r(:,idx));
 
    
    %% Computing the responses of sensory layer 2 (S2)
    %updating noise
    p.d2_n(:,idx) = p.d2_n(:,idx-1) + (p.dt/p.tau_n)*...
        (-p.d2_n(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
    % directly from r
    drive = halfExp(p.r(:,idx),p.p);
    p.d2(:,idx) = drive;
    
    % normalization pool
    pool = p.d2(:,idx);
    
    %Compute Suppressive Drive
    p.s2(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma2;
    
    %Normalization
    p.f2(:,idx) = p.d2(:,idx) ./ ...
        (p.s2(:,idx) + halfExp(sigma, p.p) + halfExp(p.a2(:,idx-1)*p.wa, p.p));
    %p.f(:,idx) = halfExp(p.f(:,idx)+ p.f_n(:,idx),1); %Add niose at the firing rate
    
    %update firing rates
    p.r2(:,idx) = p.r2(:,idx-1) + (p.dt/p.tau_r2)*(-p.r2(:,idx-1) + p.f2(:,idx));
    
    %update adaptation
    p.a2(:,idx) = p.a2(:,idx-1) + (p.dt/p.tau_a)*(-p.a2(:,idx-1) + p.r2(:,idx));
    
    
    %% Computing the responses of the decision layer
    % decode just between CCW/CW for the appropriate axis
    for iStim = 1:2
        switch p.stimseq(iStim)
            case {1, 2}
                rfresp(:,:,iStim) = p.rfresp(1:2,:);
            case {3, 4}
                rfresp(:,:,iStim) = p.rfresp(3:4,:);
        end
        evidence = decodeEvidence(p.r(:,idx)', rfresp(:,:,iStim)); % r2
        evidence = evidence*p.decisionWindows(iStim,idx); % only accumulate if in the decision window
        evidence(abs(evidence)<1e-3) = 0; % otherwise zero response will give a little evidence
        
%         % drive
%         drive = evidence;
%         p.dd(iStim,idx) = drive;
        
        p.fd(iStim,idx) = evidence;
    end
    
%     %updating noise
%     p.dd_n(:,idx) = p.dd_n(:,idx-1) + (p.dt/p.tau_n)*...
%         (-p.dd_n(:,idx-1) + randn(p.nstim,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
%     
%     % normalization pool
%     pool = p.dd(:,idx);
%     
%     %Compute Suppressive Drive
%     p.sd(:,idx) = abs(pool(:));
%     %         p.sd(:,idx) = sum(abs(pool(:))); %normalized across stimuli
%     sigma = p.sigmad;
%     
%     %Normalization
%     p.fd(:,idx) = p.dd(:,idx) ./ ...
%         (p.sd(:,idx) + halfExp(sigma, p.p) + halfExp(p.ad(:,idx-1)*p.wa, p.p));
    
    %update firing rates
    p.rd(:,idx) = p.rd(:,idx-1) + (p.dt/p.tau_rd)*(-p.rd(:,idx-1) + p.fd(:,idx));
    %         p.rd(:,idx) = p.rd(:,idx-1) + p.fd(:,idx); % no leak
    
%     % ceiling on firing rate
%     for iStim = 1:p.nstim
%         if abs(p.rd(iStim,idx))>p.ceiling
%             p.rd(iStim,idx) = p.ceiling*sign(p.rd(iStim,idx));
%         end
%     end
%     
%     %update adaptation
%     p.ad(:,idx) = p.ad(:,idx-1) + (p.dt/p.tau_a)*(-p.ad(:,idx-1) + p.rd(:,idx));
    
    %% Update voluntary attention layer
    attnGainV = p.task(:,idx-1);
    p.attV(:,idx) = p.attV(:,idx-1) + (p.dt/p.tau_attV)*(-p.attV(:,idx-1) + attnGainV);
    
    %% Update involuntary attention layer
    if idx > length(p.aW)
        r = p.rtr(:,idx-length(p.aW):idx-1);
    else
        r = nan(size(p.aW(:,:,1)));
        r(:,end-idx+2:end) = p.rtr(:,1:idx-1);
    end
    inp = [];
    for iPhase = 1:2
        inp0 =  r.*fliplr(p.aW(:,:,iPhase)); % convolve step 1 (multiply)
        inp1 =  sum(inp0(:,max(end-idx+2,1):end),2)*p.dt; % convolve step 2 (integrate across time)
        inp(:,iPhase)     = halfExp(inp1,p.ap); % rectify and raise to power
    end
    aDrive  = inp*p.aKernel; % on channel - off channel
    
    % feature-specific
%     p.dai(:,idx)      = aDrive; 
    % not feature-specific (e.g. spatial)
    p.dai(:,idx) = sum(aDrive);
    
    p.sai(:,idx) = sum(abs(p.dai(:,idx)));
    sigma = p.asigma;
    
    p.fai(:,idx) = p.dai(:,idx) ./ (p.sai(:,idx) + halfExp(sigma, p.ap));

    attnGainI = p.fai(:,idx);
    p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + attnGainI);
end
