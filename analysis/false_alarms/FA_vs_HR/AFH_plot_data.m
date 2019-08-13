function AFH_plot_data(loaded_data, parts, analysis)
% PURPOSE: This function simply scatterplots each (per subject, per
% session) [HR, FA] data point we have extracted from all the subject data.
% It then also computes a correlation.
%
% Input:
%    FA_HR_array = 4x1 (condition) cell array, each cell of which is a
%    (subjects x sessions)-sized cell array, each cell of which contains an
%    [HR, FA] vector, which are the data points we want.
%    parts = array of subjects, with their subject ID and available
%            sessions
%    analysis = 0 for FA vs HR scatter-plot, 1 for freq/length ANOVA

%%% ANALYSIS TYPE
if analysis == 0 % FA vs HR scatter-plot
    % set up colour key/value pairs, so it's easier... 
    colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
    colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
        [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
    plotColour = containers.Map(colourKeys, colourValues); 

    % set up figure
    figure('Name', 'False alarm vs. Hit rate');

    % plot the functions
    for condition = 1:4
        subplot(2, 2, condition);
        for subject = 1:size(parts, 1)
            for session = 1:length( parts{subject, 2} )
                scatter( loaded_data{condition, subject}(:, 1), ...
                    loaded_data{condition, subject}(:, 2) );
                hold on;
            end
        end

        % set and label axes
        axis( [0 1 0 40] );
        xlabel('Hit rate');
        ylabel('False alarms');

        % set subplot title
        switch condition
            case 1
                title('Frequent trials, short integration');
            case 2
                title('Frequent trials, long integration');
            case 3
                title('Rare trials, short integration');
            case 4
                title('Rare trials, long integration');
        end
    end
elseif analysis == 1 % two-way ANOVA
    [p, tbl] = anovan( loaded_data{3}(:), ...
        {convertStringsToChars(loaded_data{1}(:)) ...
        convertStringsToChars(loaded_data{2}(:))}, ...
        'model', 2, ...
        'varnames', {'Frequency', 'Length'} );
end

end
