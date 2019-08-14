function synthesise_data(input_root, output_root, ids)
% PURPOSE: This function simply loads up per-subject stimulus files and
% copies any info which may be required for data analysis, but is not
% present in their behavioural files. We do this because stimulus files are
% quite large (due to XY positions) compared to behavioural files, so we 
% don't want to be loading them repeatedly every single time we want to
% analyse some data...

% Input
%   input_root = path to input files
%   output_root = path to output files
%   ids = vector, containing IDs of subjects whose files you want to merge

last_file_loaded = [];

% go through every subject
for i = 1:length(ids)
    % make a string for ID, efficient later
    if ids(i) < 100
        sub_str = ['sub0' num2str(ids(i))];
    else
        sub_str = ['sub' num2str(ids(i))];
    end
    
    % for all sessions...
    for s = 1:12
        % set up session string so we can create a filename to load
        % the participant's data (per session)
        if s < 10
            sess_str = ['sess00' num2str(s)];
        else
            sess_str = ['sess0' num2str(s)];
        end
        input_root_b = ['D:\data\EEG\' sub_str '\behaviour\']; % delete
        fname_b = [sub_str '_' sess_str '_behav.mat'];
        input_root_s = ['D:\data\EEG\' sub_str '\stim\']; % delete
        fname_s = [sub_str '_' sess_str '_stim.mat'];
        if isfile([input_root_b fname_b]) && isfile([input_root_s fname_s])
            % do we have the file loaded?
            if ~strcmp(last_file_loaded, [input_root_b fname_b])
                % load up each participant's relevant session files
                load([input_root_b fname_b]);
                load([input_root_s fname_s]);
                last_file_loaded = [input_root_b fname_b];
            end
            
            %%% DESIRED DATA FOR TRANSFER %%%
            % This is where you create a variable to which you add stuff from
            % the stimulus file, and then insert that variable into the
            % behaviour file (do it using structures is my suggestion)
            S_behav.block_ID_cells = S.block_ID_cells;

            % Save to session file
            savePath = [output_root fname_b];
            save(savePath, 'respMat', 'B', 'tconst', 'S_behav');
            disp(['Stimulus-derived data for ' sub_str ', ' sess_str ...
                ' succesfully transferred.']);
        else
            disp(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found in designated directory!']);
        end
    end
end

end