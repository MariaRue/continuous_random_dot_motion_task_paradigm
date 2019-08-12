function [ratios_subs_sess] = AR_extract_data(respMat, B, input_cohs, int_control)
% Input: 
%   respMat = response matrix from a loaded behaviour file
%   B = another matrix from a loaded behaviour file (has other variables)
%   cohs = list of coherences used in the trial under analysis
%   int_control = do we control for integration length? 0 no, 1 yes.

% Output: 
%    ratios_subs_sess = Array, containing coherence level, proportion leftward responses,
%                  proportion rightwards responses (for each coherence level)
%    FA = 4x1 cell, contains number of false alarms for each condition
%
% Neb Jovanovic, University of Oxford 2019

% set up coherences.
% NB. this is hard-coded, change it for your experiment/make it passed into
% function
if isempty(input_cohs)
    coherences = [-0.5 -0.4 -0.3 0.3 0.4 0.5];
else
    coherences = input_cohs;
end

% for all blocks...
for block = 1:4
    % the below variables (right_resp_tot, etc.) are just temporary so I
    % can move around things properly. You only care about the output of
    % this function, the ratios_subs_sess variable, which has everything you
    % need.
    
    % copy only responses to each side
    right_resp_tot{block} = respMat{block}( respMat{block}(:, 3) == 1, 1:7);
    left_resp_tot{block} = respMat{block}( respMat{block}(:, 3) == 0, 1:7);
    
    % now only those for CORRECT responses (i.e. responding to a
    % mean_coherence =/= 0) according to int_control variable, for BOTH
    % sides
    
    % NB. We look for responses in the first 3.5 seconds instead of the
    % first 3 seconds (the length of a short integration trial) because our
    % code has 50 frames (i.e. 0.5 seconds) of "flex" time after each
    % trial, during which if the subject responds, it still counts as
    % correct even though the trial is technically over. This is to account
    % for the behavioural reaction time (i.e. time taken to press the
    % button)
    
    if int_control == 0
        right_resp_corr{block} = respMat{block}( respMat{block}(:, 3) == 1 & ...
            respMat{block}(:, 5) == 1, 1:7);
        % do the same for leftward responses...
        left_resp_corr{block} = respMat{block}( respMat{block}(:, 3) == 0 & ...
            respMat{block}(:, 5) == 1, 1:7);
    elseif int_control == 1 % otherwise, truncate all long integrations after 3 seconds
        right_resp_corr{block} = respMat{block}( respMat{block}(:, 3) == 1 & ...
            respMat{block}(:, 5) == 1 & respMat{block}(:, 2) <= 3.5, 1:7);
        left_resp_corr{block} = respMat{block}( respMat{block}(:, 3) == 0 & ...
            respMat{block}(:, 5) == 1 & respMat{block}(:, 2) <= 3.5, 1:7);
    end
    
    % calculate amount of MISSED trials per block, required for total
    % trials denominator later. Since respMat doesn't save the mean 
    % coherence of missed blocks (oops) we'll have to figure it out using
    % B.mean_coherence and backtracking ~200 frames before each missed resp
    if int_control == 0
        idx_missed = find(respMat{block}(:, 7) == 3);
    elseif int_control == 1
        idx_missed = find(respMat{block}(:, 7) == 3 | (respMat{block}(:, 5) == 1 & ...
        respMat{block}(:, 2) > 3.5));
    end
    
    for g = 1:length(idx_missed)
        % infer the coherence of each missed trial by going back 200 frames
        % before "response" (i.e. miss) in B.mean_coherence
        found_trial_coh = B.mean_coherence{block}(respMat{block}(idx_missed(g), 6)-200, 1);
        % insert this in right/left_resp_tot (but flag it as a missed
        % response)
        switch found_trial_coh/abs(found_trial_coh)
            case -1 % left
                left_resp_tot{block}(end+1, :) = [NaN 0 0 found_trial_coh ...
                    0 B.mean_coherence{block}(respMat{block}(idx_missed(g), 6)) 3];
            case 1 % right
                right_resp_tot{block}(end+1, :) = [NaN 0 1 found_trial_coh ...
                    0 B.mean_coherence{block}(respMat{block}(idx_missed(g), 6)) 3];
        end
    end
    
    % calculate ratios for each coherence
    for current_coh = 1:length(coherences)
        % calculate amount of correct rightwards presses
        R = sum( right_resp_corr{block}( ...
            right_resp_corr{block}(:, 4) == coherences(current_coh), 5 ) );
        % same, for leftwards
        L = sum( left_resp_corr{block}( ...
            left_resp_corr{block}(:, 4) == coherences(current_coh), 5 ) );
        % calculate amounts of missed trials of each type for each coh.
        M_R = sum( right_resp_tot{block}( ...
            right_resp_tot{block}(:, 7) == 3 & ...
            right_resp_tot{block}(:, 4) == coherences(current_coh), 7 )-2 );
        M_L = sum( left_resp_tot{block}( ...
            left_resp_tot{block}(:, 7) == 3 & ...
            left_resp_tot{block}(:, 4) == coherences(current_coh), 7 )-2 );
        % now, for absolute coherences...
        RL_abs = 0;
        M_abs = 0;
        T = 1;
        T_R = L + R + M_R;
        T_L = L + R + M_L;
        if current_coh > length(coherences)/2
            RL_abs = R + sum( left_resp_corr{block}( ...
                left_resp_corr{block}(:, 4) == -coherences(current_coh), 5 ) );
            M_abs = M_R + sum( left_resp_tot{block}( ...
                left_resp_tot{block}(:, 7) == 3 & ...
                left_resp_tot{block}(:, 4) == -coherences(current_coh), 7 )-2 );
            T = RL_abs + M_abs;
        end
        % calculate denominators for our ratios (correct per side, missed
        % per side)
        % put everything together into ratios_subs_sess (first column is only an
        % indicator column, others are self-explanatory)
        ratios_subs_sess{block}(current_coh, 1) = R; % right presses
        ratios_subs_sess{block}(current_coh, 2) = L; % left presses
        ratios_subs_sess{block}(current_coh, 3) = M_R; % missed right presses
        ratios_subs_sess{block}(current_coh, 4) = M_L; % missed right presses
        ratios_subs_sess{block}(current_coh, 5) = R/T_R; % proportion correct right p.
        ratios_subs_sess{block}(current_coh, 6) = L/T_L; % proportion correct left p.
        ratios_subs_sess{block}(current_coh, 7) = M_R/T_R; % proportion misses right p.
        ratios_subs_sess{block}(current_coh, 8) = M_L/T_L; % proportion misses left p.
        ratios_subs_sess{block}(current_coh, 9) = RL_abs/T; % proportion correct per absolute coherence
        ratios_subs_sess{block}(current_coh, 10) = M_abs/T; % proportion misses per abs. coh.
    end
end

% set all NaNs to zero (otherwise, we break analysis later when we attempt
% to add ratios together). NaNs here just means the denominator is zero
% because there are no responses (e.g. everything has been missed)
for block = 1:4
    ratios_subs_sess{block}(isnan(ratios_subs_sess{block})) = 0;
end
%%% Transpose output so it resembles respMat (NB. the cell array bit--the
%%% rest, such as rows being coherences, is unchanged!)
ratios_subs_sess = ratios_subs_sess.';

end