function [p]=logist_PMF(x,param,pl)

% logistic function to fit PMF to behavioral data from a rdk task.
% function mainly used in data_simul to generate simulated data to check
% param recovery. 

% INPUT
% x  = vector with values for input in function
% pl = 1 if graph should be plotted 
% param - structure with fields: 

% b0   - compulsory 
% b1   - compulsory 


% These parameters influence stretching of PMF and horizontal shift of PMF 


% Maria Ruesseler, University of Oxford 2017 


e = exp(-(param.b0 + param.b1 .* x)); % first half of logistic function (
                            %part in brackets acts as linear function)

p = 1./(1+e); % second half of logistic function. Output is 
               %probability that a certain choice occurs at x. 

if pl
hold on 
plot(x,p,'-')
xlabel('stim difficulty')
ylabel('probability of choice')
end



end % function logist_PMF