% sim_steadyState.m

dt = 1;
tau = 100;
a = 2; % sustained constant input
r(1) = 0;

for t = 2:1000
    r(t) = r(t-1) + dt/tau.*(-r(t-1) + a);
end

plot(1:1000, r)