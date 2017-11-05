function decisionEvidence = decodeEvidence(sampleResp, resp)

% rf = load(p.rf);
% resp = rf.resp;
a = 10^10; % amplitude of line extension

% project sample point onto line defined by stim 1 and stim 2 responses
center = mean(resp,1); % decision boundary
m = diff(resp,1); % slope
extreme(1,:) = center - a*m; % define extreme points on this line
extreme(2,:) = center + a*m;
sampleProj = distance2curve(extreme, sampleResp);

% make sure projection line was long enough to allow an orthgonal projection
if any(sampleResp>max(extreme)) || any(sampleResp<min(extreme))
%     warning('projection line is too short')
end

% determine direction and distance from decision boundary
distCenter = norm(center-sampleProj);
sampleDir = sign(sampleProj(1)-center(1));
respDir = sign(resp(:,1)-center(1));
% [~,idx] = max(center);
% sampleDir = sign(sampleProj(idx)-center(idx));
% respDir = sign(resp(:,idx)-center(idx));

% negative favors stim 1, positive favors stim 2
decisionEvidence = (-1)^(find(respDir==sampleDir))*distCenter; 