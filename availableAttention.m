function attAvail = availableAttention(t, span, attAvail0)

totalAtt = 1;
% span = 1000;
% attAvail0 = 0; % attention available at t=0

attAvail = min(totalAtt, attAvail0 + t/span);