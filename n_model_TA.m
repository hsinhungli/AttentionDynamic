function [p] = n_model_TA(p)
%This function is called by runModelTA.m

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
    drive = halfExp(inp,p.p) .* p.att(:,idx-1) + p.d_n(:,idx);
    %drive : stimulus_contrast * attention + noise
    p.d(:,idx) = halfExp(drive, 1); %rectification
    
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
    % involuntary
    inp     = p.r(:,idx-1);
    aDrive  = abs(p.aKernel*inp);
    aSign   = sign(p.aKernel*inp);
    
    attnGainI = halfExp(1 + p.aM*aDrive.^p.ap ./ repmat((sum(aDrive.^p.ap) + p.asigma^p.ap),p.ntheta,1) .*aSign,1) ...
        - p.h(:,idx-1)*p.wh;
%     p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + attnGainI);
    p.attICascade = cascadeExp(p.attICascade, attnGainI, p.tau_attI, p.dt, idx, p.nAttICascades);
    p.attI = p.attICascade(:,:,end);
    
    % voluntary
    attnGainV = 1 + p.task(:,idx-1);
    p.attV(:,idx) = p.attV(:,idx-1) + (p.dt/p.tau_attV)*(-p.attV(:,idx-1) + attnGainV);
    
    % total
    p.att(:,idx) = p.attI(:,idx).*p.attV(:,idx);

    % update h
%     p.h(:,idx) = p.h(:,idx-1) + (p.dt/p.tau_h)*(-p.h(:,idx-1) + halfExp(attnGainI-1,1));
    p.hCascade = cascadeExp(p.hCascade, halfExp(attnGainI-1,1), p.tau_h, p.dt, idx, p.nHCascades);
    p.h = p.hCascade(:,:,end);
end

    function y = sigmoid(x,theta, k)
        y = 1./(1+exp(-k*(x-theta)));
    end
end