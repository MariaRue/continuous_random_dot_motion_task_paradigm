function [epochs_vec,coherent_incoherent_vector,coherences] = calculate_vepoch_lengths(total_stim_epoch,totalframes,minframenum,maxframenum,stim_frames,onsets_occur,mean_iti_frames,cohlist)

% PURPOSE: This function is highly similar to (and derived from)
% calculate_epoch_lengths. It
% returns a variable which contains, for each frame, a variable as to
% whether the dots should move up or down during that frame, or whether
% that frame should contain incoherent motion (i.e. it's an ITI frame)
% NB. In this script, ITI means periods without vertical motion

% Input: 
%          total_stim_epoch = total num of frames in which variable ITIs
%                             and constant coherent motion periods need to 
%                             be defined (i.e. number of frames without 
%                             gaps of defined incoherent motion at
%                             beginning and end of block)
%          totalframes      = total frames per block 
%          minframenum      = minimum frame number of non-vertical motion
%                             in-between two vertical motion periods
%          maxframenum      = max frame number of non-vertical motion
%                             in-between two vertical motion periods
%          stim_frames      = *mean* length in frames of vertical motion 
%                             periods 
%          onsets_occur     = vector indicating first and last frame of
%                             total_stim_epoch in totalframe
%                             (onsets_occur(1) is first frame, (2) is last)
%          mean_iti_frames  = mean number of frames of incoherent motion
%                             betweeen coherent motion periods 
%          cohlist          = list of coherences used for coherent motion 
%                             periods 

% Output: 
%       
%     epochs_vec                 = vector. Contains the different ITI
%                                  lengths (in frames) between vertical 
%                                  motion periods
%     coherent_incoherent_vector = each cell of this field has a vector as
%                                  long as total frames in block, out of 0s
%                                  for incoherent motion frames, and trial 
%                                  number for coherent motion frames
%                                  e.g. 0 0 0 0 1 1 1 1 1 0 0 0 0 0 2 2 2 2
%                                  ... 
%     coherences                 = vector which contains shuffled
%                                  coherences used for each trial/coherent 
%                                  motion period
            
            
% Maria Ruesseler and Neb Jovanovic, University of Oxford 2018

framesleft = total_stim_epoch; % variable that tracks for how many more
% frames ITIs and vertical periods can be defined 

i = 1; % epochs_vec index (denotes each individual ITI length within it)

frame_id_start = onsets_occur(1); % first frame of interval in which we can define vertical and non-vertical motion

coherent_incoherent_vector = zeros(totalframes,1); % see above - sets up 
% vector with 0s for non-vertical motion frames, number denoting direction
% for vertical motion 

trial = 1; % count vertical motion periods 

%%% Defining frames which are within ITIs (incoherent motion) or vertical
%%% motion periods (will have either upwards or downwards motion) by
%%% looping through all ITIs
% More nerdily (pseudocode):
% loop through intertrial periods WHILE [the first frame of a new period we 
% want to define is before the last frame where we are allowed to
% have new periods [i.e. total_stim_epochs - mean ITI frames - duration of
% vertical periods] AND we have frames left in which we can define ITIs
% and/or vertical periods]
while frame_id_start < onsets_occur(2)-mean_iti_frames-stim_frames && framesleft > 0
    % calculate maximum length of ITI in frames (the actual ITI length will
    % be between 1 and that number, see below)
    interframe_frames_interval = maxframenum - minframenum; % calculate maximum length of ITI in frames 

    if interframe_frames_interval <= 0 % if the interval <= 0 (should never happen...)
        keyboard; % give control to user, useful for debugging
    end
   
    % Draw the actual number of non-vertical motion frames between two
    % consecutive trials from a uniform distribution (still must be at
    % least minframenum, though)
    % NB. This is the length *for the current ITI being calculated+added*
    epochs_vec(i) = abs(randi(interframe_frames_interval,1,1) + minframenum);
    % Neb: Why abs() tho? Surely all these numbers are positive
    
    % Also, draw a random number from a uniform distribution for the length
    % of this vertical motion period (Neb: maybe not needed?)
    % vert_period_frames = abs(randi(stim_frames, 1, 1);
    
    frame_id_start = frame_id_start + epochs_vec(i)+1; % get first frame of next vertical motion period
    frame_id_stop = frame_id_start-1 + stim_frames; % and its last frame
    % Neb: For this vertical motion period assign DIRECTION (up or down, 
    % chosen at random) for each frame within that period 
    % 1 = move downwards, 2 = move upwards
    coherent_incoherent_vector(frame_id_start:frame_id_stop) = ones(stim_frames,1) .* randi(2); 
    
    frame_id_start = frame_id_stop; % this is used to calculate first frame
                                    % of next vertical motion period 
    trial = trial + 1; % increase number of vertical motion periods we have
                       % gone through
    
    framesleft = framesleft - epochs_vec(i)-stim_frames; % reduce number of
    % intertrial frames left by the number we just drew
    i = i + 1; % update index counter for epochs_vec (we have just
    % calculated and added a new ITI)
    
end 

%%% If we've gone overboard (added more frames as ITIs than there are
%%% frames remaining in our block)
if framesleft <= 0
    %%% excise extra frames from
    [onset_last_stim] = find(coherent_incoherent_vector == trial-1,1,...
        'first'); % returns the index of the first non-zero (i.e. vertical)
                  % element in [coherent_incoherent_vector == trial-1]
                  % array, which is non-zero only in cells of 
                  % coherent_incoherent_vector which match trial-1
                  % (i.e. returns index of last trial in coh_incoh_vec)
                  % NB. Neb: Must fix this, I changed multiplication by trial to
                  % multiplication by randi(2) to mark vertical motion...
    epochs_vec(i-1) = epochs_vec(i-1) + framesleft; % excise the overflow 
    % frames from the length of the last ITI (frames_left is negative in
    % this case, so they get subtracted)
    coherent_incoherent_vector(onset_last_stim:end) = 0; % non-vertical
    % movement until remainder of block
    totaltrials = trial-2; % -1 because we added + 1 after last trial in while loop 
    % Neb: shouldn't above be trial-1 instead of -2?
else % i.e. both conditions of WHILE loop unsatisified
    % just add last ITI (one between last trial and end of block)
    epochs_vec(i) =  totalframes - frame_id_stop; 
    totaltrials = trial-1; % -1 because we added + 1 after last trial in while loop 
end

%%%%%%% Assign coherences to each trial period %%%%%%%%%%

% shuffle coherences for each trial 

% number of trials per coherence, rounded up (i.e. how much each coherence
% repeats)
num_repeats_coh = ceil(totaltrials/numel(cohlist));

% duplicate coherences accordingly 
coherence_matrix = repmat(cohlist,[num_repeats_coh,1]);

% shuffle indices of that matrix  
shuffled_idx = randperm(numel(coherence_matrix));

% shuffle coherences 
coherences = reshape(coherence_matrix(shuffled_idx),[numel(coherence_matrix),1]);
end % calculate_intertrial_epoch