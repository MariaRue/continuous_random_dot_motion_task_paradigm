function AD_analyse_distributions(type, ids)
% PURPOSE: This function presents the disribution of RTs, i.e. the amount
% of a bin of RTs (in bins of bin_width) vs. each bin.

% Input:
%    type = 0 for normal RTs, 1 for log RTs
%    ids = participant IDs whose data you wish to analyse (in the form of a
%            vector, e.g. [1, 7, 34:39])

% Output: 
%    None so far, just plots your data!

%%% PREPARE VARIABLES %%%
% root: self-explanatory, where we load the data from
root = ['C:\experiments\Maria_contin_motion\analysis\behav_synth\'];

%%% FIND AVAILABLE SUBJECT & SESSION FILES %%%
parts = scan_subs_sessions(ids);

%%% LOAD DATA (RTs) from all SUBJECTS %%%
RT_distribution = AD_load_data(root, parts);

%%% PLOT DATA %%%
AD_plot_data(RT_distribution, type);

end