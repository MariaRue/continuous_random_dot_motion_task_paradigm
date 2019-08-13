function ARTS_plot_data(RTs_means_matrix, parts, variation, coherences)

% set up colour key/value pairs, so it's easier to call them when plotting
colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
    [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
plotColour = containers.Map(colourKeys, colourValues);

% set up titles
figure_name_vector = ["Respones times vs. coherence", ...
    "Log response times vs. coherence"];
titles_vector = ["Frequent trials, short integration", ...
    "Frequent trials, long integration", ...
    "Rare trials, short integration", ...
    "Rare trials, long integration"];
y_labels_vector = ["Response time (s)", "Log response time"];

% go through all kinds of plots
for current_kind = 1:2
    figure('Name', figure_name_vector(current_kind) );
    
    for condition = 1:4
        subplot(2, 2, condition);
        % how do we want to express the variation in the data?
        switch variation
            case 0 % set up IQRs
            iqr = NaN(6, 2);
                for coherence = 1:6
                    iqr(coherence, 1) = ...
                        quantile(RTs_means_matrix{condition}(coherence, current_kind, :), 0.25);
                    iqr(coherence, 2) = ...
                        quantile(RTs_means_matrix{condition}(coherence, current_kind, :), 0.75);
                end
                % plot IQR
                fill([coherences fliplr(coherences)], ...
                    [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                    plotColour('LightBlue'), 'LineStyle', 'none');
                hold on;
            case 1 % set up error bars
                error_bars = NaN(6, 1); % one for each coherence
                for coherence = 1:length(coherences)
                    % calculate error bar total length for each
                    % coherence
                    error_bars(coherence) = std( reshape( RTs_means_matrix{condition}(coherence, current_kind, :), [1, length(parts) ] ) )/sqrt( length(parts) );
                end
                % plot error bars
                errorbar(coherences, nanmean( RTs_means_matrix{condition}(:, current_kind, :), 3 ), error_bars(:)/2);
                hold on;
        end
        % plot mean
        plot(coherences, nanmean( RTs_means_matrix{condition}(:, current_kind, :), 3 ), 'Color', plotColour('Blue'), 'Marker', '*' );
        hold on;
        % set title
        title( titles_vector(condition) );
        % set axes
        axis([-.5 .5 0 .6/current_kind]);
        xlabel('Coherence (unitless)');
        ylabel( y_labels_vector(current_kind) );
    end
end

end