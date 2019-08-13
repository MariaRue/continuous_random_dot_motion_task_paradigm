function AFR_analyse_FAR(ids)
% PURPOSE: This function presents the mean and distribution of the rate of
% false alarms (FA) per subject, per condition. It can also controls for
% length of intertrial intervals (because e.g. frequent trial conditions
% have much less time in which a subject could false alarm than rare trial
% conditions).

% Input:
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
loaded_data = AFR_load_data(root, parts);

%%% PLOT DATA %%%
AFR_plot_data(loaded_data, parts, 100);

end