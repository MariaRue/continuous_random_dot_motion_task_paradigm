function [epochs_vec,coherent_incoherent_vector,coherences] = calculate_epoch_lengths(total_stim_epoch,totalframes,minframenum,maxframenum,stim_frames,onsets_occur,mean_iti_frames,cohlist)

% PURPOSE: This function calculates on which frames in a block coherent and
% incoherent motion is shown, as well as which mean coherence is used in
% each coherent motion period.
% NB. This can be (and is) also used for calculating which frames are part
% of vertical motion periods and which aren't (for control)

% Input: 
%          total_stim_epoch = total num of frames in which variable ITIs
%                             and constant coherent motion periods need to be defined (i.e.
%                             number of frames without pre-defined gaps incoherent motion at
%                             beginning and end of block)
%          totalframes = total frames per block 
%          minframenum = minimum frame number of incoherent motion between
%                        two coherent motion periods
%          maxframenum = maximum frame number of incoherent motion between
%                        two coherent motion periods
%          stim_frames = length in frames of coherent motion period 
%          onsets_occur = vector indicating first and last frame of
%                         total_stim_eoch in totalframe 
%          mean_iti_frames = mean number of frames of incoherent motion
%                             betweeen coherent motion periods 
%          cohlist = list of coherences used for coherent motion periods 

% Output: 
%       
         % epochs_vec = vector with diffeent ITIs frame lengths
         %                   used between coherent motion periods,
         %                   
         % coherent_incoherent_vector = each cell of this field has a vector as
         %                     long as total frames in block, out of 0s for incoherent
         %                     motion frames, and trial number for
         %                     coherent motion frames
         %                     e.g. 0 0 0 0 1 1 1 1 1 0 0 0 0 0 2 2 2 2
         %                     ... 
         % coherences = vector which contains shuffled
         %              coherences used for each trial/coherent motion period
         %              (i.e. = [-0.5000, 0.3000, -0.4000 etc.])
            
            
% Maria Ruesseler, University of Oxford 2018

% variable that tracks for how many more frames ITIs and stim periods can 
% be definded 
framesleft = total_stim_epoch;

% counter for index in epochs_vec 
i = 1; 

% first frame of interval in which we can define coherent and incoherent 
% motion
frame_id_start = onsets_occur(1);

coherent_incoherent_vector = zeros(totalframes,1); % see above - vector with 0s 
% for incoherent motion frames, trial number for coherent motion 

trial = 1; % count coherent motion periods 

% loop through intertrial periods while the first frame of a new period we 
% want to define is smaller than the last frame of total_stim_epochs - mean 
% itis frames and duration of coherent motion

while frame_id_start < onsets_occur(2)-mean_iti_frames-stim_frames && framesleft > 0
    % generate intertrial epoch
    interframe_frames_interval = maxframenum - minframenum; % calculate the actual interval possible of intertrial frames 

    if interframe_frames_interval <= 0
        keyboard; % give control to user, useful for debugging
    end
   
    % draw a random number from uniform distribution from that interval - 
    % this is the number of incohrent motion frames between two consecutive trials
    epochs_vec(i) = abs(randi(interframe_frames_interval,1,1) + minframenum); 
    
    frame_id_start = frame_id_start + epochs_vec(i)+1; % get first frame of next coherent motion period
    frame_id_stop = frame_id_start-1 + stim_frames; % and its last frame      
    % for this coherent motion period assign number of trial for each frame within tat period 
    coherent_incoherent_vector(frame_id_start:frame_id_stop) = ones(stim_frames,1) .* trial; 
    
    frame_id_start = frame_id_stop; % this is used to calculate first frame of next coherent motion period 
    trial = trial + 1; % increase number of coherent motion period
    
    framesleft = framesleft-epochs_vec(i)-stim_frames; % reduce number of intertrial frames left by the number we just drew
    i = i + 1; % update index counter for epochs vec 
end

% in case we "go over" our allowed number of frames, trunacate the excess
if framesleft <= 0
    [onset_last_stim] = find(coherent_incoherent_vector == trial-1,1,'first'); 
    epochs_vec(i-1) = epochs_vec(i-1) + framesleft; % (frames left is negative in that case so that number gets subtracted)
    % effectively delete the last trial, as we don't want trials which are
    % shorter than stim_frames (our preset value)
    coherent_incoherent_vector(onset_last_stim : end) = 0;
    totaltrials = trial -2; % -1 because we added + 1 after last trial in while loop 
else
    % last intertrial epoch is the one between last trial and end of block
    epochs_vec(i) =  totalframes - frame_id_stop; 
    totaltrials = trial-1; % -1 because we added + 1 after last trial in while loop 
end

%%% ASSIGN COHERENCES TO TRIALS %%%
% shuffle coherences for each trial 
% number of repetitions per coherence (on average)
num_repeats_coh = ceil(totaltrials/numel(cohlist));

% duplicate coherences accordingly 
coherence_matrix = repmat(cohlist,[num_repeats_coh,1]);

% shuffle indices of that matrix  
shuffled_idx = randperm(numel(coherence_matrix));

% shuffle coherences 
coherences = reshape(coherence_matrix(shuffled_idx),[numel(coherence_matrix),1]);
end % calculate_intertrial_epoch