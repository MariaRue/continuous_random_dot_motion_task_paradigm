function AFR_plot_data(loaded_data, parts, framerate)
% PURPOSE: This function simply scatterplots each (per subject, per
% session) [HR, FA] data point we have extracted from all the subject data.
% It then also computes a correlation.
%
% Input:

% set up colour key/value pairs, so it's easier... 
colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
    [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
plotColour = containers.Map(colourKeys, colourValues); 

figure('Name', "FA rates with SEM (uncontrolled and controlled)");
graph_titles = ["FAs per block second (SEM)", "FAs per ITI second (SEM)"];
ylabel_titles = ["FAs per second of block time", ...
    "FAs per second of intertrial time"];

for type = 1:2
    subplot(1, 2, type);
    % Plot functions.
    % First, set up labels.
    labels = categorical({ 'ITI_S, Length_S', 'ITI_S, Length_L', 'ITI_L, Length_S', 'ITI_L, Length_L'});
    labels = reordercats(labels, { 'ITI_S, Length_S', 'ITI_S, Length_L', 'ITI_L, Length_S', 'ITI_L, Length_L'});
    % Calculate means and SEMs
    for condition = 1:4
        relevant_time = ...
            mean( loaded_data{condition}(:, type+1), 1 )/framerate;
        FA_means(condition) = ...
            mean( loaded_data{condition}(:, 1), 1 )/relevant_time;
        error(condition) = std( (loaded_data{condition}(:, 1)/relevant_time) )/sqrt( length(parts) );
    end
    % And plot!
    bar(labels, FA_means);
    hold on;
    er = errorbar(labels, FA_means, error);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';
    hold on;
    % Label graphs and axes.
    title(graph_titles(type));
    ylabel(ylabel_titles(type));
end

hold off;

end
