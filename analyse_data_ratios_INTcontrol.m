function analyse_data_ratios(type, side, input_cohs, ids)
% PURPOSE: Does the same thing as analyse_data_ratios, but controls for
% integration length (trial length) by counting correct responses for INT_L
% trials only if they occurred in the first 3 seconds (even though the
% participants could have responded in any of the first 5)
%
% Input
%   type = what kind of analysis you wish to perform
%            1: proportion responses correct (per coherence, per condition,
%            across subjects)
%            2: proportion misses (per coherence, per condition, across
%            subjects)
%   side = what side button press you wish to analyse
%            1: mean of R/(R+L+M_R) across subjects and sessions VS.
%            coherence for each condition
%            2: mean of L/(R+L+M_R) across subjects and sessions VS.
%            coherence
%   ids = vector which includes all the subjects you wish to study (e.g. if
%         you wish to study subjects 37 and 39-44, this should be 
%         [37,39:44])
% Output
%   nothing, just makes plots! (For now.)

% set coherences
if isempty(input_cohs)
    coherences = [-0.5 -0.4 -0.3 0.3 0.4 0.5];
else
    coherences = input_cohs;
end

% preallocate array for data from all participants
LR_cohs_PMF = cell(1, 4*length(ids));
% use this var so we don't have to waste time re-loading what we have
last_file_loaded = [''];

% initialise sums variable for all participants. Each row corresponds to a
% different coherence (from -.5 to .5 here)
sums = cell(6, 2);
for z = 1:6
    sums{z, 1} = coherences(z);
end
% initialising the sums variable, which contains all the data we want.
% a 6x2 cell, where the rows of the first column just act as indicators for
% which coherence the stuff in the second column is from.
% the second column contains a 1x4 cell array in each row (coherence),
% holding the data for that coherence from each individual condition
for i = 1:6
    for n = 1:4
        sums{i, 2}{n} = NaN(9, max(ids));
    end
end

% index used just before plotting to know how many sessions we have
% successfully loaded (need it to calculate means of ratios)
idx_sessions = 0;

