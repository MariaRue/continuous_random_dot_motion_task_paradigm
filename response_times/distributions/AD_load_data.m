function [RT_distribution] = AD_load_data(root, parts)
% PURPOSE: This function returns an (RTs x 2)-sized cell array, each
% row containing a response time from some subject (column 1) and its log
% (column 2).

%%% PREPARE VARIABLES %%%
% finish this

RT_distribution = cell(4, 1);
for condition = 1:4
    for subject=  1:size( parts, 1)
        % initialise the (session x 2)-sized cell arrays
        FA_HR_array{condition} = NaN( length(parts{subject, 2}), 2 );
    end
end

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
            input_RTs = AD_extract(respMat);
            
            % figure out condition order in this session
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            % order data by condition (instead of "by block")
            for condition = 1:4
                for side = 1:2
                    input_RTs_ordered{condition} = ...
                        input_RTs{cond_order == condition};
                end
            end
            
            % collate extracted data together
            for condition = 1:4
                transfer_block = input_RTs_ordered{condition};
                RT_distribution{condition}( ...
                    end+1:end+size(transfer_block, 1), : ) = ...
                    transfer_block;
            end
        else
            error(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found where expected? Something is wrong with' ...
                ' your parts{} variable!']);
        end
    end
end

end