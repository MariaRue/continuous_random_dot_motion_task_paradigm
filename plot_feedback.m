function plot_feedback(respMat, mean_coherence, coherence_frame, condition_vec)

figure
title('No condition_vec saved...');
for i = 1:4
    subplot(4,1,i);
    xlabel('Frame');
    ylabel('Coherence');
    % plot which bits are coherent motion periods
    % set up some variables first...
    start_frame = 2;
    end_frame = 2;
    last_frame_block_drawn = 1;
    % this FOR loop merely goes through all the frames, and draws
    % rectangles where mean_coherence is NOT zero (just makes it easier to
    % view when coherent motion periods occur--you could just
    % plot(S.mean_coherence) and save yourself the trouble, but that's more
    % difficult to view)
    for f = 2:size(mean_coherence{i}, 1)
        if mean_coherence{i}(f, 1) ~= 0 && mean_coherence{i}(f-1, 1) == 0
            start_frame = f; % find the first frame of each coherent motion block
        end
        if mean_coherence{i}(f, 1) == 0 && mean_coherence{i}(f-1, 1) ~= 0
            end_frame = f; % find the last frame of each coherent motion block
        end
        % draw a gray rectangle to show coherent motion periods, but
        % only if not drawn before
        if end_frame > start_frame && last_frame_block_drawn ~= end_frame
            rectangle('Position', [start_frame -1.49 end_frame-start_frame 3], 'FaceColor', '#ebebeb', 'LineStyle', 'none');
        end
    end
        %%% plot participant responses onto graph
    % find row numbers of responses in current block
    responses = find(~isnan(respMat{i}(:, 1)));
    % now assign colours for each response
    for k = 1:size(responses)
        switch respMat{i}(responses(k), 7)
            case 0 % wrong response during coherent motion
                rect_colour = '#e0433a'; % scarlet red
            case 1 % correct response during coherent motion
                rect_colour = '#47db40'; % emerald green
            case 2 % response during incoherent motion
                rect_colour = '#e0c73a'; % banana yellow
            case 3 % missed response
                rect_colour = '#42ddf5'; % ocean blue
            otherwise
                rect_colour = 'Error!';
        end
        % plot rectangles for each response, with corresponding colours
        rectangle('Position', [respMat{i}(responses(k, 1), 6) -1.49 12 3], 'FaceColor', rect_colour, 'LineStyle', 'none');
    end
    % plot the coherences
    hold on
    plot(coherence_frame{i});
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
    % plot the mean coherence over everything, makes it easier to
    % understand
    plot(mean_coherence{i});
    % add legend
    % limit axes so graphs look nice
    axis([0 inf -1.5 1.5]);
end

h = zeros(5, 1);
h(1) = scatter(NaN,NaN,NaN,[0.9215 0.9215 0.9215], 'filled'); % gray (trials)
h(2) = scatter(NaN,NaN,NaN,[0.8784 0.2627 0.2275], 'filled');
h(3) = scatter(NaN,NaN,NaN,[0.2784 0.8588 0.2510], 'filled');
h(4) = scatter(NaN,NaN,NaN,[0.8784 0.7804 0.2275], 'filled');
h(5) = scatter(NaN,NaN,NaN,[0.2588 0.8667 0.9608], 'filled');
legend('Coherence','Mean coherence', 'Trial', 'Incorrect', 'Correct', 'Early', 'Missed');
end
