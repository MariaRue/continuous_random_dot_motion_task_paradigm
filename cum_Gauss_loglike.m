function [loglike] = cum_Gauss_loglike(x0,data);
% same as cum_Gauss_PMF, but returns loglikelihood for fminsearch
% parameter estimation 


%Input - param need to be given in vector x0, otherwise not compatible with
%fminsearch 

% data - matrix obtained with simul_data for example  

% Maria Ruesseler, Univeristy of Oxford 2017

param.b0 = x0(1);
param.b1 = x0(2);

coherences = unique(data(:,3));

n = zeros(length(coherences),1); % vector to save number of presentations per stimulus 
resp = zeros(length(coherences),1); % vector to save number of rightward choices per stimulus

for i = 1:length(coherences) % loop through coherences to dertermine number of presentations per stimulus and number of rightward choices
    
    n(i) = sum(data(:,3) == coherences(i));
    
    resp(i) = sum(data(:,3)== coherences(i) & data(:,2)==1);

end % loop through coherences to dertermine number of presentations per stimulus 



% coherences = (-50:10:50); % for practice functions only 


y = (coherences - param.b0)./param.b1; % first half of Gaussian norm. dist. function: y = (x - mu) / sigma.
%
% p : creating the norm. dist. function predicted values for all 'x' (dx) from the sd and
% means (probit) passed to this function by its caller function.
%

p = (erf(y/sqrt(2)) +1)/2;  % second half of Gaussian norm. dist. function: p = 1/2(1 + erf(y / sqrt(2) ) ).


q = 1-p; 

% cant take log of 0, common hack to use smalles number in matlab 
p(find(p<1e-20)) = 1e-20;
q(find(q<1e-20)) = 1e-20;

 
% for practice functions only 
% n = size(data,2);
% resp = sum(data,2)'; 

loglike = ((n-resp) .* log(q)) + (resp .* log(p));
loglike = -sum(loglike);







end