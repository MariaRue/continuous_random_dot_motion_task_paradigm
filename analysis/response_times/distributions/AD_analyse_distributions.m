function AD_analyse_distributions(ids, bins)
% PURPOSE: This function presents the disribution of RTs as a histograms.

% Input:
%    ids = participant IDs whose data you wish to analyse (in the form of a
%            vector, e.g. [1, 7, 34:39])
%    bins = number of bins in histogram

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
AD_plot_data(RT_distribution, bins);

end