% loop through every participant
for i = 1:length(ids)
    % make a string for ID, efficient later
    if ids(i) < 100
        sub_str = ['sub0' num2str(ids(i))];
    else
        sub_str = ['sub' num2str(ids(i))];
    end
    % for my comp root = ['c:\experiments\Maria_contin_motion\analysis\' sub_str '\'];
    root = ['c:\experiments\Maria_contin_motion\analysis\' sub_str '\'];
            for s = 1:6
                % set up session string so we can create a filename to load
                % the participant's data (per session)
                sess_str = ['sess00' num2str(s)];
                fname_b = [sub_str '_' sess_str '_behav.mat'];
                % fname_s = [sub_str '_' sess_str '_stim.mat'];
                if isfile([root fname_b]) % && isfile([root fname_s])
                    % do we have the file loaded?
                    if ~strcmp(last_file_loaded, [root fname_b])
                        % load up each participant's relevant session files
                        load([root fname_b]);
                        % load([root fname_s]);
                        last_file_loaded = [root fname_b];
                    end
                    % extract the measures we want
                    LR_cohs_PMF = ...
                        analyse_task_data_PMF_INTcontrol(respMat, B);
                    % create new variable, where we will order the data by
                    % condition
                    LR_cohs_PMF_ordered = LR_cohs_PMF;
                    % figure out condition order (this is why we loaded
                    % S...)
                    cond_order = cellfun(@str2num, S_behav.block_ID_cells);
                    for n = 1:4
                        % order data by condition, so that we know which
                        % condition the data was from just by its row 
                        % number (e.g. row 1 means it comes from
                        % condition 1)
                        LR_cohs_PMF_ordered{n} = LR_cohs_PMF{cond_order == n};
                    end
                    
                    % begin summing
                    for n = 1:6 % FOR all coherences...
                        for condition = 1:4 % FOR all conditions...
                            % make zeros first if NaN...
                            if isnan(sums{n, 2}{condition}(1, ids(i)))
                                sums{n, 2}{condition}(1:5, ids(i)) = 0;
                            end
                            % R, L, M_R and M_L and T (total i.e. correct +
                            % incorrect + missed) responses
                            sums{n, 2}{condition}(1,ids(i)) = sums{n, 2}{condition}(1,ids(i)) + LR_cohs_PMF_ordered{condition}(n, 2); % R
                            sums{n, 2}{condition}(2,ids(i)) = sums{n, 2}{condition}(2,ids(i)) + LR_cohs_PMF_ordered{condition}(n, 3); % L
                            sums{n, 2}{condition}(3,ids(i)) = sums{n, 2}{condition}(3,ids(i)) + LR_cohs_PMF_ordered{condition}(n, 4); % M_R
                            sums{n, 2}{condition}(4,ids(i)) = sums{n, 2}{condition}(4,ids(i)) + LR_cohs_PMF_ordered{condition}(n, 5); % M_L
                            sums{n, 2}{condition}(5,ids(i)) = sum(sums{n, 2}{condition}(1:4, ids(i))); % T
                            sums{n, 2}{condition}(6,ids(i)) = sums{n, 2}{condition}(1,ids(i))/(sums{n, 2}{condition}(1,ids(i)) + sums{n, 2}{condition}(2,ids(i)) + sums{n, 2}{condition}(3,ids(i))); % R/(R+L+M_R)
                            sums{n, 2}{condition}(7,ids(i)) = sums{n, 2}{condition}(2,ids(i))/(sums{n, 2}{condition}(1,ids(i)) + sums{n, 2}{condition}(2,ids(i)) + sums{n, 2}{condition}(4,ids(i))); % L/(R+L+M_L)
                            sums{n, 2}{condition}(8,ids(i)) = sums{n, 2}{condition}(3,ids(i))/(sums{n, 2}{condition}(1,ids(i)) + sums{n, 2}{condition}(2,ids(i)) + sums{n, 2}{condition}(3,ids(i))); % M_R/(R+L+M_R)
                            sums{n, 2}{condition}(9,ids(i)) = sums{n, 2}{condition}(4,ids(i))/(sums{n, 2}{condition}(1,ids(i)) + sums{n, 2}{condition}(2,ids(i)) + sums{n, 2}{condition}(4,ids(i))); % M_L/(R+L+M_L)
                        end
                    end
                    idx_sessions = idx_sessions + 1;
                else
                    disp(['Behavioural data for ' sub_str ', ' sess_str ...
                        'not found in designated directory!']);
                end
            end
end

% set up figure (we are going to be plotting a lot)
figure;

% if we didn't load an equal amount of sessions from each participant (six
% sessions per participant) display WARNING message...
if round(idx_sessions) ~= idx_sessions
    disp(['WARNING: You didn''t load an equal amount of sessions from' ...
        ' each participant! This will seriously affect your data. ' ...
        'Check what''s gone wrong!']);
    part_number = -1;
else
    part_number = idx_sessions/6;
end

% create variable where we collect all the different ratios per coherence
% per condition across subjects. First column is for rightwards ratios,
% second column is for leftwards ratios
ratios_together = cell(4, 2);
% create variable for mean of everything. First column is the sum of all
% rightwards ratios for a specific coherence (row), second column is the
% mean of them; columns 3 and 4 have the same function, but for leftward
% button press ratios
ratios_means = cell(4,1); 
for i = 1:4
    ratios_means{i} = NaN(6, 4);
    ratios_together{i} = NaN(6, part_number);
end
% set up colour key/value pairs, so it's easier... 
colourKeys = {'LightRed', 'Red', 'LightBlue', 'Blue'};
colourValues = {[1 0.741 0.875], [0.929 0.067 0.513], ...
    [0.753 0.839 0.980], [31/255, 117/255, 255/255]};
plotColour = containers.Map(colourKeys, colourValues); 

% now, what kind of analysis did we want?
switch type
    %%% TYPE 1: RATIOS OF CORRECT RESPONSES %%%
    case 1
        for n = 1:6 % for every coherence...
            % calculate the mean R/(R+L+M) for all subjects.
            % we can simply add up all the ratios (across conditions and 
            % coherences) we have calculated already and divide by number of
            % ratios. NB. do this for *each* block
            for i = 1:4
                % non-NaN indices
                indices_R_ratio = find(~isnan(sums{n, 2}{i}(6, :)));
                indices_L_ratio = find(~isnan(sums{n, 2}{i}(7, :)));
                % first, create a matrix which contains all ratios per coherence
                % per condition across all subjects
                ratios_together{i, 1}(n, 1:length(indices_R_ratio)) = ...
                    sums{n, 2}{i}(6, indices_R_ratio); % rightwards responses
                ratios_together{i, 2}(n, 1:length(indices_L_ratio)) = ...
                    sums{n, 2}{i}(7, indices_L_ratio); % leftwards responses
                % the sum of ratios for each coherence for each condition across
                % all subjects (numerator of the mean formula)
                ratios_means{i}(n, 1) = nansum(sums{n, 2}{i}(6,:));
                ratios_means{i}(n, 3) = nansum(sums{n, 2}{i}(7,:));
                % and the mean ratio for each coh is...
                % (divide by participant number b/c there is only one ratio per
                % coherence per condition for each participant, so the amount of 
                % ratios we add together to the numerator of our mean formula is 
                % equal to the amount of participants, which is what we put in the
                % denominator)
                ratios_means{i}(n, 2) = ratios_means{i}(n, 1)/part_number;
                ratios_means{i}(n, 4) = ratios_means{i}(n, 3)/part_number;
            end
        end

        % finally, plot all this. FOR all blocks...
        for i = 1:4
            % begin plotting
            subplot(2, 2, i);
            switch side
                case 1 % rightward resp data
                    % calculate interquartile ranges (IQR) so we can plot it with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quartile
                    for n = 1:6
                        iqr(n, 1) = quantile(ratios_together{i, 1}(n, :), 0.25);
                        iqr(n, 2) = quantile(ratios_together{i, 1}(n, :), 0.75);
                    end
                    % fill in background to show interquartile ranges 
                    % (it looks all Nature Neuroscience-y and therefore  
                    % cool)
                    fill([coherences fliplr(coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightBlue'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(coherences, ratios_means{i}(:, 2), '-s', ...
                         'Color', plotColour('Blue'));
                    hold on;
                    ylabel('Mean of R/(R+L+M_R)');
                case 2 % leftward response data
                    % calculate quartiles so we can plot IQRs with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:6
                        iqr(n, 1) = quantile(ratios_together{i, 2}(n, :), 0.25);
                        iqr(n, 2) = quantile(ratios_together{i, 2}(n, :), 0.75);
                    end
                    % fill in background to show IQRs 
                    fill([coherences fliplr(coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightBlue'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(coherences, ratios_means{i}(:, 4), '-s', ...
                        'Color', plotColour('Blue'));
                    hold on;
                    ylabel('Mean of L/(R+L+M_L)');
            end
            % set title
            switch i
                case 1
                    title('Frequent trials, short integration');
                case 2
                    title('Frequent trials, long integration (INT c)');
                case 3
                    title('Rare trials, short integration');
                case 4
                    title('Rare trials, long integration (INT c)');
            end
            % set axes
            axis([-.6 .6 0 1]);
            xlabel('Coherence (unitless)');
            % hold on so same figure is used
            hold on;
        end
        
    %%% TYPE 2: MISS PROPORTIONS (RATIOS) %%%
    case 2
        % just like above, calculate proportions (here, of misses) for each
        % coherence and condition
        for n = 1:6
            % calculate the mean miss proportion (i.e. M/(R+L+M_R)) for 
            % each subject.
            % we can simply add up all the ratios (across conditions and 
            % coherences) we have calculated already and divide by number of
            % ratios. NB. do this for *each* block
            for i = 1:4
                % non-NaN indices
                indices_R_ratio = find(~isnan(sums{n, 2}{i}(8, :)));
                indices_L_ratio = find(~isnan(sums{n, 2}{i}(9, :)));
                % first, create a matrix which contains all ratios per coherence
                % per condition across all subjects
                ratios_together{i, 1}(n, 1:length(indices_R_ratio)) = ...
                    sums{n, 2}{i}(8, indices_R_ratio); % rightwards responses
                ratios_together{i, 2}(n, 1:length(indices_L_ratio)) = ...
                    sums{n, 2}{i}(9, indices_L_ratio); % leftwards responses
                % the sum of ratios for each coherence for each condition across
                % all subjects (numerator of the mean formula)
                ratios_means{i}(n, 1) = nansum(sums{n, 2}{i}(8,:));
                ratios_means{i}(n, 3) = nansum(sums{n, 2}{i}(9,:));
                % and the mean ratio for each coh is...
                % (divide by participant number b/c there is only one ratio per
                % coherence per condition for each participant, so the amount of 
                % ratios we add together to the numerator of our mean formula is 
                % equal to the amount of participants, which is what we put in the
                % denominator)
                ratios_means{i}(n, 2) = ratios_means{i}(n, 1)/part_number;
                ratios_means{i}(n, 4) = ratios_means{i}(n, 3)/part_number;
            end
        end

        % finally, plot all this. FOR all blocks...
        for i = 1:4
            % begin plotting
            subplot(2, 2, i);
            switch side
                case 1 % rightward resp data
                    % calculate interquartile ranges (IQR) so we can plot it with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:6
                        iqr(n, 1) = quantile(ratios_together{i, 1}(n, :), 0.25);
                        iqr(n, 2) = quantile(ratios_together{i, 1}(n, :), 0.75);
                    end
                    % fill background (IQRs)
                    fill([coherences fliplr(coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightRed'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(coherences, ratios_means{i}(:, 2), '-*', ...
                         'Color', plotColour('Red'));
                    ylabel('Mean of M_R/(R+L+M_R)');
                case 2 % leftward response data
                    % calculate quartiles so we can plot IQRs with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:6
                        iqr(n, 1) = quantile(ratios_together{i, 2}(n, :), 0.25);
                        iqr(n, 2) = quantile(ratios_together{i, 2}(n, :), 0.75);
                    end
                    % fill background (IQRs)
                    fill([coherences fliplr(coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightRed'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(coherences, ratios_means{i}(:, 4), '-*', ...
                         'Color', plotColour('Red'));
                    ylabel('Mean of M_L/(R+L+M_L)');
            end
            % set title
            switch i
                case 1
                    title('Frequent trials, short integration');
                case 2
                    title('Frequent trials, long integration');
                case 3
                    title('Rare trials, short integration');
                case 4
                    title('Rare trials, long integration');
            end
            % set axes
            axis([-.6 .6 0 1]);
            xlabel('Coherence (unitless)');
            % hold on so same figure is used
            hold on;
        end
end

end