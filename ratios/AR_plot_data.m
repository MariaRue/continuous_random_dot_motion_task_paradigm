function AR_plot_data(ratios_subs_matrix, type, coherences)

% set up colour key/value pairs, so it's easier to call them when plotting
colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
    [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
plotColour = containers.Map(colourKeys, colourValues);

% set up titles
titles_vector = ["Frequent trials, short integration", ...
    "Frequent trials, long integration", ...
    "Rare trials, short integration", ...
    "Rare trials, long integration"];
y_labels_vector = ["Mean of R/(R+L+M_R)", "Mean of L/(R+L+M_L)", ...
    "Mean of M_R/(R+L+M_R)", "Mean of M_L/(R+L+M_L)", ...
    "Mean of R+L/(R+L+M_R+M_L)", "Mean of M_R+M_L/(R+L+M_R+M_L)"];

for current_kind = 1:length(type)
    figure;
    
    % set up temporary colour variable (just for plotting so the code isn't messy)
    if type(current_kind) == 1 || type(current_kind) == 2 || type(current_kind) == 5
        temp_colour{1} = plotColour('Blue');
        temp_colour{2} = plotColour('LightBlue');
    else
        temp_colour{1} = plotColour('Red');
        temp_colour{2} = plotColour('LightRed');
    end
    
    for condition = 1:4
        subplot(2, 2, condition);
        % set up IQRs
        iqr = NaN(6, 2);
        for coherence = 1:6
            iqr(coherence, 1) = ...
                quantile(ratios_subs_matrix{condition}(coherence, :, type(current_kind)+4), 0.25);
            iqr(coherence, 2) = ...
                quantile(ratios_subs_matrix{condition}(coherence, :, type(current_kind)+4), 0.75);
        end
        % plot variation (IQR, SEM, etc.) - here, IQR
        fill([coherences fliplr(coherences)], ...
            [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
            temp_colour{2}, 'LineStyle', 'none');
        hold on;
        % plot mean
        plot(coherences, mean( ratios_subs_matrix{condition}(:, :, type(current_kind)+4), 2 ), 'Color', temp_colour{1}, 'Marker', 's' );
        hold on;
        % set title
        title( titles_vector(condition) );
        % set axes
        if type(current_kind) < 5
            axis([-.5 .5 0 1]);
            xlabel('Coherence (unitless)');
        else
            axis([0.3 0.5 0 1]);
            xlabel('Absolute coherence (unitless)');
        end
        ylabel( y_labels_vector(type(current_kind)) );
    end
end

end