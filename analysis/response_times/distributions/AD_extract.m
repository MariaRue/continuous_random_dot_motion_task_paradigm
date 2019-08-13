function [input_RTs] = AD_extract(respMat)
% PURPOSE: Extracts relevant data (false alarm number and hit rate per
% session) and returns it.
%
% Input: 
%   respMat = response matrix from a loaded behaviour file
%   B = another matrix from a loaded behaviour file (has other variables)
%
% Output: 
%    FA_percond_waveform = 4x1 (condition) cell array, each cell
%    contains an [HR, FR] vector for that condition.
%
% Neb Jovanovic, University of Oxford 2019

% initialise output variable
input_RTs = cell(4, 1);

% FOR all blocks...
for block = 1:4
    % index for correct responses so we can take our RTs
    idx_responses = respMat{block}(:, 7) == 0 | respMat{block}(:, 7) == 1;
    % find RTs of responses
    input_RTs{block} = respMat{block}( idx_responses, 2 );
end

end
