function [loaded_data] = AFR_load_data(root, parts)
% PURPOSE: This function returns a 4x1 cell array (condition) each
% containing a (subjects x sessions) cell array, where each cell is a
% vector in the form of [HR, FA] where HR = hit rate, FA = false alarm.
% Thus we have an HR vs. FA value for each session, for each subject.
% 
% Input:
%    root = string, path from where we load our data
%    parts = array of participants with their IDs and available sessions
%    analysis = 0 for FA vs HR scatter-plot, 1 for freq/length ANOVA

%%% PREPARE VARIABLES %%%
FAR_array = cell( 4, length(parts) );
loaded_data = cell(4, 1);

%%% LOAD DATA %%%

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
            input_FARs = AFR_extract(respMat, B);
            
            % create new variable, where we will order the data by
            % condition
            input_FARs_ordered = input_FARs;
            % figure out condition order in this session
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            % order data by condition (instead of "by block")
            for condition = 1:4
                for side = 1:2
                    input_FARs_ordered{condition} = ...
                        input_FARs{cond_order == condition};
                end
            end
            
            % Add extracted data to FAR_array, our master variable
            for condition = 1:4
                FAR_array{condition, sub}(sess_idx, 1:3) = ...
                    input_FARs_ordered{condition}(1:3);
            end
        else
            error(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found where expected? Something is wrong with' ...
                ' your parts{} variable!']);
        end
    end
end

% Reshape FAR_array
% Find means per session, per subject
for condition = 1:4
    for sub = 1:length(parts)
        % find mean for all three variables (FA, ITI frames, total frames)
        loaded_data{condition}(end+1, 1:3) = ...
            mean( FAR_array{condition, sub}(:, 1:3), 1);
    end
end

end