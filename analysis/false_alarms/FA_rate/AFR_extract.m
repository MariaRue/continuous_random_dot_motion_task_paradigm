function [input_FARs] = AFR_extract(respMat, B)
% PURPOSE: Extracts relevant data (false alarm rate per condition, as well
% as per condition and per ITI unit time) and returns it.
%
% Input: 
%   respMat = response matrix from a loaded behaviour file
%   B = another matrix from a loaded behaviour file (has other variables)
%
% Output: 
%    input_FARs = 4x1 (condition) cell array; within each cell,
%    first column = FA number in that condition, second column = ITI frames
%    in that condition, third column = total frames in that condition
%
% Neb Jovanovic, University of Oxford 2019

% initialise output variable
input_FHs = cell(4, 1);

% FOR all blocks...
for block = 1:4
    % Calculate amount of each type of 'response'.
    % We use these below to calculate the hit rate, and just copy the false
    % alarm rate.
    input_FARs{block}(1) = ... % FA number
        size( respMat{block}( respMat{block}(:, 7) == 2, 1:7), 1);
    input_FARs{block}(2) = ... % ITI frames
        sum( B.mean_coherence{block}(:) == 0 );
    input_FARs{block}(3) = ... % total frames
        length( B.mean_coherence{block} );
end

end
