function [RTs_means_matrix] = ARts_load_data(root, parts, coherences)

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
                ARts_extract_data(respMat, coherences);
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
            reshaped_matrix = ...
                reshape( RTs_commons{current_coherence, condition, sub}(:, 1:2, :), [1, 2, numel(RTs_commons{current_coherence, condition, sub}(:, 1:2, :))/2]);
            RTs_means_matrix{condition}(current_coherence, 1:2, sub) = ...
                mean( reshaped_matrix, 3 );
        end
    end
end

% RESTRUCTURE STORAGE VARIABLE, and RETURN.
% Create storage variable (we *have* to do this because you can't use
% colons to sum across cells in a cell array... annoying) which we use to 
% find the mean later in the plotting function.
% RTs_means_matrix = cell(4, 1);
% for condition = 1:4
%     for current_coherence = 1:length(coherences)
%         for sub = 1:length(parts)
%             RTs_means_matrix{condition}(current_coherence, 1:2, sub) = ...
%                 ratios_subs_means{condition, sub}(current_coherence, 1:10);
%         end
%     end
% end

end