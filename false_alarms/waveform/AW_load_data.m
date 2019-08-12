function [FA_waveforms] = AW_load_data(root, parts, interval)
% PURPOSE: This function returns a 4x2 cell array (condition x side), each
% cell being a Subjects x Frames array, such that each row of this array
% corresponds to the mean coherence_frame across sessions for each subject.
% We then use this output to calculate the overall mean per subject and
% plot that.

%%% PREPARE VARIABLES %%%
% FA_sessions_collated and FA_sessions_persub: cell arrays we use as
% intermediaries, must declare
FA_sessions_collated = cell(4, 2, length( parts) );
FA_waveforms = cell(4, 2);

% go through all subjects
for sub = 1:length( parts )
    % assign just for ease of coding
    subject = parts{sub, 1};
    sessions = parts{sub, 2};
    
    % make a string for ID, efficient later
    if subject < 100
        sub_str = ['sub0' num2str( subject )];
    else
        sub_str = ['sub' num2str( subject )];
    end

    % Load each session.
    for sess_idx = 1:length(sessions)
        % set up session string so we can create a filename to load
        % the participant's data (per session)
        if sessions(sess_idx) < 10
            sess_str = ['sess00' num2str( sessions(sess_idx) )];
        else
            sess_str = ['sess0' num2str( sessions(sess_idx) )];
        end
        % set filename to load
        fname_b = [sub_str '_' sess_str '_behav.mat'];
        if isfile([root fname_b])
            % load up each participant's relevant session files
            load([root fname_b]);
            % display success
            disp(['Data for ' sub_str ', ' sess_str ...
                ' succesfully loaded.']);
            
            % extract the measures we want
            input_data = AW_input_task_waveforms(respMat, B, interval);
            
            % create new variable, where we will order the data by
            % condition
            input_data_ordered = input_data;
            % figure out condition order in this session
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            % order data by condition (instead of "by block")
            for condition = 1:4
                for side = 1:2
                    input_data_ordered{condition, side} = ...
                        input_data{cond_order == condition, side};
                end
            end
            
            % ADD EACH SESSION'S DATA TO MASTER DATA VARIABLE.
            % This is where we collate all the data, and then extract an
            % average (mean) for each subject further down in the code.
            % (We order first, then collate due to debugging reasons.)
            for condition = 1:4
                for side = 1:2
                    transfer_block = input_data_ordered{condition, side}(:, :);
                    FA_sessions_collated{condition, side, sub}( end+1:end+size(transfer_block, 1), 1:size(transfer_block, 2) ) = ...
                        transfer_block;
                end
            end
        else
            error(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found where expected? Something is wrong with' ...
                ' your parts{} variable!']);
        end
    end
    
    % FIND MEAN PER SESSION, PER SUBJECT
    for condition = 1:4
        for side = 1:2
            % it's OK we use end+1 here because it happens only once per
            % subject loaded (and all subjects should be loaded as we
            % checked them before with scan_subs_sessions() in the master
            % script)
            FA_waveforms{condition, side}( end+1, 1:interval ) = ...
                mean( FA_sessions_collated{condition, side, sub}(:, :), 1 );
        end
    end
end

end