function [p] = n_model_FA(p)
%This function is called by runModelFA.m

idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
%     counterdisp(t);
    idx = idx+1;
    
    %% Sensory layer 1 transient (S1t)
    %defining inputs (stimulus)
    inp = p.stim(:,idx);
    
    %updating drives
    if isempty(p.rf) 
        drive = halfExp(inp,p.p); %%% leaving out w and a
    else
        if any(inp)
            drive = halfExp(p.rfresp(logical(inp),:),p.p)'*p.contrast*inp(logical(inp)); % select pre-calculated response
        else
            drive = zeros(p.ntheta,1);
        end
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
    if isempty(p.rf) 
        drive = halfExp(inp,p.p); %%% leaving out w and a
    else
        if any(inp)
            drive = halfExp(p.rfresp(logical(inp),:),p.p)'*p.contrast*inp(logical(inp)); % select pre-calculated response
        else
            drive = zeros(p.ntheta,1);
        end
    end
    drive = drive + p.r2(:,idx-1)*p.wF; % add feedback from layer S2 to drive
%     drive = halfExp(drive - p.rtr(:,idx)); % subtract transient inhibition
    % orig
    p.d(:,idx) = halfExp(1+p.attV(:,idx-1)*p.aMV).*halfExp(1+p.attI(:,idx-1)*p.aMI).*drive;
    % with history on drive
%     drive = halfExp(1+p.attV(:,idx-1)*p.aMV).*halfExp(1+p.attI(:,idx-1)*p.aMI).*drive;
%     p.d(:,idx) = p.d(:,idx-1) + (p.dt/p.tau)*(-p.d(:,idx-1) + drive);
    % with history on drive - cascade version
%     drive = halfExp(1+p.attV(:,idx-1)*p.aMV).*halfExp(1+p.attI(:,idx-1)*p.aMI).*drive;
%     p.rCascade = cascadeExp(p.rCascade, drive, p.tau, p.dt, idx, p.nRCascades);
%     p.d(:,idx) = p.rCascade(:,idx,end);

    % normalization pool
    pool = p.d(:,idx);
    % normalization pool - include transient response
