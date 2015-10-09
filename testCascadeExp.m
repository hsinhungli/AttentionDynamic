% testExpCascade.m

p = setParametersTA;
p = initTimeSeriesTA(p);

attnGainI = ones(size(p.attI));
attnGainI(1,500:530) = 2;

%% separate vars
%     p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + attnGainI(:,idx-1));
%     p.h(:,idx) = p.h(:,idx-1) + (p.dt/p.tau_h)*(-p.h(:,idx-1) + halfExp(attnGainI-1,1));

p.attI1 = zeros(size(p.attI));
p.attI2 = zeros(size(p.attI));
p.attI3 = zeros(size(p.attI));
p.attI4 = zeros(size(p.attI));

for idx = 2:1000
    p.attI1(:,idx) = p.attI1(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI1(:,idx-1) + attnGainI(:,idx-1));
    p.attI2(:,idx) = p.attI2(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI2(:,idx-1) + p.attI1(:,idx));
    p.attI3(:,idx) = p.attI3(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI3(:,idx-1) + p.attI2(:,idx));
    p.attI4(:,idx) = p.attI4(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI4(:,idx-1) + p.attI3(:,idx));
    p.attI(:,idx) = p.attI(:,idx-1) + (p.dt/p.tau_attI)*(-p.attI(:,idx-1) + p.attI4(:,idx));
end

%% attI cascade loop
for idx = 2:1000
    p.attICascade(:,idx,1) = p.attICascade(:,idx-1,1) + (p.dt/p.tau_attI)*(-p.attICascade(:,idx-1,1) + attnGainI(:,idx-1)); % initialize with attnGainI driver
    for iC = 2:p.nAttICascades
        p.attICascade(:,idx,iC) = p.attICascade(:,idx-1,iC) + (p.dt/p.tau_attI)*(-p.attICascade(:,idx-1,iC) + p.attICascade(:,idx,iC-1));
    end
end
p.attI = p.attICascade(:,:,end);

figure
hold on
plot(p.attI')

%% h cascade loop
for idx = 2:1000
    p.hCascade(:,idx,1) = p.hCascade(:,idx-1,1) + (p.dt/p.tau_h)*(-p.hCascade(:,idx-1,1) + halfExp(attnGainI(:,idx-1)-1,1)); % initialize with attnGainI driver
    for iC = 2:p.nHCascades
        p.hCascade(:,idx,iC) = p.hCascade(:,idx-1,iC) + (p.dt/p.tau_attI)*(-p.hCascade(:,idx-1,iC) + p.hCascade(:,idx,iC-1));
    end
end
p.h = p.hCascade(:,:,end);

figure
hold on
plot(p.h')