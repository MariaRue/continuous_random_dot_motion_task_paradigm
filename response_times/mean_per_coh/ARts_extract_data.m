function [RTs_matrix] = ARts_extract_data(respMat, cohs)
% Output: 6x1 (for each coherence) cell, each is a 4x1 (for each block)
% cell, which contains rows for all the responses in that coherence level
% (whether correct or not)
%
% Neb Jovanovic, University of Oxford 2019

% set up coherences.
% NB. this is hard-coded, change it for your experiment/make it passed into
% function
if isempty(cohs)
    coh_list = [-0.5 -0.4 -0.3 0.3 0.4 0.5];
else
    coh_list = cohs;
end

% set up output variable (6x1 cell for each coherence, each coherence is
% 4x1 cell for each block)
RTs_matrix = cell(length(coh_list), 4);

% FOR all coherences...
for coherence = 1:length(coh_list)
    % FOR all blocks...
    for block = 1:4
        % transfer all the relevant data from respMat (response time x2,
        % choice, direction, and correctness)
        transfer_block = respMat{block}( respMat{block}(:, 4) == coh_list(coherence), [2,2,3,5,4]);
        RTs_matrix{coherence, block}(end + 1:end + size(transfer_block, 1), 1:5) = transfer_block;
        % modify the 2nd column so that it's the decimal logarithm of
        % itself (this is why we transferred the response time twice)
        RTs_matrix{coherence, block}(:, 2) = log(RTs_matrix{coherence, block}(:, 2));
    end
end

end