function [noise_Matrix] = n_makeNoise(ny,lay,p,amp,tfilter)

noise_Matrix = amp(lay)*randn(ny,length(p.tlist));
tkern = normpdf(p.tlist,0,tfilter);
tkern = tkern/norm(tkern);

for i = 1:ny
    noise_Matrix(i,:) = cconv2(squeeze(noise_Matrix(i,:)),tkern);
end

% noise = p.noiseamp*randn(1,length(p.tlist));
% tkern = normpdf(p.tlist,0,p.noisefilter_t);
% tkern = tkern/norm(tkern);
% cconv2(noise,tkern);