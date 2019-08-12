function AFH_analyse_FA_HR(ids, analysis)
% PURPOSE: This function presents a scatterplot of FAs (false alarms) vs.
% HRs (hit rates) for each subject, for each session. It also presents the
% correlation between these.
% This function can also return an ANOVA analysis instead, if so specified.

% Input:
%    analysis = 0 for FA vs HR, 1 for ANOVA
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
loaded_data = AFH_load_data(root, parts, analysis);

%%% PLOT DATA %%%
AFH_plot_data(loaded_data, parts, analysis);

end