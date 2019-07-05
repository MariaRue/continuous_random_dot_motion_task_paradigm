function [stim_vec] = calculate_coherence_vec(epoch, sd_duration, mean_duration, sd_coherence, mean_coherence, ft, noise_amplitude, step_function)

% PURPOSE: This function returns a vector, whose length equals the amounts 
% of frames passed to the function ('epoch' parameter), composed of "steps"
% (i.e. different lengths of frames) where each step has a different 
% coherence value (always between -1 and 1). It is used to generate
% such coherence vectors both for coherent left/right motion periods (i.e. 
% trials) *and* for incoherent motion periods (ITIs; remember that coherent
% motion can also happen in ITIs, it's just that the *mean* of the 
% coherence values over the ITI is 0). This is we have an 'epoch'
% parameter: an epoch can be a coherent motion period and/or an incoherent
% motion period.

% An example of the output:

% stim_vec = [-0.343 -0.343 -0.343 0.177 0.177 0.177 0.177 -0.981 ...]
%
% This would correspond to at least three steps: the first step is three
% frames long, each having a coherence of -0.343, and the second step is
% four frames long, each with a coherence of 0.177. The third step has a
% coherence of -0.981 and in this example, we can't see how long it is, but
% the real variable obviously has different steps of discrete and known
% length.

% This output is then used when rendering dots during a task. Remember, the
% coherence of dots always shifts (because of steps) from time to time; in
% coherent motion periods, it has some constant mean (e.g. 0.7 means 70% of
% dots are moving to the right) and in incoherent motion periods, there are
% small periods of coherence but their mean coherence is 0.

% Important: the step lengths and coherences can be be drawn from different 
% distributions depending on the step_function flag (see below).

% Input:

% epoch = length of incoherent motion periods in frames

% sd_duration = standard deviation of normal distribution from which we draw coherence
% levels for each jump (?)

% mean_duration = mean jump length in number of frames (?)
%
% sd_coherence = vector (?) of different standard deviations for each
%                  incoherent motion period
%
% mean_coherence =
%
% ft = filter object required for WhiteNoise flag (redundant now, no longer
% used?)
%
% noise_amplitude =
%
% step_function = string flag, as follows:
%                 if 'ExpStep': durations drawn from an exponential 
%                   function and coherences drawn from a normal 
%                   distribution with a specified mean. This allows steps 
%                   to be drawn from the same exponential distribution for 
%                   intertrial (ITI) and trial periods but trial periods to  
%                   have a mean that is smaller or greater than zero,  
%                   whereas the mean for ITIs would always be zero.
%                 if 'NormStep': durations drawn from a normal distribution 
%                   with a specified mean and standard deviation. This is 
%                   to allow for intertrial periods to have a different 
%                   distribution of step times with a bigger standard 
%                   deviation but the trials to have a similiar mean step 
%                   time with a much narrower standard deviation. Unlike 
%                   the first option, the trial periods consist of one step 
%                   only.

switch step_function
    case 'ExpStep'
        % min and max to truncate the distribution - hard-coded for now but
        % make these input arguments later!
        % Neb: shall I do this?
        min_duration = 5;
        max_duration = 100;
        % t is the number of frames allocated to "jumps". Here, it's the 
        % sum of individual samplings from an exponential distribution
        t = 0;
        % count duration before jumps (index for WHILE loop)
        count_d = 0;
        % while t <= frame length of incoherent motion, calculate new step length
        while  t < epoch
            % calculate duration before next jump occurs
            count_d = count_d + 1;
            % sample from exponential distribution with mean =
            % mean_distribution
            % NB. duration here is a variable, NOT the duration() function
            % used in MATLAB
            duration(count_d) = round(exprnd(mean_duration));
            % if duration is < min or > max, re-sample until otherwise
            while (duration(count_d) < min_duration) | (duration(count_d)...
                    > max_duration)
                duration(count_d) = round(exprnd(mean_duration));
            end
            % increase t by the sample from above
            % Neb: is this step useless, because in the FOR loop below, the
            % code resets t to 1? So we should just care about
            % sum(duration) anyway...
            t = t + duration(count_d);
        end
        
        % pre-allocate stim vector with zeroes, of length sum(duration)
        % i.e. t
        stim_vec = zeros(sum(duration),1);
        % index used for the first frame of each step within an ITI 
        % (incoherent motion period)
        start_idx = 1;
        % loop through steps and assign coherences
        for t = 1:length(duration)
            % determine which coherence value we will assign to this step
            % of incoherent motion
            coherence_value =  sd_coherence .* randn(1,1) + mean_coherence;
            
            % assign this coherence value to this step (NOT just this
            % frame, but all frames within the step)
            stim_vec(start_idx:start_idx + (duration(t)-1)) = coherence_value .* ones(duration(t),1);
            
            % update index so we can assign a difference coherence to the
            % next step in the next iteration of this FOR loop
            start_idx = start_idx + duration(t); 
        end
    case 'NormStep'
        % this CASE is highly similar to the above one, just uses a normal
        % distribution rather than exponential
        t = 0; % number of frames allocated to jumps
        % count duration before jumps
        count_d = 0;
        % while t <= frame length of incoherent motion, calculate new step length
        while  t < epoch
            % calculate duration before next jump occurs
            count_d = count_d + 1;
            duration(count_d) = abs(round(sd_duration .* randn(1,1)+mean_duration));
            
            % update t
            t = t + duration(count_d);
        end % loop through epoch
        stim_vec = zeros(sum(duration),1);
        start_idx = 1;
        for t = 1 : length(duration) % loop through steps and assign coherences
            coherence_value =  sd_coherence .* randn(1,1) + mean_coherence;
            
           
            stim_vec(start_idx : start_idx + (duration(t)-1)) = coherence_value .* ones(duration(t),1);
            
            start_idx = start_idx + duration(t);
            
    end % loop through steps and assign coherences
    % old code below, unused currently
%     case 'WhiteNoise'
%         % generate random coherences with mean 0 for incoherent motion frame scaled by
%         % standard - deviation for an incoherent motion period
%         s_incoh = randn(epoch,1).* sd_coherence;
% 
%         % low pass filter this 
%         incoh_filtered = filter(ft,s_incoh);
% 
%         % filter leads to a distortion of the sd so scale back to the original
%         % value, this step also changes amplitude of noise 
%         stim_vec = (sd_coherence*incoh_filtered/std(incoh_filtered)).* noise_amplitude;
%     case 'SingleStimDuration'  
%         stim_vec = zeros(epoch,1) + mean_coherence; 
%     case 'changingStimDuration'
%         epoch = abs(round(sd_duration .* randn(1,1)+mean_duration)); 
%         stim_vec = zeros(epoch,1) + mean_coherence; 
%           
end

% trim output to length of ITI only, as sometimes algorithm may produce too
% many frames (?)
stim_vec = stim_vec(1:epoch);

end % function

