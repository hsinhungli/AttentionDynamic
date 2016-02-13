function [p] = n_model_FA(p)
%This function is called by runModelFA.m

idx = 1; %corresponds to t=0
% istim = 1; % relevant only for WM. works only with no noise at the moment.
for t = p.dt:p.dt:p.T
%     counterdisp(t);
    idx = idx+1;
%     if t > p.stimOnset + p.soa
%         istim = 2;
%     end
    
    %% Computing the responses of sensory layer
    %defining inputs (stimulus)
    % use the stimulus that's been convolved with a temporal filter
%     inp = p.e(:,idx);
    inp = p.stim(:,idx);
    
    %updating noise
    p.d_n(:,idx) = p.d_n(:,idx-1) + (p.dt/p.tau_n)*...
        (-p.d_n(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp*sqrt(p.tau_n*2));
    
    %updating drives
%     drive = halfExp(inp,p.p) .* p.att(:,idx-1) + p.d_n(:,idx);
    %drive : stimulus_contrast * attention + noise
%     p.d(:,idx) = halfExp(drive, 1); %rectification
    if isempty(p.rf) 
        drive = halfExp(inp,p.p); %%% leaving out w and a
    else
        if any(inp)
            drive = halfExp(p.rfresp(logical(inp),:),p.p)'; % select pre-calculated response
        else
            drive = zeros(p.ntheta,1);
        end
    end
    p.d(:,idx) = halfExp(1+p.att(:,idx-1)).*drive; % previous -> turning
%     into dynamical here:
%     p.d(:,idx) = p.d(:,idx-1) + (p.dt/p.tau_e)*...
%         (-p.d(:,idx-1) + halfExp(1+p.att(:,idx-1)).*drive);
    
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

%     % with history
%     drive = halfExp(p.r(:,idx),p.p); %%% leaving out w and a
%     p.dwm(:,idx,:) = p.dwm(:,idx-1,:) + (p.dt/p.tau_dwm)*(-p.dwm(:,idx-1,:));
%     p.dwm(:,idx,istim) = p.dwm(:,idx-1,istim) + (p.dt/p.tau_dwm)*(-p.dwm(:,idx-1,istim) + drive); % overwrite
    
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
    
    
    %% Update attention map
    % voluntary
    attnGainV = p.task(:,idx-1);
    p.attV(:,idx) = p.attV(:,idx-1) + (p.dt/p.tau_attV)*(-p.attV(:,idx-1) + attnGainV);
    
    % involuntary
    if idx > length(p.aW)
        r = p.r(:,idx-length(p.aW):idx-1);
    else
        r = nan(size(p.aW(:,:,1)));
        r(:,end-idx+2:end) = p.r(:,1:idx-1);
    end
    inp = [];
    for iPhase = 1:2
%         inp0    = halfExp(r.*fliplr(p.aW(:,:,iPhase)), p.ap);
%         inp(:,iPhase)     = sum(inp0(:,max(end-idx+2,1):end),2); % sum across time
        inp0 =  r.*fliplr(p.aW(:,:,iPhase)); % convolve step 1 (multiply)
        inp1 =  sum(inp0(:,max(end-idx+2,1):end),2)*p.dt; % convolve step 2 (integrate across time)
        inp(:,iPhase)     = halfExp(inp1,p.ap); % rectify and raise to power
    end
    aDrive  = inp*p.aKernel; % on channel - off channel
    aE      = halfExp(1 + p.attV(:,idx)*p.aMV).*(aDrive + p.aBaseline);
%     aS      = repmat((sum(aDrive) + p.asigma^p.ap),p.ntheta,1); % S + sigma^2
    aS      = repmat((sum(abs(aE)) + p.asigma^p.ap),p.ntheta,1); % S + sigma^2
    
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