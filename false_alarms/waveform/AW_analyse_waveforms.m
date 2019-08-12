function AW_analyse_waveforms(interval, ids)
% PURPOSE: This function presents the average coherence_frame waveform, per
% condition, across all subjects, in the INTERVAL frames leading up to each
% False Alarm (FA) that the participants have made.

% Input:
%    interval = frames leading up to each FA for which you want the
%                 waveform
%    ids = participant IDs whose data you wish to analyse (in the form of a
%            vector, e.g. [1, 7, 34:39])

% Output: 
%    None so far, just plots your data!

%%% PREPARE VARIABLES %%%
% root: self-explanatory, where we load the data from
root = ['C:\experiments\Maria_contin_motion\analysis\behav_synth\'];

%%% FIND AVAILABLE SUBJECT & SESSION FILES %%%
parts = scan_subs_sessions(ids);

%%% LOAD and ORDER DATA for EACH SUBJECT %%%
FA_waveforms = AW_load_data(root, parts, interval);

%%% PLOT DATA %%%
AW_plot_data(FA_waveforms, interval, parts);

end