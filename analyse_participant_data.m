function analyse_participant_data(type, ids)
% Input
%   type = what kind of analysis you want to perform
%            1: Correlate REACTION TIME vs. COHERENCE
%            2: Correlate PERFORMANCE vs. COHERENCE
%            3: Correlate MISSED vs. COHERENCE
%            4: 
% Output
%   nothing, just makes plots! (For now.)
% preallocate array for data from all participants
LR_cohs_PMF = cell(1, 4*length(ids));
% use this var so we don't have to waste time re-loading what we have
last_file_loaded = [''];

% initialise sums variable for all participants. Each row corresponds to a
% different coherence (from -.5 to .5 here)
sums = cell(6, 2);
sums{1, 1} = [-0.5]; sums{2, 1} = [-0.4]; sums{3, 1} = [-0.3]; 
sums{4, 1} = [0.3]; sums{5, 1} = [0.4]; sums{6, 1} = [0.5]; 
for i = 1:6; sums{i, 2} = NaN(7, max(ids)); end

% index used just before plotting to know how many subjects we have
% successfully loaded (need it to calculate means of ratios)
idx_parts = 0;

% loop through every participant
for i = 1:length(ids)
    % make a string for ID, efficient later
    if ids(i) < 100
        sub_str = ['sub0' num2str(ids(i))];
    else
        sub_str = ['sub' num2str(ids(i))];
    end
    root = ['analysis/' sub_str '/'];
    % what do we want to plot?
    switch type
        case 1 % PMF betw. COHERENCE and PROPORTION PRESSED RIGHT (->) BUTTON
            % for every session per participant...
            for s = 1:11
                % set up session string so we can create a filename to load
                % the participant's data (per session)
                sess_str = ['sess0' num2str(s)];
                fname_b = [sub_str '_' sess_str '_behav.mat'];
                fname_s = ['C:\experiments\Maria_contin_motion\stim\' sub_str '\' sub_str '_' sess_str '_stim.mat'];
                if isfile([root fname_b]) && isfile([fname_s])
                    % do we have the file loaded?
                    if ~strcmp(last_file_loaded, [root fname_b])
                        % load up each participant's relevant session files
                        load([root fname_b]);
                        load([fname_s]);
                        last_file_loaded = [root fname_b];
                    end
                    % extract the measures we want
                    LR_cohs_PMF = analyse_task_data_PMF(respMat, B);
                    % create new variable, where we will order the data by
                    % condition
                    LR_cohs_PMF_ordered = LR_cohs_PMF;
                    % figure out condition order (this is why we loaded
                    % S...)
                    cond_order = cellfun(@str2num, S.block_ID_cells);

                    for n = 1:4
                        % order data by condition...
                        LR_cohs_PMF_ordered{n} = LR_cohs_PMF{cond_order == n};
                    end
                    
                    % begin summing
                    for n = 1:6
                        for block = 1:4
                            % make zeros first if NaN...
                            if isnan(sums{n, 2}(1, ids(i)))
                                sums{n, 2}(1:5, ids(i)) = 0;
                            end
                            % R, L, M_R and M_L and T (total i.e. correct +
                            % incorrect + missed) responses
                            sums{n, 2}(1,ids(i)) = sums{n, 2}(1,ids(i)) + LR_cohs_PMF_ordered{block}(n, 2); % R
                            sums{n, 2}(2,ids(i)) = sums{n, 2}(2,ids(i)) + LR_cohs_PMF_ordered{block}(n, 3); % L
                            sums{n, 2}(3,ids(i)) = sums{n, 2}(3,ids(i)) + LR_cohs_PMF_ordered{block}(n, 4); % M_R
                            sums{n, 2}(4,ids(i)) = sums{n, 2}(4,ids(i)) + LR_cohs_PMF_ordered{block}(n, 5); % M_L
                            sums{n, 2}(6,ids(i)) = sums{n, 2}(1,ids(i))/(sums{n, 2}(1,ids(i)) + sums{n, 2}(2,ids(i)) + sums{n, 2}(3,ids(i))); % R/(R+L+M_R)
                            sums{n, 2}(7,ids(i)) = sums{n, 2}(2,ids(i))/(sums{n, 2}(1,ids(i)) + sums{n, 2}(2,ids(i)) + sums{n, 2}(4,ids(i))); % L/(R+L+M_L)
                            idx_parts = idx_parts + 1;
                        end
                        sums{n, 2}(5,ids(i)) = sum(sums{n, 2}(1:4, ids(i))); % T
                    end
                else
                    disp(['Behavioural data for ' sub_str ', ' sess_str ...
                        'not found in designated directory!']);
                end
            end
%         case 2 % correlation betw. PERFORMANCE and RT
%         % NB. missed trials count as incorrect responses
%             % for every session per participant...
%             for s = 1:11
%                 % set up session string so we can create a filename to load
%                 % the participant's data (per session)
%                 sess_str = ['sess0' num2str(s)];
%                 fname_b = [sub_str '_' sess_str '_behav.mat'];
%                 if isfile([root fname_b])
%                     % load up each participant's relevant session file
%                     load([root fname_b]);
%                     % extract the measures we want
%                     LR_cohs_PMF = analyse_task_data(respMat, B);
%                     % we now plot a scatter plot of each set of data (i.e. each
%                     % block per participant--there are four plots, so all blocks
%                     % get 
%                     for n = 1:4
%                         subplot(2, 2, n);
%                         scatter(LR_cohs_PMF{n}(:, 1), LR_cohs_PMF{n}(:, 3));
%                         % set axes
%                         axis([0 0.7 0 500]);
%                         % add least-squares linear regression line to scatter plots
%                         xlabel('Coherence (unitless)');
%                         ylabel('Reaction time (frames)');
%                         lsline;
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
    end
end

% set up figure (we are going to be plotting a lot)
figure;

% indeed, plot the mean of everything. First column is the sum of all
% rightwards ratios for a specific coherence (row), second column is the
% mean of them; columns 3 and 4 have the same function, but for leftward
% button press ratios
ratio_calc = zeros(6, 4);
for n = 1:6 % for every coherence...
    % calculate the mean R/(R+L+M) for all subjects.
    % we can simply add up all the ratios we have calculated already and
    % divide by number of subjects
    ratio_calc(i, 1) = sum(sums{n, 2}(6,:));
    ratio_calc(i, 3) = sum(sums{n, 2}(7,:));
    % and the mean ratio for each coh is...
    ratio_calc(i, 2) = ratio_calc(i, 1)/idx_parts;
    ratio_calc(i, 4) = ratio_calc(i, 3)/idx_parts;
end

% finally, plot all this
for n = 1:4
    % begin plotting
    subplot(2, 2, n);
    % rightward response data
    scatter(LR_cohs_PMF_ordered{n}(:, 1), LR_cohs_PMF_ordered{n}(:, 6)); 
    % leftward response data
    % scatter(abs(LR_cohs_PMF_ordered{n}(:, 1)), LR_cohs_PMF_ordered{n}(:, 2));
    % set axes
    axis([-.6 .6 0 1]);
    xlabel('Coherence (unitless)');
    ylabel('Proportion rightward responses');
    % lsline;
    % tell us what's been plotted
    disp(['Plotted ' sub_str ', ' sess_str ', block ' num2str(n) '.']);
    % hold on so same figure is used
    hold on;
end


end