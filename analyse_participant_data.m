function analyse_participant_data(type, ids)
% Input
%   type = what kind of analysis you want to perform
%            1: Correlate REACTION TIME vs. COHERENCE
%            2: Correlate PERFORMANCE vs. COHERENCE
%            3: Correlate MISSED vs. COHERENCE
%            4: 
% preallocate array for data from all participants
RPB = cell(1, 4*length(ids));
% set up figure (we are going to be plotting a lot)
figure;

% what do we want to plot?
switch type
    case 1 % correlation betw. COHERENCE and REACTION TIME
        % for every participant...
        for i = 1:length(ids)
            % make a string for ID, efficient later
            if ids(i) < 100
                sub_str = ['sub0' num2str(ids(i))];
            else
                sub_str = ['sub' num2str(ids(i))];
            end
            root = ['analysis/' sub_str '/'];
            % for every session per participant...
            for s = 1:11
                sess_str = ['sess0' num2str(s)];
                fname = [sub_str '_' sess_str '_behav.mat'];
                if isfile([root fname])
                    % load up each participant's relevant session file
                    load([root fname]);
                    % extract the measures we want
                    RPB = analyse_task_data(respMat, B);
                    % we now plot a scatter plot of each set of data (i.e. each
                    % block per participant--there are four plots, so all blocks
                    % get 
                    for n = 1:4
                        subplot(2, 2, n);
                        scatter(RPB{n}(:, 1), RPB{n}(:, 2));
                        % set axes
                        axis([0 0.7 0 500]);
                        % tell us what's been plotted
                        disp(['Plotted ' sub_str ', ' sess_str ', block ' num2str(n) '.']);
                        % hold on so same figure is used
                        hold on;
                    end
                else
                    disp(['Behavioural data for ' sub_str ', ' sess_str ...
                        ' not found in designated directory!']);
                end
            end
        end

        for i = 1:4
            % add least-squares linear regression line to scatter plots
            subplot(2, 2, i);
            xlabel('Coherence (unitless)');
            ylabel('Reaction time (frames)');
            lsline;
        end
%     case 2 % correlation betw. COHERENCE and PERFORMANCE
%         % again, for every participant...
%         for i = 1:length(ids)
%             % make a string for ID, efficient later
%             if ids(i) < 100
%                 sub_str = ['sub0' num2str(ids(i))];
%             else
%                 sub_str = ['sub' num2str(ids(i))];
%             end
%             root = ['analysis/' sub_str '/'];
%             % for every session per participant...
%             for s = 1:11
%                 sess_str = ['sess0' num2str(s)];
%                 fname = [sub_str '_' sess_str '_behav.mat'];
%                 if isfile([root fname])
%                     % load up each participant's relevant session file
%                     load([root fname]);
%                     % extract the measures we want
%                     RPB = analyse_task_data(respMat, B);
%                     % we now plot a scatter plot of each set of data (i.e. each
%                     % block per participant--there are four plots, so all blocks
%                     % get 
%                     for n = 1:4
%                         subplot(2, 2, n);
%                         scatter(RPB{n}(:, 1), RPB{n}(:, 3));
%                         % set axes
%                         axis([0 0.7 0 500]);
%                         % tell us what's been plotted
%                         disp(['Plotted ' sub_str ', ' sess_str ', block ' num2str(n) '.']);
%                         % hold on so same figure is used
%                         hold on;
%                     end
%                 else
%                     disp(['Behavioural data for ' sub_str ', ' sess_str ...
%                         'not found in designated directory!']);
%                 end
%             end
%         end
% 
%         for i = 1:4
%             % add least-squares linear regression line to scatter plots
%             subplot(2, 2, i);
%             xlabel('Coherence (unitless)');
%             ylabel('Reaction time (frames)');
%             lsline;
%         end
end

end