function [loaded_data] = AFH_load_data(root, parts, analysis)
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
% We only require one variable initialisation, FA_HR_array (our output
% variable). It's a (4 x subjects)-sized cell array, and each cell contains
% a (subjects x 2)-sized array that holds the HR and FA (one in each
% column) for each subject (row).
if analysis == 0
    FA_HR_array = cell(4, size( parts, 1) );
    for condition = 1:4
        for subject=  1:size( parts, 1)
            % initialise the (session x 2)-sized cell arrays
            FA_HR_array{condition} = NaN( length(parts{subject, 2}), 2 );
        end
    end
elseif analysis == 1
    % setup output variable
    freq_cond_anova = cell(1, 3);
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
            input_FHs = AFH_extract(respMat);
            
            % create new variable, where we will order the data by
            % condition
            input_FHs_ordered = input_FHs;
            % figure out condition order in this session
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            % order data by condition (instead of "by block")
            for condition = 1:4
                for side = 1:2
                    input_FHs_ordered{condition} = ...
                        input_FHs{cond_order == condition};
                end
            end
            
            % IF we want an FA vs. HR scatterplot...
            if analysis == 0
                % Add extracted data to FA_HR_array, our master variable, by
                % reshaping into the proper form first (go from [HR, FA] cells
                % into two columns, one for HR, one for FA)
                for condition = 1:4
                    FA_HR_array{condition, sub}(sess_idx, 1:2) = ...
                        reshape( input_FHs_ordered{condition}, [1, 2]);
                end
            elseif analysis == 1
                % Collate extracted data to our master variable for ANOVA
                % analysis
                for condition = 1:4
                    FA_number = input_FHs_ordered{condition}(1, 2);
                    freq = "Common";
                    cond_length = "Short";
                    % change variables if needed
                    if condition == 1 | condition == 3
                        cond_length = "Long";
                    else
                        freq = "Rare";
                    end
                    % finally, transfer variables
                    freq_cond_anova{1}(end+1, 1) = freq;
                    freq_cond_anova{2}(end+1, 1) = cond_length;
                    freq_cond_anova{3}(end+1, 1) = FA_number;
                end
            end
        else
            error(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found where expected? Something is wrong with' ...
                ' your parts{} variable!']);
        end
    end
end

% set output variable
if analysis == 0 % if want FA vs. HR
    loaded_data = FA_HR_array;
elseif analysis == 1
    % create relevant table
    data_table = table(freq_cond_anova{1}(:), ...
        freq_cond_anova{2}(:), freq_cond_anova{3}(:), ...
        'VariableNames', {'freq', 'length', 'FA_number'} );
    %% continue here.
    % set up factors (for the function after)
    % factors = table(
    % fit rm model
    rm = fitrm(data_table, 'FA_number~freq*length', 'WithinDesign', );
    loaded_data = freq_cond_anova;
end

end