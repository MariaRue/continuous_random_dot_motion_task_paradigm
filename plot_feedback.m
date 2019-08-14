function plot_feedback(type, id, respMat, mean_coherence, coherence_frame, condition_vec, scrWidth, scrHeight)
% PURPOSE: This function plots feedback after either one block or all 
% blocks (depending on input parameters) in the form of a coherence and 
% mean_coherence graph overlaid with rectangles showing horizontal coherent
% motion periods, and markers for each type of response participant made
% (correct, incorrect, false positive, missed)
%
% Input:
%    type = flag, 1 if you want to display straight after a block, 2 if you
%             want to display at the end of all blocks
% 
% by Neb Jovanovic
% with thanks to Dr Jonathan Hadida for showing me how to optimise through
% indexing!

figure('Position', [0 0 scrWidth scrHeight]);
title('No condition_vec saved...');
colour = {[224/255 67/255 58/255], [71/255 219/255 64/255], [224/255 199/255 58/255], [66/255 221/255 245/255]};

if type == 1
    hold on;
    xlabel('Frame');
    ylabel('Coherence');

    MCi = mean_coherence{id};
    CFi = coherence_frame{id};

    nframe = size(MCi,1); % number of frames

    % draw the rectangles corresponding to trials
    absMC = abs(MCi);
    k_first = find( absMC(2:end) - absMC(1:end-1) > 0 );
    k_last = find( absMC(2:end) - absMC(1:end-1) < 0 );
    ntrial = numel(k_first);

    for j = 1:ntrial
        rectangle('Position', [k_first(j), -1.49, k_last(j)-k_first(j)+1, 3], ...
            'FaceColor', [235/255 235/255 235/255], 'LineStyle', 'none');
    end

    % find row numbers of responses in current block
    r_valid = find(~isnan(respMat{id}(:, 1)));
    nresp = numel(r_valid);
    for j = 1:nresp
        r6 = respMat{id}(r_valid(j), 6);
        r7 = respMat{id}(r_valid(j), 7);
        rectangle('Position', [r6, -1.49, 25, 3], ...
            'FaceColor', colour{r7+1}, 'LineStyle', 'none');
    end

    % plot the blue and red lines
    plot( 1:nframe, MCi, 'r' ); 
    plot( 1:nframe, CFi, 'b' );

    % set up titles
    switch id
        case 1
            ordinal = 'First';
        case 2
            ordinal = 'Second';
        case 3
            ordinal = 'Third';
        case 4
            ordinal = 'Fourth';
    end

    % another switch to construct title according to condition
    if ~isempty(condition_vec)
        switch condition_vec(id)
            case 1
                title({[ordinal ' block (frequent trials, ' ...
                    'short integration)'], ...
                    '(Press any key to continue with task)'});
            case 2
                title({[ordinal ' block (frequent ' ...
                    'trials, long integration)'], ...
                    '(Press any key to continue with task)'});
            case 3
                title({[ordinal ' block (rare trials, ' ...
                    'short integration)'], ...
                    '(Press any key to continue with task)'});
            case 4
                title({[ordinal ' block (rare trials, ' ...
                    'long integration)'], ...
                    '(Press any key to continue with task)'});
        end
    end

    % limit axes so graphs look nice
    axis([0, nframe, -1.5, 1.5]);
elseif type == 2
    for i = 1:4
        subplot(4,1,i); hold on;
        xlabel('Frame');
        ylabel('Coherence');

        MCi = mean_coherence{i};
        CFi = coherence_frame{i};

        nframe = size(MCi,1); % number of frames

        % draw the rectangles corresponding to trials
        absMC = abs(MCi);
        k_first = find( absMC(2:end) - absMC(1:end-1) > 0 );
        k_last = find( absMC(2:end) - absMC(1:end-1) < 0 );
        ntrial = numel(k_first);

        for j = 1:ntrial
            rectangle('Position', [k_first(j), -1.49, k_last(j)-k_first(j)+1, 3], ...
                'FaceColor', '#ebebeb', 'LineStyle', 'none');
        end

        % find row numbers of responses in current block
        r_valid = find(~isnan(respMat{i}(:, 1)));
        nresp = numel(r_valid);
        for j = 1:nresp
            r6 = respMat{i}(r_valid(j), 6);
            r7 = respMat{i}(r_valid(j), 7);
            rectangle('Position', [r6, -1.49, 25, 3], ...
                'FaceColor', colour{r7+1}, 'LineStyle', 'none');
        end

        % plot the blue and red lines
        plot( 1:nframe, MCi, 'r' ); 
        plot( 1:nframe, CFi, 'b' );

        % set up titles
        switch i
            case 1
                ordinal = 'First';
            case 2
                ordinal = 'Second';
            case 3
                ordinal = 'Third';
            case 4
                ordinal = 'Fourth';
        end

        % another switch to construct title according to condition
        if ~isempty(condition_vec)
            switch condition_vec(i)
                case 1
                    title([ordinal ' block (frequent trials, short integration)']);
                case 2
                    title([ordinal ' block (frequent trials, long integration)']);
                case 3
                    title([ordinal ' block (rare trials, short integration)']);
                case 4
                    title([ordinal ' block (rare trials, long integration)']);
            end
        end

        % limit axes so graphs look nice
        axis([0, nframe, -1.5, 1.5]);
    end
end
    

% add legend, including five fake plots so we can have a legend for the
% rectangles
h = zeros(5, 1);
h(1) = scatter(0,0,0.1,[0.9215 0.9215 0.9215], 'filled'); % gray (trials)
h(2) = scatter(0,0,0.1,[0.2784 0.8588 0.2510], 'filled'); % green (correct)
h(3) = scatter(0,0,0.1,[0.8784 0.2627 0.2275], 'filled'); % red (incorrect)
h(4) = scatter(0,0,0.1,[0.8784 0.7804 0.2275], 'filled'); % yellow (early)
h(5) = scatter(0,0,0.1,[0.2588 0.8667 0.9608], 'filled'); % cyan (missed)
legend('Coherence','Mean coherence', 'Trial', 'Correct', 'Incorrect', 'Early', 'Missed');

end