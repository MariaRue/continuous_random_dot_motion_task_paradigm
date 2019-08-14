function [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f)
% This function recalculates random dot positions after response during
% coherent motion period for the remainder of the period

% Input: S = stimulus structure, f, frame we are currently at, trial,
% coherent_motion_period we are in, and block we are in

% Output = updated S
if trial == 0 
    % lol
else
    trial_num = S.blocks_shuffled{block}(f);

    idx_begin_trial = find(S.blocks_shuffled{block} == trial_num,1,'first'); % get idx of first frame of this coherent motion trial
    frames_of_trial_displayed = f - idx_begin_trial + 1; % frames of coherent motion period that have been displayed so far

    frames_trial_to_come = S.blocks_coherence_cells{block}(1) ;

    idx_begin_of_incoherent = idx_begin_trial + S.block_coherent_cells{block}(1)+1; % calculate index of next incoherent frame
    
    % now, calculate amount of frames from current one (in which 
    % participant has responded) to the beginning of the next ITI (i.e. 
    % incoherent motion)
    make_zero = length(f+1:idx_begin_of_incoherent)+1;
    
    % set mean coherence to 0 for remaining coherence frames, and also update coherence_frame and dot positions xy with the corresponding noise vectors  
    S.xy{block}(:,:,f+1:idx_begin_of_incoherent) = S.xy_noise{block}(:,:,f+1:idx_begin_of_incoherent); % here, we literally replace the remaining XY positions of our dots (i.e. remaining until the end of the block) with just the noise vector (totally random movement)
    S.mean_coherence{block}(f+1:idx_begin_of_incoherent+1) = zeros(make_zero,1); % change the mean coherence for this length to 0
    S.coherence_frame{block}(f+1:idx_begin_of_incoherent+1) = S.coherence_frame_noise{block}(f +1  : idx_begin_of_incoherent+1); % and get new coherences with mean 0 from randn distribution

    % new start idx for noise for next time 
end
end % function
