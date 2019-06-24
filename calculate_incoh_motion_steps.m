function [stim_vec] = calculate_incoh_motion_steps(epoch,sd_duration,mean_duration,sd_coherence,mean_coherence,ft, noise_amplitude, step_function)

% this function generates a stepping stimulus for incoherent or coherent
% motion periods for the continuous rdk task. There are several
% possibilities:
%                   1) The function creates a stepping stimulus with
%                   durations drawn from an exponential function and
%                   coherences drawing from a normal distribution with a
%                   specified mean. This allows steps to be drawn from the
%                   same exponential distribution for intertiral and trial
%                   periods but trial periods to have a mean that is
%                   smaller or greater than zero, whereas the mean for
%                   intertrial periods would always be zero.
%
%                   2) The function creates a stepping stimulus with
%                   durations drawn from a normal distribution with a
%                   specified mean and standard deviation. This is to allow
%                   for intertrial periods to have a different distribution
%                   of step times with a bigger standard deviation but the
%                   trials to have a similiar mean step time with a much
%                   narrower standard deviation. Unlike for the first
%                   optoin, the trial period consitst of one step only.


% Input:


% length of incoherent motion

% standard deviation for nnormal distribution from which we draw coherence
% levels for each jump

% mean jump length in number of frames

switch step_function
    
    case 'ExpStep'
        
        t = 0; % number of frames allocated to jumps
        % count duration before jumps
        count_d = 0;
        % while t <= frame length of incoherent motion, calculate new step length
        while  t < epoch
            % calculate duration before next jump occurs
            count_d = count_d + 1;
            duration(count_d) = round(exprnd(mean_duration));
            
            % update t
            t = t + duration(count_d);
        end
        stim_vec = zeros(sum(duration),1);
        start_idx = 1;
        for t = 1 : length(duration) % loop through steps and assign coherences
            coherence_values =  sd_coherence .* randn(1,1) + mean_coherence;
            
            stim_vec(start_idx : start_idx + (duration(t)-1)) = coherence_values .* ones(duration(t),1);
            
            start_idx = start_idx + duration(t);
            
        end % loop through steps and assign coherences
        %
        
        
        
    case 'NormStep'
        t = 0; % number of frames allocated to jumps
        % count duration before jumps
        count_d = 0;
        % while t <= frame length of incoherent motion, calculate new step length
        while  t < epoch
            % calculate duration before next jump occurs
            count_d = count_d + 1;
            duration(count_d) = round(sd_duration .* randn(1,1)+mean_duration);
            
            % update t
            t = t + duration(count_d);
        end % loop through epoch
        stim_vec = zeros(sum(duration),1);
        start_idx = 1;
        for t = 1 : length(duration) % loop through steps and assign coherences
            coherence_values =  sd_coherence .* randn(1,1) + mean_coherence;
            
            stim_vec(start_idx : start_idx + (duration(t)-1)) = coherence_values .* ones(duration(t),1);
            
            start_idx = start_idx + duration(t);
            
        end % loop through steps and assign coherences
        %
    case 'WhiteNoise'
        
        
         % generate random coherences with mean 0 for incoherent motion frame scaled by
    % standard - deviation for an incoherent motion period
    s_incoh = randn(epoch,1).* sd_coherence;
    
    % low pass filter this 
    incoh_filtered = filter(ft,s_incoh);
    

    
    % filter leads to a distortion of the sd so scale back to the original
    % value, this step also changes amplitude of noise 
    stim_vec = (sd_coherence*incoh_filtered/std(incoh_filtered)).* noise_amplitude;
        
        
        
    case 'SingleStim'  
        
        stim_vec = zeros(epoch,1) + mean_coherence; 
        
        
        
end % switch

stim_vec = stim_vec(1:epoch);
end % function

% sd = 0.2;
% coherence_values =  sd .* randn(50,1);
%
%
% for t =  1:50
% duration(t) = round(exprnd(30));
%
%
% end
%
% noise_vec = zeros(sum(duration),1);
% start_idx = 1;
% for t = 1 : 50;
%
%     noise_vec(start_idx : start_idx + (duration(t)-1)) = coherence_values(t);
%
%     start_idx = start_idx + duration(t);
%
% end