%     pool = p.d(:,idx) + p.rtr(:,idx)*100;
    
    %Compute Suppressive Drive
    p.s(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma;
    
    %Normalization
    p.f(:,idx) = p.d(:,idx) ./ ...
        (p.s(:,idx) + halfExp(sigma, p.p) + halfExp(p.a(:,idx-1)*p.wa, p.p)) ...
        + p.baselineMod;
    %Adaptation, p.a, is implemented as Wilson 2003 here. %Subject to change
    %p.f(:,idx) = halfExp(p.f(:,idx)+ p.f_n(:,idx),1); %Add niose at the firing rate
    
    %update firing rates
    % orig
%     p.r(:,idx) = p.r(:,idx-1) + (p.dt/p.tau)*(-p.r(:,idx-1) + p.f(:,idx));
    % cascade
    p.rCascade = cascadeExp(p.rCascade, p.f(:,idx), p.tau, p.dt, idx, p.nRCascades);
    % subtract transient response
    p.rCascade(:,idx,:) = halfExp(p.rCascade(:,idx,:) - sum(p.rtr(:,idx)));
    p.r(:,idx) = p.rCascade(:,idx,end);
    % add to cascade for initial transient
%     for i = 1:p.ntheta
%         if p.rCascade(i,idx,6)==0
%             p.r(i,idx) = 0;
%         else
%             p.r(i,idx) = p.rCascade(i,idx,6)./p.rCascade(i,idx,7);
%         end
%     end
    % with history on drive
%     p.r(:,idx) = p.f(:,idx);
    
    %update adaptation
    p.a(:,idx) = p.a(:,idx-1) + (p.dt/p.tau_a)*(-p.a(:,idx-1) + p.r(:,idx));
 
    
    %% Computing the responses of sensory layer 2 (S2)
    %defining inputs (stimulus)
%     inp = p.r(:,idx);
    
    %updating noise
    p.d2_n(:,idx) = p.d2_n(:,idx-1) + (p.dt/p.tau_n)*...
        (-p.d2_n(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
    % with temporal receptive field
%     if idx > length(p.s2W)
%         r = p.r(:,idx-length(p.s2W):idx-1);
%     else
%         r = nan(size(p.s2W));
%         r(:,end-idx+2:end) = p.r(:,1:idx-1);
%     end
%     inp0  = r.*fliplr(p.s2W); % convolve step 1 (multiply)
%     inp1  = sum(inp0(:,max(end-idx+2,1):end),2)*p.dt; % convolve step 2 (integrate across time)
%     drive = halfExp(inp1,p.p); % rectify and raise to power
%     p.d2(:,idx) = drive;
    % directly from r
    drive = p.r(:,idx);
    p.d2(:,idx) = drive;
    
    % normalization pool
    pool = p.d2(:,idx);
    
    %Compute Suppressive Drive
    p.s2(:,idx) = sum(pool(:)); %normalized across orientation
    sigma = p.sigma2;
    
    %Normalization
    p.f2(:,idx) = p.d2(:,idx) ./ ...
        (p.s2(:,idx) + halfExp(sigma, p.p) + halfExp(p.a2(:,idx-1)*p.wa, p.p)) ...
        + p.baselineMod;
    %Adaptation, p.a, is implemented as Wilson 2003 here. %Subject to change
    %p.f(:,idx) = halfExp(p.f(:,idx)+ p.f_n(:,idx),1); %Add niose at the firing rate
    
    %update firing rates
    p.r2(:,idx) = p.r2(:,idx-1) + (p.dt/p.tau_r2)*(-p.r2(:,idx-1) + p.f2(:,idx));
    
    %update adaptation
    p.a2(:,idx) = p.a2(:,idx-1) + (p.dt/p.tau_a)*(-p.a2(:,idx-1) + p.r2(:,idx));
    
    
    %% Computing the responses of working memory layer
    %updating noise
    p.dwm_n(:,idx,:) = p.dwm_n(:,idx-1,:) + (p.dt/p.tau_n)*...
        (-p.dwm_n(:,idx-1,:) + randn(p.ntheta,p.nx,p.nstim)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
    % with temporal receptive field
    for istim = 1:p.nstim
        rr = p.r.*repmat(p.gate(istim,:),p.ntheta,1); % gate
        if idx > length(p.wmW)
            r = rr(:,idx-length(p.wmW):idx-1);
        else
            r = nan(size(p.wmW));
            r(:,end-idx+2:end) = rr(:,1:idx-1);
        end
        inp0  = r.*fliplr(p.wmW); % convolve step 1 (multiply)
        inp1  = sum(inp0(:,max(end-idx+2,1):end),2)*p.dt; % convolve step 2 (integrate across time)
        drive = halfExp(inp1,p.p); % rectify and raise to power
        p.dwm(:,idx,istim) = drive; % note difference from sensory layer: no attention
    end
    
    % normalization pool
    pool = p.dwm(:,idx,:); % pool over features and stimuli
    
    %Compute Suppressive Drive
    p.swm(:,idx,:) = sum(pool(:)); %normalized across orientation
    
    %Normalization
    p.fwm(:,idx,:) = p.dwm(:,idx,:) ./ ...
        (p.swm(:,idx,:) + halfExp(p.sigmawm, p.p) + halfExp(p.awm(:,idx-1,:)*p.wa, p.p)) ...
        + p.baselineMod;
    
    %update firing rates
    p.rwm(:,idx,:) = p.rwm(:,idx-1,:) + (p.dt/p.tauwm)*(-p.rwm(:,idx-1,:) + p.fwm(:,idx,:));
    
    %update adaptation
    p.awm(:,idx,:) = p.awm(:,idx-1,:) + (p.dt/p.tau_a)*(-p.awm(:,idx-1,:) + p.rwm(:,idx,:));
    
    
    %% Computing the responses of the decision layer
    if isempty(p.rf)
        error('must have RF to decode at each time step')
    else
        % decode just between CCW/CW for the appropriate axis
        for iStim = 1:2
            switch p.stimseq(iStim)
                case {1, 2}
                    rfresp(:,:,iStim) = p.rfresp(1:2,:);
                case {3, 4}
                    rfresp(:,:,iStim) = p.rfresp(3:4,:);
            end
            evidence = decodeEvidence(p.r2(:,idx)', rfresp(:,:,iStim)); % r2
            evidence = evidence*p.decisionWindows(iStim,idx); % only accumulate if in the decision window
            evidence(abs(evidence)<1e-3) = 0; % otherwise zero response will give a little evidence
            
%             p.e(iStim,idx) = p.e(iStim,idx-1) + evidence;
%             if abs(p.e(iStim,idx))>p.ceiling
%                 p.e(iStim,idx) = p.ceiling*sign(p.e(iStim,idx));
%             end

            % drive
            drive = evidence;
            p.dd(iStim,idx) = drive;
        end
        
        %updating noise
        p.dd_n(:,idx) = p.dd_n(:,idx-1) + (p.dt/p.tau_n)*...
            (-p.dd_n(:,idx-1) + randn(p.nstim,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));

        % normalization pool
        pool = p.dd(:,idx);

        %Compute Suppressive Drive
        p.sd(:,idx) = abs(pool(:));
%         p.sd(:,idx) = sum(abs(pool(:))); %normalized across stimuli
        sigma = p.sigmad;

        %Normalization
        p.fd(:,idx) = p.dd(:,idx) ./ ...
            (p.sd(:,idx) + halfExp(sigma, p.p) + halfExp(p.ad(:,idx-1)*p.wa, p.p)) ...
            + p.baselineMod;

        %update firing rates
        p.rd(:,idx) = p.rd(:,idx-1) + (p.dt/p.tau_rd)*(-p.rd(:,idx-1) + p.fd(:,idx));
%         p.rd(:,idx) = p.rd(:,idx-1) + p.fd(:,idx); % no leak
        
        % ceiling on firing rate
        for iStim = 1:p.nstim
            if abs(p.rd(iStim,idx))>p.ceiling
                p.rd(iStim,idx) = p.ceiling*sign(p.rd(iStim,idx));
            end
        end

        %update adaptation
        p.ad(:,idx) = p.ad(:,idx-1) + (p.dt/p.tau_a)*(-p.ad(:,idx-1) + p.rd(:,idx));
    end
    
    %% Update attention layer
    % voluntary
    attnGainV = p.task(:,idx-1);
    p.attV(:,idx) = p.attV(:,idx-1) + (p.dt/p.tau_attV)*(-p.attV(:,idx-1) + attnGainV);
    
    % involuntary
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
%     aE      = aDrive; 
    % not feature-specific (e.g. spatial)
    aE      = repmat(sum(aDrive),p.ntheta,1);
    
    aS      = repmat((sum(abs(aE)) + p.asigma^p.ap),p.ntheta,1); % S + sigma^2
    
    p.aDrive(:,idx) = aDrive; p.aE(:,idx) = aE; p.aS(:,idx) = aS; % store things

    attnGainI = aE./aS;
    p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + attnGainI);

    % total
%     p.att(:,idx) = p.attI(:,idx);
end

    function y = sigmoid(x,theta, k)
        y = 1./(1+exp(-k*(x-theta)));
    end
end