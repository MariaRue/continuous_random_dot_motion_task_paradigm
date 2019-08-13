function [RTs_means_matrix] = ARTS_load_data(root, normalised, parts, coherences)
    
% Input:
%    normalised - do we normalise RTs by subtracting each subject's overall
%    RT from their 

% initialise variable where we will contain RTs.
RTs_commons = cell( 6, 4, length(parts) );

% loop through every participant
for sub = 1:length( parts )
    % make a string for ID, efficient later
    if parts{sub, 1} < 100
        sub_str = ['sub0' num2str(parts{sub, 1})];
    else
        sub_str = ['sub' num2str(parts{sub, 1})];
    end
    
    % load data from each session per subject
    for sess = 1:6
        % set up session string so we can create a filename to load
        % the participant's data (per session)
        if sess < 10
            sess_str = ['sess00' num2str(sess)];
        else
            sess_str = ['sess0' num2str(sess)];
        end
        % set filename
        fname_b = [sub_str '_' sess_str '_behav.mat'];
        if isfile([root fname_b])
            % load up each participant's relevant session files
            load([root fname_b]);
            % display message
            disp(['Data for ' sub_str ', ' sess_str ...
                ' succesfully loaded.']);
            % extract the measures we want
            input_data = ...
                ARTS_extract_data(respMat, coherences);
            % create new variable, where we order the data by condition
            input_data_ordered = input_data;
            % figure out condition order (this is why we loaded
            % S...)
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            for block = 1:4
                for coherence = 1:length(coherences)
                    % order data by condition, so that we know which
                    % condition the data was from just by its row 
                    % number (e.g. row 1 means it comes from
                    % condition 1)
                    input_data_ordered{coherence, block} = ...
                        input_data{coherence, cond_order == block};
                end
            end

            % COLLATE RTs
            for coherence = 1:6
                for condition = 1:4
                    % transfer each session block into a common
                    % repository, from which we derive the per-session
                    % means later
                    transfer_block = input_data_ordered{coherence, condition}(:, 1:2);
                    RTs_commons{coherence, condition, sub}(end + 1:end + size(transfer_block, 1), 1:2, sess) = transfer_block;
                end
            end
        else
            disp(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found in designated directory!']);
        end
    end
    
    % FIND MEAN RT PER SESSION, PER SUBJECT, and COLLATE
    % We find the mean across both the (session) and (# responses)
    % dimension at the same time.
    for condition = 1:4
        for current_coherence = 1:length(coherences)
            for type = 1:2 % for both normal and log RTs...
            reshaped_matrix = ...
                reshape( RTs_commons{current_coherence, condition, sub}(:, type, :), [1, 1, numel(RTs_commons{current_coherence, condition, sub}(:, type, :))]);
            RTs_means_matrix{condition}(current_coherence, type, sub) = ...
                mean( reshaped_matrix, 3 );
            end
        end
    end
end


% IF NORMALISING, RESTRUCTURE STORAGE VARIABLE, and RETURN.
% Here, we simply subtract each subject's overall mean RT from each of
% their (per coherence, per condition) mean RTs. This is to diminish the
% effect of subjects who are faster (better) in general.
if normalised == 1
    for sub = 1:length(parts)
        overall_mean = 0;
        temporary_matrix = NaN(1);
        % calculate overall mean
        for condition = 1:4
            for coherence = 1:length(coherences)
                temporary_matrix(coherence, condition, 1:2) = ...
                    RTs_means_matrix{condition}(coherence, 1:2, sub);
            end
        end
        reshaped_matrix = reshape(temporary_matrix, ...
            [numel(temporary_matrix)/2, 2]);
        overall_mean = nanmean(reshaped_matrix, 1);
        % subtract overall from per coherence, per condition means
        for condition = 1:4
            for coherence = 1:length(coherences)
                RTs_means_matrix{condition}(coherence, 1:2, sub) = ...
                    RTs_means_matrix{condition}(coherence, 1:2, sub) - ...
                    overall_mean;
            end
        end
    end
end

end