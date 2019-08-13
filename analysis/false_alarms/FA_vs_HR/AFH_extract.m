function [input_FHs] = AFH_extract(respMat)
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
input_FHs = cell(4, 1);

% FOR all blocks...
for block = 1:4
    % Calculate amount of each type of 'response'.
    % We use these below to calculate the hit rate, and just copy the false
    % alarm rate.
    incorrects = size( respMat{block}( respMat{block}(:, 7) == 0, 1:7), 1);
    corrects = size( respMat{block}( respMat{block}(:, 7) == 1, 1:7), 1);
    FAs = size( respMat{block}( respMat{block}(:, 7) == 2, 1:7), 1);
    missed = size( respMat{block}( respMat{block}(:, 7) == 3, 1:7), 1);
    
    % Calculate relevant ratios.
    % Note that 'hit rate' is the proportion of trials correctly responded
    % to, out of all trials, and thus it equals (corrects)/(corrects+
    % incorrects+missed)
    input_FHs{block} = [corrects/(corrects+incorrects+missed), FAs];
end

end
