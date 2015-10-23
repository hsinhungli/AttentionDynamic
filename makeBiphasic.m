function g = makeBiphasic(t,k,n)

g = (k*t).^n .* exp(-k*t).*(1/factorial(n) - (k*t).^2 ./factorial(n+2));