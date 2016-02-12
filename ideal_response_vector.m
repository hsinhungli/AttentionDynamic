% ideal_response_vector.m
%
% calculate responses of raised cosine RFs to stimuli

%% setup
nRF = 6;
tilt = 2*pi/180;
step = .001;

% stim = [pi/2+tilt pi/2-tilt tilt pi-tilt]; % V-CCW V-CW H-CCW H-CW
stim = [pi/2+tilt pi/2-tilt]; % V-CCW V-CW

theta = 0:step:pi;

%% make RFs
for iRF = 1:nRF
    rf(:,iRF) = abs(cos(theta + iRF*pi/nRF).^(2*nRF-1));
end

%% find intersection of RFs with stim
for iS = 1:numel(stim)
    idx(iS) = find(abs(theta-stim(iS))==min(abs(theta-stim(iS))));
end

%% get RF responses to each stim
for iS = 1:numel(stim)
    resp(iS,:) = rf(idx(iS),:);
end

%% show results
disp(resp)

figure
plot(theta,rf)

figure
plot(resp')

%% save
save(sprintf('rf/resp_stim%d_rf%d.mat',numel(stim),nRF), 'nRF','stim','resp','theta','rf')

%% project random point to line defined by RF responses to a stim
ndimtoplot = '3d';
switch ndimtoplot
    case '2d'
        % example with just 2 RFs
        resp2 = resp(:,[2 4]);
        center = mean(resp2,1);
        sampleResp = rand(1,2);
        
        % p = polyfit(resp2(:,1),resp2(:,2),1);
        % x1 = linspace(-1,1);
        % y1 = polyval(p,x1);
        % sampleProj = distance2curve([x1; y1]', sampleResp);
        
        m = diff(resp2,1);
        extreme(1,:) = center - m*10;
        extreme(2,:) = center + m*10;
        sampleProj = distance2curve(extreme, sampleResp);
        
        figure
        hold on
        plot(resp2(:,1),resp2(:,2),'.');
        % plot(x1, y1);
        plot(center(1),center(2),'.k')
        plot(extreme(:,1),extreme(:,2),'.')
        plot(sampleResp(1),sampleResp(2),'.r')
        plot(sampleProj(1),sampleProj(2),'.r')
        axis equal
        
        % in direction of stim 1 or stim 2?
        distCenter = norm(center-sampleProj);
        sampleDir = sign(sampleProj(1)-center(1));
        respDir = sign(resp2(:,1)-center(1));
        evidence = (-1)^(find(respDir==sampleDir))*distCenter; % negative favors stim 1, positive favors stim 2
        
    case '3d'
        % example with 3 RFs
        resp3 = resp(:,[1 2 4]);
        center = mean(resp3,1);
        sampleResp = rand(1,3);
        
        m = diff(resp3,1);
        extreme(1,:) = center - m*10;
        extreme(2,:) = center + m*10;
        sampleProj = distance2curve(extreme, sampleResp);
        
        figure
        hold on
        plot3(resp3(:,1),resp3(:,2),resp3(:,3),'.');
        plot3(center(1),center(2),center(3),'.k')
        plot3(extreme(:,1),extreme(:,2),extreme(:,3),'.')
        plot3(sampleResp(1),sampleResp(2),sampleResp(3),'.r')
        plot3(sampleProj(1),sampleProj(2),sampleProj(3),'.r')
        grid on
        
        % in direction of stim 1 or stim 2?
        distCenter = norm(center-sampleProj);
        sampleDir = sign(sampleProj(1)-center(1));
        respDir = sign(resp3(:,1)-center(1));
        evidence = (-1)^(find(respDir==sampleDir))*distCenter; % negative favors stim 1, positive favors stim 2
end
disp(evidence)


