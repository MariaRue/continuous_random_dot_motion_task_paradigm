function [S] = init_stimulus(S,discrete_trials,tconst,filter_on)
% This function creates sequences of xy dot positions for discrete trial
% version of rdk or continuous versions 

% Input: 
%       S = stimulus descriptor 
%       discrete_trials = flag, 1 = discrete trials, 0 = continuous rdk
%       filter_on = flag 1 if filtered white noise used for intertrial
%                   periods, 0 if jumping step like stimulus used for intertrialperiods
%       

        
% Output S = contains now fields for xy dot positions across entire session


% Maria Ruesseler, University of Oxford, 2018

if discrete_trials == 1 || discrete_trials == 2
  
    % calculate dot positions for each trial
    for trial = 1:S.vp.totaltrials
        
 
        [xy,~,~,pre_incoh_mo_coh,bl] = ...
    move_dots(discrete_trials,trial,S.discrete_stim_duration,S.ap_radius,...
            S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,S.pre_incoh_mo,...
            0,0,0,S.coherence_list,0,0, 0, S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
            tconst.framerate,S.vp.noise_amplitude,S.mean_duration,S.sd_duration,S.vp.noise_function, S.vp.stim_function);
        
        
        S.pre_incoh_mo_coh = pre_incoh_mo_coh; 
        
        S.xy{trial} = xy;  
    end
    
    
    
else % for continuous rdk 

for block = 1:numel(S.vp.condition_vec) % loop through all blocks 
 
    % calculate xy position for each dot for entire block duration 
[xy,coherence_frame,mean_coherence,pre,blocks_shuffled] = ...
    move_dots(discrete_trials,0,S.totalframes_per_block,S.ap_radius,...
            S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,0,...
           S.mean_coherence{block},S.blocks_coherence_cells{block},...
            S.coherence_frame{block},0,S.ITIS_vec{block},S.block_coherent_cells{block},0,...
            S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
            tconst.framerate,S.vp.noise_amplitude,S.mean_duration,S.sd_duration,S.vp.noise_function, S.vp.stim_function);

 S.xy{block} = xy; 
 S.mean_coherence{block} = mean_coherence; 
 S.blocks_shuffled{block} = blocks_shuffled; 
 S.coherence_frame{block} = coherence_frame; 

 
% copy mean coherenes and actual coherence on each frame because we alter
% them in stim present function 
S.mean_coherence_org{block} = S.mean_coherence{block}; % mean coherence
S.coherence_frame_org{block} = S.coherence_frame{block}; % actual coherence used, 
% oscillates with sd around mean coherence 

% calculate noise vector for replacing coherent motion after button press

noise_vec{block} = S.totalframes_per_block;

[xy,coherence_frame,mean_coherence] = ...
    move_dots(discrete_trials,0,S.totalnoise_frames{block},S.ap_radius,...
            S.vp.coherence_sd,S.vp.direction,S.step,S.Nd,0,...
            S.mean_coherence_noise{block},S.blocks_coherence_cells{block},...
            S.coherence_frame_noise{block},0,noise_vec{block},S.block_coherent_cells{block},1,...
            S.vp.passbandfreq, S.vp.stopbandfreq,S.vp.passrip,S.vp.stopbandatten,...
            tconst.framerate,S.vp.noise_amplitude,S.mean_duration,S.sd_duration,S.vp.noise_function, S.vp.stim_function);
        
        

 S.xy_noise{block} = xy; 
 S.mean_coherence_noise{block} = mean_coherence; 
 S.coherence_frame_noise{block} = coherence_frame; 
 
% copy mean coherenes and actual coherence on each frame because we alter
% them in stim present function 
% S.mean_coherence_org{block} = S.mean_coherence{block}; % mean coherence
% S.coherence_frame_org{block} = S.coherence_frame{block}; % actual coherence used, 



end % loop through blocks


end % if discrete trials 

end % init stimulus
