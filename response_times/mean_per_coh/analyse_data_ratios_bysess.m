function analyse_data_ratios_bysess(type, side, int_control, input_cohs, ids)
% PURPOSE: Analyses our data in a specific manner (gives psychometric
% functions). See 'Input' for details.
%
% Input
%   type = what kind of analysis you wish to perform
%            1: proportion responses correct (per coherence, per condition,
%            per subject, per session (mean))
%            2: proportion misses (per coherence, per condition, per 
%            subjects, per session (mean))
%            DELETE THIS -> 3: response times (per coherence, per condition, per subject,
%            per session (mean))
%   side = what side button press you wish to analyse
%            1: mean of ratio across subjects and sessions VS.
%            coherence for each condition
%            2: mean of ratio across subjects and sessions VS.
%            coherence
%            3: coherences collapsed (no side)
%   int_control = control for integration length? (counts correct responses
%               to LONG integration trial periods after 3 seconds as 
%               misses)
%                 0: no
%                 1: yes
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
unique_coherences = unique(abs(coherences));

% preallocate array for data from all participants
input_data = cell(1, 4*length(ids));
% use this var so we don't have to waste time re-loading what we have
last_file_loaded = [''];

% initialise sums variable for all participants. Each row corresponds to a
% different coherence (from -.5 to .5 here)
sums = cell(6, 2);
% abs_sums used for analyses collapsing across coherences
abs_sums = cell(3, 2);
% RT analysis. RTs_means holds the mean per session, per coherence, per
% condition per subject; RTs_together holds
RTs_means = cell(6, 4);
for i = 1:24
    RTs_means{i} = cell(6, 1);
end
% TEMPORARY (debug) make one for each session

for z = 1:6
    sums{z, 1} = coherences(z);
    averages_conds{z, 1} = coherences(z);
    % RTs_together{z, 1} = cell(4, 1);
end
for z = 1:3
    abs_sums{z, 1} = unique_coherences(z);
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
% init abs_sums
for i = 1:3
    for n = 1:4
        abs_sums{i, 2}{n} = NaN(4, max(ids));
    end
end

% index used just before plotting to know how many sessions we have
% successfully loaded for each subject (needed to find mean responses per
% session)
idx_sessions = zeros(length(ids), 1);
% vector used to calculate how many participants' data successfully loaded
parts = NaN(length(ids), 1);

