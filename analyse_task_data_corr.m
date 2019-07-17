function [results_per_block] = analyse_task_data_corr(respMat, B)
% PURPOSE: Finds correlations between response time (in frames) and
% absolute coherence level
%
% Output:
%    results_per_block = 4x3 array. Each row corresponds to a different 
%    block. Column # and description:
%       1 = contains a two-column double of only correctly responded
%           RIGHTWARDS trials (first column is coherence, second is
%           reaction time in frames). 
%       2 = same, except for leftward trials.
%       3 = performance in block; a number (from 0 to 1) corresponding to
%           proportion correct responses for that block

% create variable containing results per block of each block
results_per_block = cell(4, 4);

%%% 1. CORRELATE CORRECT RESPONSE TIME WITH COHERENCE OF TRIAL %%%

%% Neb: make sure to discriminate between conditions! You are going i = 1:4
% here but make sure you return the condition for each block as well!
for i = 1:4 % for each block
    % set up variables
    absMCi = abs(B.mean_coherence{i});
    % find out when trials begin and their coherences.
    % first, index cells where mean coherence switches from 0 to non-zero,
    % and vice-versa (use this to figure out where trials are)
    k_first = find(absMCi(2:end) - absMCi(1:end-1) > 0);
    k_last = find(absMCi(2:end) - absMCi(1:end-1) < 0);
    % find mean coherences of each trial
    k_trials_and_cohs = [B.mean_coherence{i}(k_first+1), k_first, k_last];

    % find out when response made, then add to cell.
    % copy response frames and responses from respMat
    responses = respMat{i}( ~isnan(respMat{i}(:, 6)) , [3,5:7]);
    
    % combine trials to corresponding correct responses.
    % index movement trials both for left and right sides
    % (side 1 = right, 2 = left)
    for side = 1:2
        switch side
            case 1 % 'wards' variable is for rightwards trials
                wards = k_trials_and_cohs(k_trials_and_cohs(:, 1) > 0, 1:3);
                % index only correct responses
                corr_idx = find(responses(:, 1) == 1 & responses(:, 2) == 1);
            case 2 % otherwise, for leftwards trials
                wards = k_trials_and_cohs(k_trials_and_cohs(:, 1) < 0, 1:3);
                % index only correct responses
                corr_idx = find(responses(:, 1) == 0 & responses(:, 2) == 1);
        end
        % make last column be response time (in frames)
        wards(:, 4) = wards(:, 3) - wards(:, 2);
        % pre-allocate results array
        corr_trials_idx = 0; % count amount of correct responses in trials
        results = zeros(size(wards, 1), 2);
        for n = 1:size(wards, 1)
            for m = corr_idx.' % maybe optimise so it only looks at non-zeros?
                % when we find a correspondence between a correct response and a
                % rightwards trial, accounting for flex time (50 frames)
                if ( responses(m, 3) >= wards(n, 3) && responses(m, 3) <= wards(n, 3)+51 )
                    % add coherence to result array
                    results(n, 1) = wards(n, 1);
                    % add response time
                    results(n, 2) = wards(n, 4);
                    corr_trials_idx = corr_trials_idx + 1;
                    break % go to next loop iteration, since we've found a
                    % correct response
                else
                    % if the participant responded incorrectly, return a NaN
                    results(n, 1:2) = NaN;
                end
            end
        end
        % compile results into the output variable
        results_per_block{i, side} = results; 
    
    % find performance and compile into output variable
    results_per_block{i, 3} = sum(~isnan(results(:, 1)))/length(results);
    % find missed and put into output
    results_per_block{i, 4} = sum(isnan(results(:, 1)))/length(results);
end
    
end