function AR_analyse_ratios(type, int_control, input_cohs, ids)
% PURPOSE: Analyses our data in a specific manner (gives psychometric
% functions). See 'Input' for details.
%
% Input
%   type = a vector containing which analyses you wish to perform, 
%          e.g. [1 3 5], where
%            1: proportion correct rightwards responses
%            2: proportion correct leftwards responses
%            3: proportion rightwards misses
%            4: proportion leftwards misses
%            5: proportion correct responses (collapsed across sides)
%            6: proportion misses (collapsed across sides)
%   int_control = control for integration length? (counts correct responses
%               to LONG integration trial periods after 3 seconds as 
%               misses)
%                 0: no
%                 1: yes
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
ratios_subs_matrix = AR_load_data(root, type, parts, coherences, int_control);

%%% PLOT DATA %%%
AR_plot_data(ratios_subs_matrix, type, coherences);

end