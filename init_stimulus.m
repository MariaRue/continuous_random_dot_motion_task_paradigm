function [S] = init_stimulus(S,discrete_trials,tconst,filter_on)
% PURPOSE: This function is the first of two required to calculate X-Y dot
% positions for the task. It has a simple purpose: it calls move_dots()
% (the second function) with different parameters depending on whether the
% task includes discrete or continuous trials, and then passes on the 
% relevant parameters to it, mainly fields of the S structure. 
% See move_dots() for the actual code which calculates X-Y positions.

% Input: 
%    S                   = stimulus descriptor (structure), containing 
%                            important fields that describe the task and 
%                            stimulus, such as the fixdot size, the list of 
%                            coherences and their order (imported from 
%                            'parameter.csv') and so forth
%    tconst              = structure containing fields relating to task 
%                            display and PTB, such as frame rate (really
%                            important for proper rendering!)
%    discrete_trials - 1 = discrete trials, 
%                      0 = continuous rdk
%                         (thus it is a flag as to which kind of trial we
%                           want to have)
%    filter_on ------- 1 = filtered white noise used for ITIs
%                            (intertrial intervals)
%                      0 = jumping step like stimulus used for ITIs
%
% Output:
%    S = only output, now contains fields for X/Y dot positions across all
%          trials, *for every frame* (these are used for rendering later).
%          Also has three other new fields:
%            mean_coherence, which describes the mean level of coherence 
%            for every block;
%            blocks_shuffled

% Maria Ruesseler, University of Oxford, 2018

if discrete_trials == 1 || discrete_trials == 2 % If we've selected for discrete trials
    for trial = 1:S.vp.totaltrials % calculate dot positions for each trial
        % Calculate xy position for *each* dot for *entire* block 
        % duration (coherent and incoherent periods)
        % (all this below is one giant function call)
        [xy,~,~,pre_incoh_mo_coh,~] = ... % Neb: ignored 'bl' output
        move_dots(discrete_trials,trial,S.discrete_stim_duration,S.ap_radius,...
        S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,S.pre_incoh_mo,...
        0,0,0,S.coherence_list,0,0, 0, S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
        tconst.framerate,S.vp.noise_amplitude,S.mean_duration,S.sd_duration,S.vp.noise_function, S.vp.stim_function);
        S.pre_incoh_mo_coh = pre_incoh_mo_coh; 
        
        %assign the xy coordinates to the S structure
        S.xy{trial} = xy;
    end
else % for continuous rdk 
    for block = 1:numel(S.vp.condition_vec) % loop through all blocks 
        % Calculate xy position for *each* dot for *entire* block 
        % duration (coherent and incoherent periods)
        % (all this below is one giant function call)
        [xy,coherence_frame,mean_coherence,~,blocks_shuffled] = ... % Neb: ignored 'pre' output
        move_dots(discrete_trials,0,S.totalframes_per_block,S.ap_radius,...
        S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,0,...
        S.mean_coherence{block},S.blocks_coherence_cells{block},...
        S.coherence_frame{block},0,S.ITIS_vec{block},S.block_coherent_cells{block},0,...
        S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
        tconst.framerate,S.vp.noise_amplitude,S.mean_duration, ...
        S.sd_duration,S.vp.noise_function, S.vp.stim_function, ...
        .8, 0, 20, 3, 120, 30, S.step);

        % assign the xy coordinates to the S structure
        S.xy{block} = xy;
        % here (continuous trials) we also assign these three variables
        % (see move_dots.m for explanation)
        S.mean_coherence{block} = mean_coherence;
        S.blocks_shuffled{block} = blocks_shuffled;
        S.coherence_frame{block} = coherence_frame;

        % copy mean coherence and actual coherence on each frame because we
        % alter them in stim present function 
        S.mean_coherence_org{block} = S.mean_coherence{block}; % mean coherence
        S.coherence_frame_org{block} = S.coherence_frame{block}; % actual coherence used, 
        % oscillates with sd around mean coherence 

        % Calculate a noise vector, used to create S.xy_noise (this is
        % because after a participant responds in the experiment, the dots
        % in the remaining frames of the block are replaced with noise,
        % i.e. coherent motion stops if there was any)
        noise_vec{block} = S.totalframes_per_block;

        % giant function call
        [xy,coherence_frame,mean_coherence] = ...
        move_dots(discrete_trials,0,S.totalnoise_frames{block},S.ap_radius,...
        S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,0,...
        S.mean_coherence_noise{block},S.blocks_coherence_cells{block},...
        S.coherence_frame_noise{block},0,noise_vec{block},S.block_coherent_cells{block},1,...
        S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
        tconst.framerate,S.vp.noise_amplitude,S.mean_duration, ...
        S.sd_duration,S.vp.noise_function, S.vp.stim_function, ...
        0, 0, 0, 0, 0, 0, 0);

        % assign positions to S.xy_noise
        S.xy_noise{block} = xy;
        % copy mean coherences and actual coherence on each frame because 
        % we alter them in stim present function
        S.mean_coherence_noise{block} = mean_coherence; 
        S.coherence_frame_noise{block} = coherence_frame; 
    end % loop through blocks
end % if discrete trials 

end % init stimulus
