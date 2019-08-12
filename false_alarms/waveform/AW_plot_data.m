function AW_plot_data(FA_waveforms, interval, parts)
% PURPOSE: This function simply plots the mean and IQR of the mean per
% session waveforms (leading up to each FA) we got from each subject.
%
% Input:
%    FA_waveforms = 4x2 (condition x side) cell array, each cell contains
%                   mean per session waveforms for each subject (each row)
%    interval = number of frames leading up to FA we want to look at

% set up colour key/value pairs, so it's easier... 
colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
    [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
plotColour = containers.Map(colourKeys, colourValues); 

% plot the functions
for side = 1:2
    % create a figure for each side, set title
    if side == 1
        figure('Name', 'Leftwards responses');
    else
        figure('Name', 'Rightwards responses');
    end
    
    % plot all conditions in each figure
    for condition = 1:4
        subplot(2, 2, condition);
        
        % calculate IQRs (interquartile ranges)
        iqr = NaN(2, interval); % first row is 25% quartile, second is 75% quartile
        for n = 1:interval
            iqr(1, n) = quantile(FA_waveforms{condition, side}(:, n), 0.25);
            iqr(2, n) = quantile(FA_waveforms{condition, side}(:, n), 0.75);
        end
        
        % plot IQRs (as background fill) 
        fill([1:interval fliplr(1:interval)], ...
            [iqr(1, :) fliplr(iqr(2, :))], ...
            plotColour('LightBlue'), 'LineStyle', 'none');
        hold on;
        % plot mean
        plot(1:interval, mean( FA_waveforms{condition, side}(:, :), 1), ...
                '-', 'Color', 'Blue');
        % set and label axes
        if side == 1
            axis( [1 interval -0.6 0] );
        elseif side == 2
            axis( [1 interval 0 0.6] );
        end
        xlabel('Frame leading to FA (max = FA)');
        ylabel('Mean c_f per sub, mean per sess');
        
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
        
        % hold on for next
        hold on;
    end
end

end