% loop through every participant
for i = 1:length(ids)
    % make a string for ID, efficient later
    if ids(i) < 100
        sub_str = ['sub0' num2str(ids(i))];
    else
        sub_str = ['sub' num2str(ids(i))];
    end
    % for my comp root = ['c:\experiments\Maria_contin_motion\analysis\' sub_str '\'];
    root = ['C:\experiments\Maria_contin_motion\analysis\behav_synth\'];
    
    for s = 1:12
        % set up session string so we can create a filename to load
        % the participant's data (per session)
        if s < 10
            sess_str = ['sess00' num2str(s)];
        else
            sess_str = ['sess0' num2str(s)];
        end
        fname_b = [sub_str '_' sess_str '_behav.mat'];
        % fname_s = [sub_str '_' sess_str '_stim.mat'];
        if isfile([root fname_b]) % && isfile([root fname_s])
            % do we have the file loaded?
            if ~strcmp(last_file_loaded, [root fname_b])
                % load up each participant's relevant session files
                load([root fname_b]);
                % load([root fname_s]);
                last_file_loaded = [root fname_b];
                % display message
                disp(['Data for ' sub_str ', ' sess_str ...
                    ' succesfully loaded.']);
                % show this participant has been loaded
                if isnan(parts(i))
                    parts(i) = 1;
                end
                % increase sessions loaded for this participant by one
                idx_sessions(i) = idx_sessions(i) + 1;
            end
            % extract the measures we want
            if type == 3 % if measuring reaction times...
                input_data = analyse_task_RT_PMF(respMat, B, input_cohs);
            else
                if int_control == 0 % not controlling for integration length...
                    input_data = analyse_task_data_PMF(respMat, B, input_cohs, 0);
                else
                    input_data = analyse_task_data_PMF(respMat, B, input_cohs, 1);
                end
            end
            % create new variable, where we will order the data by
            % condition
            input_data_ordered = input_data;
            % figure out condition order (this is why we loaded
            % S...)
            cond_order = cellfun(@str2num, S_behav.block_ID_cells);
            for n = 1:4
                % order data by condition, so that we know which
                % condition the data was from just by its row 
                % number (e.g. row 1 means it comes from
                % condition 1)
                if type == 3 % if we're studying RTs...
                    for coherence = 1:length(coherences)
                        input_data_ordered{coherence, n} = ...
                            input_data{coherence, cond_order == n};
                    end
                else
                    input_data_ordered{n} = input_data{cond_order == n};
                end
            end
            %% If analysing ratios (type == 1 or 2)
            if type == 1 | type == 2
                % begin summing up individual R and L values (which up to now
                % each were per session, per condition, per coherence -> will
                % now be *across* sessions, per cond, per coh) and M_R and M_L
                % values (til now were per sess, per cond -> will now be summed
                % up *across* sess, per cond)
                % Then, after this sum, we divide by session number to get the
                % mean per session.

                % SUMMING ACROSS SESSIONS
                for n = 1:6 % FOR all coherences...
                    for condition = 1:4 % FOR all conditions...
                        % make zeros first if NaN...
                        if isnan(sums{n, 2}{condition}(1, ids(i)))
                            sums{n, 2}{condition}(1:9, ids(i)) = 0;
                        end
                        % R, L, M_R and M_L and T (total i.e. correct +
                        % incorrect + missed) responses
                        sums{n, 2}{condition}(1,ids(i)) = sums{n, 2}{condition}(1,ids(i)) + input_data_ordered{condition}(n, 2); % R
                        sums{n, 2}{condition}(2,ids(i)) = sums{n, 2}{condition}(2,ids(i)) + input_data_ordered{condition}(n, 3); % L
                        sums{n, 2}{condition}(3,ids(i)) = sums{n, 2}{condition}(3,ids(i)) + input_data_ordered{condition}(n, 4); % M_R
                        sums{n, 2}{condition}(4,ids(i)) = sums{n, 2}{condition}(4,ids(i)) + input_data_ordered{condition}(n, 5); % M_L
                        sums{n, 2}{condition}(5,ids(i)) = sum(sums{n, 2}{condition}(1:4, ids(i))); % T
                        sums{n, 2}{condition}(6,ids(i)) = sums{n, 2}{condition}(6,ids(i)) + input_data_ordered{condition}(n, 6); % R/(R+L+M_R)
                        sums{n, 2}{condition}(7,ids(i)) = sums{n, 2}{condition}(7,ids(i)) + input_data_ordered{condition}(n, 7); % L/(R+L+M_L)
                        sums{n, 2}{condition}(8,ids(i)) = sums{n, 2}{condition}(8,ids(i)) + input_data_ordered{condition}(n, 8); % M_R/(R+L+M_R)
                        sums{n, 2}{condition}(9,ids(i)) = sums{n, 2}{condition}(9,ids(i)) + input_data_ordered{condition}(n, 9); % M_L/(R+L+M_L)
                    end
                end
            elseif type == 3
            %% Analysing RTs
                for coherence = 1:6
                    for condition = 1:4
                        % transfer each session block into a common
                        % repository, from which we derive the per-session
                        % means later
                        transfer_block = input_data_ordered{coherence, condition}(:, 1:2);
                        RTs_commons{coherence, condition}{s}(end + 1:end + size(transfer_block, 1), 1:2) = transfer_block;
                    end
                end
            end
        else
            disp(['Behavioural data for ' sub_str ', ' sess_str ...
                ' not found in designated directory!']);
        end
    end
    
    %% If dividing across sessions
    if type == 1 || type == 2
        % DIVIDE ACROSS SESSIONS
        % Now we divide all the summed data (individual responses, ratios,
        % etc.) across the loaded sessions so we get the means of everything

        for n = 1:6 % FOR all coherences...
            for condition = 1:4 % FOR all conditions...
                for row = 1:9
                    sums{n, 2}{condition}(row,ids(i)) = sums{n, 2}{condition}(row,ids(i))/idx_sessions(i); % R
                end
            end
        end

        % SET UP UNIQUE COHERENCES (if desired)
        % This simply creates a new variable where the data are group according
        % to |coherence| so we can see things like "proportion of correct
        % responses per |coherence|" instead of separating by left/right
        if side == 3
            for n = 1:3
                for condition = 1:4
                    % check for NaNs...
                    if isnan(abs_sums{n, 2}{condition}(1, ids(i)))
                        abs_sums{n, 2}{condition}(1:5, ids(i)) = 0;
                    end
                    % NB. We have to go "inside-out" because
                    % the order of coherences is [-0.5 -0.4
                    % -0.3 0.3 0.4 0.5] so we have to match
                    % each with each
                    abs_sums{n, 2}{condition}(1,ids(i)) = (sums{4-n, 2}{condition}(1,ids(i)) + sums{3+n, 2}{condition}(1,ids(i))) + (sums{4-n, 2}{condition}(2,ids(i)) + sums{3+n, 2}{condition}(2,ids(i))); % R + L (per subject, per absolute coherence, per condition, per session)
                    abs_sums{n, 2}{condition}(2,ids(i)) = (sums{4-n, 2}{condition}(3,ids(i)) + sums{3+n, 2}{condition}(3,ids(i))) + (sums{4-n, 2}{condition}(4,ids(i)) + sums{3+n, 2}{condition}(4,ids(i))); % M_R + M_L (per subject, per condition, per session)
                    abs_sums{n, 2}{condition}(3,ids(i)) = abs_sums{n, 2}{condition}(1,ids(i))/(abs_sums{n, 2}{condition}(1,ids(i)) + abs_sums{n, 2}{condition}(2,ids(i))); % (R+L)/(R+L+M_R+M_L) i.e. total proportion correct resp. per unique abs coh
                    abs_sums{n, 2}{condition}(4,ids(i)) = abs_sums{n, 2}{condition}(2,ids(i))/(abs_sums{n, 2}{condition}(1,ids(i)) + abs_sums{n, 2}{condition}(2,ids(i))); % (M_R+M_L)/(R+L+M_R+M_L) i.e. total proportion misses per unique abs coh
                end
            end
        end
    elseif type == 3 && exist('input_data_ordered','var') == 1
        %% If analysing reaction times (type == 3)
        % Find mean for each subject's condition (i.e. data now are
        % per subject, *mean per session*, per condition, per
        % coherence)
        for coherence = 1:length(coherences)
            for condition = 1:4
                for sess = 1:6
                    % sometimes subjects have not responded at all in some
                    % conditions; to prevent these cells being NaN, 
                    % pre-emptively set them to zero
                    if ~isempty( RTs_commons{coherence, condition}{sess} )
                        RTs_means{coherence, condition}{sess}(end + 1, 1:2) = mean( RTs_commons{coherence, condition}{sess}(:, 1:2) );
                    else
                        RTs_means{coherence, condition}{sess}(end + 1, 1:2) = [0 0];
                    end
                end
            end
        end
        
        % NB. *must* clear this variable at the end of every session,
        % otherwise the above 'exist' check will always be 1 after you load
        % it for the first time...
        clear('input_data_ordered');
    end
end

% calculate total participants loaded
part_number = nansum(parts);

% set up figure (we are going to be plotting a lot)
figure;

switch type
    case 1 | 2
        % create variable where we collect all the different ratios per coherence
        % per condition across subjects. First column is for rightwards ratios,
        % second column is for leftwards ratios
        ratios_together = cell(4, 2);
        ratios_together_abscoh = cell(4, 1);
        % create variable for mean of everything. First column is the sum of all
        % rightwards ratios for a specific coherence (row), second column is the
        % mean of them; columns 3 and 4 have the same function, but for leftward
        % button press ratios
        ratios_means = cell(4,1);
        ratios_means_abscoh = cell(4,1);
        for i = 1:4
            % initialise variables for storing ratio means
            ratios_means{i} = NaN(6, 4);
            ratios_means_abscoh{i} = NaN(3, 4);
            ratios_together{i} = NaN(6, part_number);
            ratios_together_abscoh{i} = NaN(6, part_number);
        end
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
        % SET-UP: final values
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
                % all subjects and all sessions (numerator of the mean formula)
                ratios_means{i}(n, 1) = nansum(sums{n, 2}{i}(6,:));
                ratios_means{i}(n, 3) = nansum(sums{n, 2}{i}(7,:));
                % and the mean ratio for each coh is...
                % (divide by participant number b/c there is only one ratio per
                % coherence per condition for each participant, so the amount of 
                % ratios we add together to the numerator of our mean formula is 
                % equal to the amount of participants, which is what we put in the
                % denominator)
                ratios_means{i}(n, 2) = ratios_means{i}(n, 1)/(part_number);
                ratios_means{i}(n, 4) = ratios_means{i}(n, 3)/(part_number);
            end
        end

        % PLOT: finally, plot all this. FOR all conditions...
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
        
    %%% TYPE 2: RATIOS OF MISSES %%%
    case 2
        % just like above, calculate proportions (here, of misses) for each
        % coherence and condition
        for i = 1:4 % FOR each block
            % calculate the mean miss proportion (i.e. M_R/(R+L+M_R)) for 
            % each subject.
            % we can simply add up all the ratios (across conditions and 
            % coherences) we have calculated already and divide by number of
            % ratios.
            if side == 3 % if coherences collapsed
                for n = 1:3 % FOR each coherence
                    % find indices of non-NaN columns (i.e. subjects whose data
                    % we have actually imported)
                    indices = find(~isnan(abs_sums{n, 2}{i}(4, :)));
                    % first, create a matrix which contains all ratios per coherence
                    % per condition across all subjects
                    ratios_together_abscoh{i}(n, 1:length(indices)) = ...
                        abs_sums{n, 2}{i}(4, indices); % 
                    % the sum of ratios for each coherence for each condition across
                    % all subjects (numerator of the mean formula)
                    ratios_means_abscoh{i}(n, 1) = nansum(abs_sums{n, 2}{i}(4, :));
                    % and the mean ratio for each coh is...
                    ratios_means_abscoh{i}(n, 2) = ratios_means_abscoh{i}(n, 1)/part_number;
                end
            else
                for n = 1:6 % FOR each coherence
                    % find indices of non-NaN columns (i.e. subjects whose data
                    % we have actually imported)
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
        end

        % PLOT: finally, plot all this. FOR all blocks...
        for i = 1:4
            % begin plotting
            subplot(2, 2, i);
            switch side
                case 1 % rightward resp data
                    % calculate interquartile ranges (IQR) so we can plot it with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:6
                        % calculate 25%-75% IQRs for each coherence
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
                        % calculate 25%-75% IQRs for each coherence
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
                case 3 % COLLAPSED COHERENCES
                    iqr = NaN(3, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:3
                        % calculate 25%-75% IQRs for each unique
                        % coherence (i.e. unique absolute value)
                        iqr(n, 1) = quantile(ratios_together_abscoh{i}(n, :), 0.25); % sum up all unique coherences regardless of sign (branching out from the middle)
                        iqr(n, 2) = quantile(ratios_together_abscoh{i}(n, :), 0.75);
                    end

                    % fill background (IQRs)
                    fill([unique_coherences fliplr(unique_coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightRed'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(unique_coherences, ratios_means_abscoh{i}(1:3, 2), '-*', ...
                     'Color', plotColour('Red'));
                 ylabel('Mean of M_R+M_L/(R+L+M_R)');
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
            if side ~= 3
                axis([-.6 .6 0 1]);
                xlabel('Coherence (unitless)');
            else
                axis([0.2 0.6 0 1]);
                xlabel('Absolute coherence (unitless)');
            end
            % hold on so same figure is used
            hold on;
        end
    %%% TYPE 3: RESPONSE TIMES VS. COHERENCE %%%
    case 3
        % find mean of log(RTs) for each coherence.
        % set up mean variable
        mean_RTs = cell( 4, 1 );
        for coherence = 1:length(coherences)
            for condition = 1:4
                for sess = 1:6
                    % mean of RTs
                    mean_RTs{condition}(coherence, sess) = mean( RTs_means{coherence, condition}{sess}(:, 2) );
                end
            end
        end
        
        % PLOT: FOR all conditions...
        %% Change back condition to 1:4
        for condition = 1:6
            % begin plotting
            subplot(3, 2, condition);
            switch side
                case 1 % rightward resp data
                    % calculate interquartile ranges (IQR) so we can plot it with plot()
                    error_bars = NaN(6, 1); % one for each coherence
                    for coherence = 1:length(coherences)
                        % calculate error bar total length for each
                        % coherence
                        %error_bars(coherence) = std( RTs_means{coherence, condition}(:, 2) )/sqrt( length(RTs_means{coherence, condition}(:, 1) ));
                    end
                    % fill background (IQRs)
%                      fill([coherences.' fliplr(coherences).'], ...
%                          [mean_RTs{condition}(:, 2)-error_bars(:)/2 fliplr(mean_RTs{condition}(:, 2)+error_bars(:)/2)], ...
%                          plotColour('LightBlue'), 'LineStyle', 'none');
                    % plot error bars
                    hold on;
                    %errorbar(coherences, mean_RTs{condition}(:, 2), error_bars(:)/2);
                    % plot mean
                    hold on;
                    %% switch {3} to {condition}
                    plot(coherences, mean_RTs{3}(:, condition), ...
                        '-*', 'Color', plotColour('Red'));
                    ylabel('Log response time');
                %% Finish below (leftward and together)
                case 2 % leftward response data
                    % calculate quartiles so we can plot IQRs with plot()
                    iqr = NaN(6, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:6
                        % calculate 25%-75% IQRs for each coherence
                        iqr(n, 1) = quantile(ratios_together{condition, 2}(n, :), 0.25);
                        iqr(n, 2) = quantile(ratios_together{condition, 2}(n, :), 0.75);
                    end

                    % fill background (IQRs)
                    fill([coherences fliplr(coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightRed'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(coherences, ratios_means{condition}(:, 4), '-*', ...
                         'Color', plotColour('Red'));
                    ylabel('Mean of M_L/(R+L+M_L)');
                case 3 % COLLAPSED COHERENCES
                    iqr = NaN(3, 2); % first column is 25% quartile, second is 75% quart
                    for n = 1:3
                        % calculate 25%-75% IQRs for each unique
                        % coherence (i.e. unique absolute value)
                        iqr(n, 1) = quantile(ratios_together_abscoh{condition}(n, :), 0.25); % sum up all unique coherences regardless of sign (branching out from the middle)
                        iqr(n, 2) = quantile(ratios_together_abscoh{condition}(n, :), 0.75);
                    end

                    % fill background (IQRs)
                    fill([unique_coherences fliplr(unique_coherences)], ...
                        [iqr(:, 1).' fliplr(iqr(:, 2).')], ...
                        plotColour('LightRed'), 'LineStyle', 'none');
                    hold on;
                    % plot mean
                    plot(unique_coherences, ratios_means_abscoh{condition}(1:3, 2), '-*', ...
                     'Color', plotColour('Red'));
                 ylabel('Mean of M_R+M_L/(R+L+M_R)');
            end
            % set title
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
            % set axes
            if side ~= 3
                axis([-.6 .6 0 1]);
                xlabel('Coherence (unitless)');
            else
                axis([0.2 0.6 0 1]);
                xlabel('Absolute coherence (unitless)');
            end
            if type == 3
                axis([-.6 .6 0 5]);
            end
            % hold on so same figure is used
            hold on;
        end
        
end

end