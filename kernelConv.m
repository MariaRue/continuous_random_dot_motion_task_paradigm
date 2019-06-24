%%% this code is from Jill %%%


%t=0.01:0.01:(60*1); % frame times
t = 0 : 0.0167 : 120;
%coh = randn(length(t),1); % vector of coherence frame by frame - replace with the real one
coh = S.coherence_frame{1}(1:7186);

kernelDuration = 750; % number of frames in sliding window

%kernel = ones(kernelDuration,1); %uniform kernel
kernel = fliplr(exp(-(1/50)*[1:300])); % exponential decay; halflife in frames is the number on the bottom of the fraction
%kernel = normpdf(0:kernelDuration, kernelDuration/2, 25); %Gaussian kernel

kernel = kernel./sum(kernel); %make area under curve be 1

coh_conv = conv(coh,kernel,'same');

figure; plot(t,coh,'k');
hold on; plot(t,coh_conv,'r');