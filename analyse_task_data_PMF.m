function [LR_cohs_PMF] = analyse_task_data_PMF(respMat, B)
% Output: Array, containing coherence level, proportion leftward responses,
% proportion rightwards responses (for each coherence level)
%
% Neb Jovanovic, University of Oxford 2019

% set up coherences.
% NB. this is hard-coded, change it for your experiment/make it passed into
% function
coh_list = [-0.5 -0.4 -0.3 0.3 0.4 0.5];

% for all blocks...
for i = 1:4
    % copy only those rows for TOTAL, RIGHTward responses
    right_resp_tot{i} = respMat{i}( respMat{i}(:, 3) == 1, 1:7);
    % now only those for CORRECT, RIGHTward responses (i.e. responding to a
    % mean_coherence =/= 0)
    right_resp_corr{i} = respMat{i}( respMat{i}(:, 3) == 1 & ...
        respMat{i}(:, 5) == 1, 1:7);
    % do the same for leftward responses...
    left_resp_tot{i} = respMat{i}( respMat{i}(:, 3) == 0, 1:7);
    left_resp_corr{i} = respMat{i}( respMat{i}(:, 3) == 0 & ...
        respMat{i}(:, 5) == 1, 1:7);
    
    % calculate proportion of right/left button presses per coherence.
    % first, set up coherence column so we know which row is which
    LR_cohs_PMF{i}(1:6, 1) = coh_list;
    % calculate amount of missed trials per block, required for total
    % trials denominator later. Since respMat doesn't save the mean 
    % coherence of missed blocks (oops) we'll have to figure it out using
    % B.mean_coherence and backtracking ~200 frames before each missed resp
    idx_missed = find(respMat{i}(:, 7) == 3);
    for g = 1:length(idx_missed)
        % infer the coherence of each missed trial by going back 200 frames
        % before "response" (i.e. miss) in B.mean_coherence
        found_trial_coh = B.mean_coherence{i}(respMat{i}(idx_missed(g), 6)-200, 1);
        % insert this in right/left_resp_tot (but flag it as a missed
        % response)
        switch found_trial_coh/abs(found_trial_coh)
            case -1 % left
                left_resp_tot{i}(end+1, :) = [NaN 0 0 found_trial_coh ...
                    0 B.mean_coherence{i}(respMat{i}(idx_missed(g), 6)) 3];
            case 1 % right
                right_resp_tot{i}(end+1, :) = [NaN 0 1 found_trial_coh ...
                    0 B.mean_coherence{i}(respMat{i}(idx_missed(g), 6)) 3];
        end
    end
    
    % calculate R/R+L+M and L/R+L+M, for each coherence (6 coherences in 
    % total here, NB. these were hard-coded above).
    for m = 1:6
        % calculate amount of correct rightwards presses
        R = sum( right_resp_corr{i}( ...
            right_resp_corr{i}(:, 4) == LR_cohs_PMF{i}(m, 1), 5 ) );
        % same, for leftwards
        L = sum( left_resp_corr{i}( ...
            left_resp_corr{i}(:, 4) == LR_cohs_PMF{i}(m, 1), 5 ) );
        % calculate amounts of missed trials of each type for each coh.
        M_R = sum( right_resp_tot{i}( ...
            right_resp_tot{i}(:, 7) == 3 & ...
            right_resp_tot{i}(:, 4) == LR_cohs_PMF{i}(m, 1), 7 )-2 );
        M_L = sum( left_resp_tot{i}( ...
            left_resp_tot{i}(:, 7) == 3 & ...
            left_resp_tot{i}(:, 4) == LR_cohs_PMF{i}(m, 1), 7 )-2 );
        % put everything together into LR_cohs_PMF (first column is only an
        % indicator column, others are self-explanatory)
        LR_cohs_PMF{i}(m, 2) = R; % right presses
        LR_cohs_PMF{i}(m, 3) = L; % left presses
        LR_cohs_PMF{i}(m, 4) = M_R; % missed right presses
        LR_cohs_PMF{i}(m, 5) = M_L; % missed right presses
        LR_cohs_PMF{i}(m, 6) = R/(R+L+M_R); % proportion correct right p.
        LR_cohs_PMF{i}(m, 7) = L/(R+L+M_L); % proportion correct left p.
        % NB. The output variable for 6 and 7 is X/T, where X is either R 
        % (amount of correct right responses) or L (amount of correct left
        % responses) for that coherence, and T is total trials for that 
        % coherence (i.e. R+L+M)
    end
end

%%% Transpose output so it resembles respMat, etc.
LR_cohs_PMF = LR_cohs_PMF.';

end