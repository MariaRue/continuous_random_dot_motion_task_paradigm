function [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f)
% This function recalculates random dot positions after response during
% coherent motion period for reminder of this coherent motion period

% Input: S = stimulus structure, f, frame we are currently at, trial,
% coherent_motion_period we are in, and block we are in

% Output = updated S
if trial == 0 
    
else
 

   trial_num = S.blocks_shuffled{block}(f);
   
idx_begin_trial = find(S.blocks_shuffled{block} == trial_num,1,'first'); % get idx of first frame of this coherent motion epoch
frames_of_trial_displayed = f - idx_begin_trial + 1; % frames of coherent motion period that have been displayed so far

frames_trial_to_come = S.blocks_coherence_cells{block}(1) ;


idx_begin_of_incoherent = idx_begin_trial + S.block_coherent_cells{block}(1)+1; % calculate index of next incoherent frame
make_zero = length(f + 1 : idx_begin_of_incoherent)+1;
%S.block_coherent_cells{block}(1)-frames_of_trial; % calculate the number of frames that are left from trial/coh motion period




% set mean coherence to 0 for remaining coherence frames, and also update coherence_frame and dot positions xy with the correpsonding noise vectors  
S.xy{block}(:,:,f+1 : idx_begin_of_incoherent) =  S.xy_noise{block}(:,:,f+1 : idx_begin_of_incoherent);
S.mean_coherence{block}(f+1 : idx_begin_of_incoherent+1) = zeros(make_zero,1); % change the mean coherence for this length to 0
S.coherence_frame{block}(f+1 : idx_begin_of_incoherent+1) =  S.coherence_frame_noise{block}(f +1  : idx_begin_of_incoherent+1); % and get new coherences with mean 0 from randn distribution

% new start idx for noise for next time 

    
  end



end % function
