function [FA_percond_waveform] = AW_input_task_waveforms(respMat, B, interval)
% Input: 
%   respMat = response matrix from a loaded behaviour file
%   B = another matrix from a loaded behaviour file (has other variables)
%   interval = how long we want our waveform to be (in frames)
%
% Output: 
%    FA_percond_waveform = 4x2 (condition x side) cell array, each cell
%    contains an (FA x interval)-sized array where each row is an FA (false
%    alarm) and the columns are all the frames leading up to the FA
%
% Neb Jovanovic, University of Oxford 2019

% initialise output variable
FA_percond_waveform = cell(4, 2);

% FOR all blocks...
for block = 1:4
    % create 1x1 matrix of false alarms for this block (column is the frame
    % of the false alarm).
    % First for leftward presses
    FA_matrix = respMat{block}( respMat{block}(:, 7) == 2 & respMat{block}(:, 3) == 0, 6 );
    
    % find waveforms
    % FOR each side
    for side = 1:2
        for response = 1:numel(FA_matrix)
            FA_frame = FA_matrix(response);
            if FA_frame < interval % if our first FA occurred before the full interval
                waveform = zeros(interval, 1);
                waveform(interval-FA_frame:interval) = B.coherence_frame{block}( interval-FA_frame:interval, 1 );
            else % otherwise, it doesn't matter
                waveform = B.coherence_frame{block}( FA_frame-interval:FA_frame-1, 1 );
            end
            % add this one waveform (from this FA, in this condition) to the
            % list of waveforms for this condition
            FA_percond_waveform{block, side}( end+1, 1:length(waveform) ) = waveform;
        end
        % Now, set this for rightward presses (will only be executed once
        % due to how the for loop is structured
        FA_matrix = respMat{block}( respMat{block}(:, 7) == 2 & respMat{block}(:, 3) == 1, 6 );
    end
end

end
