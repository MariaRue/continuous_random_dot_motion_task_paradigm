function [ratio_subs_matrix] = AR_load_data(root, type, parts, coherences, int_control)

% initialise sums variable for all participants. Each row corresponds to a
% different condition, each column to a different session, and the 3rd
% dimension to the amount of subjects loaded.
ratios_subs = cell( 4, length(parts) );
for c = 1:4*length(parts) ratios_subs{c} = zeros( 6, 10, 6 ); end
% same for means
ratios_subs_means = cell( 4, length(parts) );

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
                AR_extract_data(respMat, B, coherences, int_control);
            % create new variable, where we order the data by condition
            input_data_ordered = input_data;
            % figure out condition order (this is why we loaded
            % S...)
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            for n = 1:4
                % order data by condition, so that we know which
                % condition the data was from just by its row 
                % number (e.g. row 1 means it comes from
                % condition 1)
                input_data_ordered{n} = input_data{cond_order == n};
            end

            % SUMMING ACROSS SESSIONS
            for current_coherence = 1:length(coherences) % FOR all coherences...
                for condition = 1:4 % FOR all conditions...
                    % transfer each datum (including ratios) from subject's
                    % session file to the sum variable
                    for current_ratio = 1:10
                        % transfer!
                        ratios_subs{condition, sub}(current_coherence, current_ratio, sess) = ...
                            ratios_subs{condition, sub}(current_coherence, current_ratio, sess) + ...
                            input_data_ordered{condition}(current_coherence, current_ratio);
                    end
                end
            end
        else
            disp(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found in designated directory!']);
        end
    end
    
    % FIND MEAN PER SESSION, PER SUBJECT.
    for condition = 1:4
        for current_coherence = 1:length(coherences)
            ratios_subs_means{condition, sub}(current_coherence, 1:10) = ...
                mean( ratios_subs{condition, sub}(current_coherence, :, :), 3 );
        end
    end
end

% RESTRUCTURE STORAGE VARIABLE, and RETURN.
% Create storage variable (we *have* to do this because you can't use
% colons to sum across cells in a cell array... annoying) which we use to 
% find the mean later in the plotting function.
ratio_subs_matrix = cell(4, 1);
for condition = 1:4
    for current_coherence = 1:length(coherences)
        for sub = 1:length(parts)
            ratio_subs_matrix{condition}(current_coherence, sub, 1:10) = ...
                ratios_subs_means{condition, sub}(current_coherence, 1:10);
        end
    end
end

end