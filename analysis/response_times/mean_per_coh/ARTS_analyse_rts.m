function ARTS_analyse_rts(variation, normalised, input_cohs, ids)
% PURPOSE: Plots mean RTs and log RTs per coherence, per condition. Also
% shows IQR or SEM, whichever preferred.
%
% Input
%   variation = do you want to see IQR (0) or error bars (1) ?
%   normalised = do we normalise for good subjects? (0 no, 1 yes)
%   input_cohs = leave [] if you want default, otherwise input your
%                coherences.
%   ids = vector which includes all the subjects you wish to study (e.g. if
%         you wish to study subjects 37 and 39-44, this should be 
%         [37,39:44])
% Output
%   nothing, just makes plots! (For now.)

%%% PREPARE VARIABLES %%%
% root: self-explanatory, where we load the data from
root = ['C:\experiments\Maria_contin_motion\analysis\behav_synth\'];

% coherences: which coherences we wish to extract data points from
if isempty(input_cohs)
    coherences = [-0.5 -0.4 -0.3 0.3 0.4 0.5];
else
    coherences = input_cohs;    
end

%%% FIND AVAILABLE SUBJECT & SESSION FILES %%%
parts = scan_subs_sessions(ids);

%%% LOAD and ORDER DATA for EACH SUBJECT %%%
RTs_means_matrix = ARTS_load_data(root, normalised, parts, coherences);

%%% PLOT DATA %%%
ARTS_plot_data(RTs_means_matrix, parts, variation, coherences);

end
