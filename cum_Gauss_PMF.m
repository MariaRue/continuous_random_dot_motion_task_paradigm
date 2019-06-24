function [p] = cum_Gauss_PMF(xrange,param,pl)


% cummulative Gaussian error function used to fit PMFs.function mainly used 
% in data_simul to generate simulated data to check param recovery. 


% function is taken and adapted from basic_fitpsf_cdf.m from Nela Cicmil 


% INPUT: mean and sd from Gaussian 
%        pl = 0 or 1 - possibility to plot probabilities 
%        x  = vector with values for input in function
%    param  = structure with fields 
%        bo = mean of Gaussian 
%        b1 = sd of Gaussian 
 
% OUTPUT: p = probabilities (y) of function 
 

% Maria Ruesseler, University of Oxford, 2017



y = (xrange - param.b0)./param.b1; % first half of Gaussian norm. dist. function: y = (x - mu) / sigma.
%
% p : creating the norm. dist. function predicted values for all 'x' (dx) from the sd and
% means (probit) passed to this function by its caller function.
%

p = (erf(y/sqrt(2)) +1)/2;  % second half of Gaussian norm. dist. function: p = 1/2(1 + erf(y / sqrt(2) ) ).


if pl
hold on 
plot(xrange,p,'k-')
ylabel('probability')
xlabel('stim difficulty')
end


end % function cum_Gauss_PMF 