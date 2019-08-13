function [parts] = scan_subs_sessions(ids)
% PURPOSE: Returns an Nx2 cell array, where the first column contains 
% subject ID, second column contains a vector composed of all the found
% sessions for these subjects

%%% INIT VARIABLES %%%
% parts: used to determine which participants' data is accessible, and
% which sessions each subject has
parts = cell(100, 2);

%%% MAIN CODE %%%
% loop through all given IDs, check if they're there
for subject = 1:length(ids)
    % how many sessions available
    if ids(subject) < 100
        sub_str = ['sub0' num2str(ids(subject))];
    else
        sub_str = ['sub' num2str(ids(subject))];
    end
    % for my comp root = ['c:\experiments\Maria_contin_motion\analysis\' sub_str '\'];
    root = ['C:\experiments\Maria_contin_motion\analysis\behav_synth\'];
    
    for session = 1:12
        % set up session string so we can create a filename to load
        % the participant's data (per session)
        if session < 10
            sess_str = ['sess00' num2str(session)];
        else
            sess_str = ['sess0' num2str(session)];
        end
        fname_b = [sub_str '_' sess_str '_behav.mat'];
        % assign both subject ID and sessions found to cell array
        if isfile([root fname_b])
            if isempty(parts{subject, 1})
                parts{subject, 1} = ids(subject);
            end
            % now sessions founds...
            parts{subject, 2} = [parts{subject, 2}, session];
        end
    end
end

% delete empty cells, and reshape cell array back into proper form
parts = parts( ~cellfun('isempty',parts) );
parts = reshape(parts, [length(parts)/2, 2]);

% and return!

end
