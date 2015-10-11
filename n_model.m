function [p] = n_model(p)
%This function is called by n_runModel.m
%The word 'layer' is used in the following sense:
%Layer 1 = Left monocular neurons
%Layer 2 = Right monocular neurons
%Layer 3 = Summation neurons
%Layer 4 = Left-Right opponency neurons
%Layer 5 = Right-Left opponency neurons

switch p.fbtype %This set the form of the inhibitory feedback from opponency layer
    case 's'
        p.w_opp_se = p.w_opp;
        p.w_opp_d  = 0;
        p.w_opp_g  = 0;
    case 'd'
        p.w_opp_se = 0;
        p.w_opp_d  = p.w_opp;
        p.w_opp_g  = 0;
    case 'g'
        p.w_opp_se = 0;
        p.w_opp_d  = 0;
        p.w_opp_g  = p.w_opp;
end

idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
    
    counterdisp(t);
    idx = idx+1;
    
    %% Computing the responses of Monocular layers
    for lay = [1 2]
        
        %defining inputs (stimulus)
        inp = p.i{lay}(:,idx);
        
        %updating noise
        p.d_n{lay}(:,idx) = p.d_n{lay}(:,idx-1) + (p.dt/p.tau_n)*...
            (-p.d_n{lay}(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp(lay)*sqrt(p.tau_n*2));
        
        %updating drives
        %drive : stimulus_contrast * attention - subtractive_inhibition + noise
        drive = halfExp(inp,p.p(lay)) .* p.att(:,idx-1) - p.inh{lay}(:,idx-1)*p.w_opp_se + p.d_n{lay}(:,idx);
        p.d{lay}(:,idx) = halfExp(drive, 1); %rectification
        
    end
    for lay = [1 2] 
        
        %defining normalization pool for each layer
        if lay ==1
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*1;       %within-eye normalization
            pool(:,2) = p.d{2}(:,idx)*p.w_int; %cross-eye normalization
        elseif lay ==2
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*p.w_int; %cross-eye normalization
            pool(:,2) = p.d{2}(:,idx)*1;       %within-eye normalization
        end
        
        %Compute Suppressive Drive
        p.s{lay}(:,idx) = sum(pool(:)); %suppressive drive: sum over all the units in normalization pool
        sigma           = p.sigma(lay); %semisaturation constant
        
        %Normalization 
        g = (1 + p.inh{lay}(:,idx-1)*p.w_opp_g); %(p.w_opp_g is used when modeling feedback as gain change, otherwise set as zero)
        p.s{lay}(:,idx) = p.s{lay}(:,idx).*g;
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./ (p.s{lay}(:,idx) + p.w_opp_d*p.inh{lay}(:,idx-1) ...
            + halfExp(sigma, p.p(lay)) + halfExp(p.a{lay}(:,idx-1)*p.wa(lay), p.p(lay))) + p.baselineMod(lay);
        %Adaptation, p.a, is implemented as increase of semisaturation constant. Same as HR Wilson 2003.
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx));
    end
    
    %% Computing the responses of Binocular layers
    for lay = 3:p.nLayers
        
        %defining inputs
        if lay == 3 %summation layer
            inp = p.r{1}(:,idx) + p.r{2}(:,idx);
        elseif lay == 4 %opponency layer (left-right)
            inp = p.r{1}(:,idx) - p.r{2}(:,idx);
        elseif lay == 5 %opponency layer (right-left)
            inp = p.r{2}(:,idx) - p.r{1}(:,idx);
        end
        
        %updating drives
        drive = halfExp(inp,p.p(lay));    %.* p.att(:,idx-1); %+ p.d_n{lay}(:,idx); %Can implement attention and nosie here.
        p.d{lay}(:,idx) = halfExp(drive); %Rectification (esp for Opponency layer)
    end
    for lay = 3:p.nLayers
        
        %defining normalization pool for each layer
        pool = p.d{lay}(:,idx);
        
        %Compute Suppressive Drive
        if lay == 3
            p.s{lay}(:,idx) = pool; %summation layer: just normalize itself, no cross orientation normalization
        elseif lay >= 4
            p.s{lay}(:,idx) = sum(pool(:)); %opponency layer: pool over orientation channls within L-R (or R-L) layer
        end
        sigma = p.sigma(lay);
        
        %Normalization
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./...
            (p.s{lay}(:,idx) + halfExp(sigma, p.p(lay)) + halfExp(p.a{lay}(:,idx-1)*p.wa(lay), p.p(lay))) + p.baselineMod(lay);
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx));
        
        %update negative feedback. This is a dummy variable simply save the value of inhibition that should fed back to monocular layers, no temporal
        %delay implemented here.
        if lay == 4
            Inh = sum(p.r{lay}(:,idx));
            p.inh{2}(:,idx) = p.inh{2}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{2}(:,idx-1) + Inh); %Inhibition sent to layer one
        elseif lay == 5
            Inh = sum(p.r{lay}(:,idx));
            p.inh{1}(:,idx) = p.inh{1}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{1}(:,idx-1) + Inh); %Inhibition sent to layer two
        end
    end
    
    %% Update attention map
    if p.changeAtt == 1 %Full Attention, No endo implemented yet, but exo follow stronger stimulus
        
        aKernel = [1 -1; -1 1];
        inp     = p.r{3}(:,idx-1);
        aDrive  = abs(aKernel*inp);
        aSign   = sign(aKernel*inp);
        attnGain = halfExp(p.baselineAtt + p.aM*aDrive.^p.ap ./ repmat((sum(aDrive.^p.ap) + p.asigma^p.ap),p.ntheta,1) .*aSign,1);
        %attnGain = max(attnGain,1);
        
        %WTA-inhibitory pool
        %attnGain = nan(p.ntheta,1);
        %diff1 = p.r{3}(1,idx-1)-p.r{3}(2,idx-1);
        %diff2 = p.r{3}(2,idx-1)-p.r{3}(1,idx-1);
        %attnGain(1) = halfExp(1 + p.aM*(sigmoid(diff1,p.aT,p.aR) - sigmoid(diff2,p.aT,p.aR)));
        %attnGain(2) = halfExp(1 + p.aM*(sigmoid(diff2,p.aT,p.aR) - sigmoid(diff1,p.aT,p.aR)));
        
    elseif p.changeAtt == 0;
        
        attnGain = ones(size(p.att(:,idx-1)));
        
    end
    
    p.att(:,idx) = p.att(:,idx-1) + (p.dt/p.tau_att)*(-p.att(:,idx-1) + attnGain);
end

% for lay = 1:p.nLayers %Add measurement noise when simulating EEG/MEG experiment
%     p.r{lay} = p.r{lay} + p.m_n{lay};
% end

%     function y = sigmoid(x,theta, k)
%         y = 1./(1+exp(-k*(x-theta)));
%     end
end