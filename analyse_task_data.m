function [results_per_block] = analyse_task_data(respMat, B)
% Output:
%    results_per_block = 4x2 array. Each row is a different block. 
%    First column contains a two-column
%    array of only correctly responded trials (first column is coherence,
%    second is reaction time in frames). Second column contains a number
%    (from 0 to 1) corresponding to proportion correct responses for that
%    block (i.e. performance).

% create variable containing results per block of each block
results_per_block = cell(4, 2);
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
    responses = respMat{i}( find(~isnan(respMat{i}(:, 6))) , [3,5:7]);
    
    % combine trials to corresponding correct responses.
    % index right-ward movement trials
    rightwards = k_trials_and_cohs(find(k_trials_and_cohs(:, 1) > 0), 1:3);
    % make last column be response time (in frames)
    rightwards(:, 4) = rightwards(:, 3) - rightwards(:, 2);
    % index only correct rightwards responses
    corr_idx = find(responses(:, 1) == 1 & responses(:, 2) == 1);
    
    % combine (recorded response times) with their respective (trial
    % coherences)
    % cohs_rts = NaN(size(corr_idx, 1), 2);
    % assign coherences (easy) - but do it at the end b/c it moves to 2nd
    % column
    % cohs_rts(1:size(rightwards, 1)) = rightwards(:, 1);
    % create response times array.
    % first, assign each response to the closest starting frame of a
    % coherent motion period
    % corr_resps = responses(corr_idx, 3); % correct responses array
    % rt_array = 
    
    % pre-allocate results array
    corr_trials_idx = 0; % count amount of correct responses in trials
    results = zeros(size(rightwards, 1), 2);
    for n = 1:size(rightwards, 1)
        for m = corr_idx.' % maybe optimise so it only looks at non-zeros?
            % when we find a correspondence between a correct response and a
            % rightwards trial, accounting for flex time (50 frames)
            if ( responses(m, 3) >= rightwards(n, 3) && responses(m, 3) <= rightwards(n, 3)+51 )
                % add coherence to result array
                results(n, 1) = rightwards(n, 1);
                % add response time
                results(n, 2) = rightwards(n, 4);
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
    results_per_block{i, 1} = results; 
    % find performance and compile into output variable
    results_per_block{i, 2} = sum(~isnan(results(:, 1)))/length(results);
end
    
end