function [xy, coherence_frame, coherence_frame_v, mean_coherence, ...
    mean_coherence_v, pre_incoh_mo_coh, blocks_shuffled] = ...
    move_dots(S, discrete_trials, trial, ...
    total_frames, ap_radius, coherence_sd, direction_org, step, Nd, ...
    pre_incoh_mo, mean_coherence, blocks_coherence_cells, ...
    coherence_frame, coherence_list, ITIS_vec, integration_long, noise, ...
    passbandfreq, stopbandfreq, passrip, stopbandatten, framerate, ...
    noise_amplitude, mean_duration, sd_duration, noise_function, ...
    stim_function, step_v, iti_vec_v, cohs_v, vert_motion)
% PURPOSE: This function creates the dots' X/Y positions for discrete  
% trials or continuous blocks of motion and saves those coordinates for 
% *each* frame. Thus, every dot has its own X/Y coordinates for each frame, 
% and all of this is saved in the output matrix 'xy'. This matrix is then
% used to render all the dots in either discrete_rdk_trials_training (when
% doing discrete trials) or present_rdk (when doing continous trials).

% NB. The two coherences (for horizontal movement and vertical movement)
% added together cannot be more than 1, as then you get diagonal movement,
% which is undesired.

% Two types of dots: SIGNAL dots (which move in a specific direction during
% a trial, i.e. during "coherence") and NOISE dots (which just move
% randomly)

% NB. The stimulus is coded in a way that there are 3 sets of dots, whose
% positions are calculated randomly each for the first three frames, and 
% every set of dots is "reshuffled" (noise dots) and moved (signal dots)
% every third frame, depending on the positions of its dots three frames
% previous.

% Input:
%
% discrete_trials   - flag 1 if discrete trials displayed for training, 0
%                     if continuous version
% trial             - current trial ID only for discrete trial version
% total_frames      - number of frames random dots are displayed - this is
%                     for pre-allocation of space
% ap_radius         - radius of the circular aperture in which the dots are
%                     displayed
% coherence_sd      - standard deviation for a normal distribution that we
%                     use to sample coherence levels during incoherent motion
%                     periods
% direction_org     - used to calculate in which direction the dots are
%                     moving - just a 1 - has been used for something else
%                     in the past (Neb: should get rid of this?)
% step              - speed with which the signal dots move - pixels/frame
% Nd                - number of dots displayed per frame
% pre_incoh_m       - time incoherent motion is displayed before coherent
%                     motion starts in discrete trial version (in number of frames)
% mean_coherence    - pre-allocated vector which will be a vector out of
%                     zeros for incoherent motion periods and the level of
%                     coherence at periods of coherent motion for each frame
%                     (for continuous task version only)
% blocks_coherence
% _cells            - vector with sequence coherence values used for
%                     coherent motion periods - used to fill up coherent
%                     periods in mean_coherence (for continuous task
%                     version only)
% coherence_frame   - pre-allocated vector that gets assigned coherence
%                     values during incoherent and coherent motion periods
%                     for each frame
% coherence_list    - list of coherences for trials (discrete trial version
%                     only) (basically same as blocks_coherence_cells for
%                     continuous motion task)
% ITIS_vec          - vector containing list of length of incoherent motion
%                     periods between coherent motion periods in number of
%                     frames (only continuous motion task)
% integration_long  - length of a coherent motion period in number of
%                     frames (continuous motion task only)
% noise             - flag 0: when calculating the original coherence_frame
%                     vector for displaying the rdms, however, every time
%                     button has been pressed during coherent motion period,
%                     the remaining frames of coherent motion have to be
%                     replaced by incoherent motion which is drawn from
%                     another vector that is generated when the flag = 1
%                     (continuous motion task only)
% passbandfreq      - passbandfreq for lowpass filtering
%                     fluctuations of coherences during incoherent motion
%                     periods (continuous motion task only)
% stopbandfreq      - stopandfrequencey for low pass filtering incoherent
%                     motion periods (continuous motion task only)
% passrip           - passrip for low pass filtering incoherent
%                     motion periods (continuous motion task only)
% stopbandatten     - stopandattenuation for low pass filtering incoherent
%                     motion periods (continuous motion task only)
% framerate         - sampling rate (= screen frame rate)
%                     for low pass filtering incoherent motion periods
%                     (continuous motion task only)
% nosie_amplitude   - scalar scaling the low pass filtered incoherent
%                     motion coherences (continuous motion task only)
% mean_duration     - in case incoherent motion periods are generated by
%                     drawing steps from an exponential function when
%                     coherence values change, this is the mean duration
%                     before a step occurs
% sd_duration       - ???
% noise_function    - ???
% stim_function     - ???
%   mean_vcoh       = proportion of dots you want to move vertically
%   mean_vcoh_sd    = the standard deviation of mean_coh
%   mean_vfreq      = mean frequency of vertical motion periods (as a *number
%                     per block*, e.g. if mean_freq == 5, then on average 
%                     there will be 5 vertical motion periods per block)               
%   mean_vfreq_sd   = the standard deviation of mean_freq
%   mean_vlength    = mean length of vertical motion periods *in frames*
%   mean_vlength_sd = the standard deviation of mean_length
%   step_v          = speed of vertical movement *in pixels/frame*
%   ap_radius       = radius of aperture (used to return dots if they move
%                     out of annulus)
% 
% Output:
% xy                = 2xNdxf matrix, where first row is x position and,
%                     second row is y position for number of dots (Nd) for
%                     each frame (f) (therefore EACH DOT has its OWN X/Y
%                     coordinates for EACH frame)
% coherence_frame   = vector, as long as the entire task (each cell
%                       represents a different frame) with each cell having
%                       a coherence value (i.e. this describes the
%                       coherences in all frames, both for coherent and
%                       incoherent motion)
% mean_coherence    = vector of zeros for incoherent motion periods and the level of
%                     coherence at periods of coherent motion for each frame
%                     (for continuous task version only)
% mean_coherence_v  = like above, but for VMPs
% pre_incoh_mo_coh  = vector with incoherent motion frames for incoherent
%                     motion periods before coherent motion periods during
%                     discrete trials
% blocks_shuffled   = vector, only returned for continuous trials (if
%                       discrete, returns empty vector i.e. []) 

% Maria Ruesseler, University of Oxford, 2018

% here we pre-allocate frames 
pre_incoh_mo_coh = [];

if discrete_trials == 1 % if we are moving dots for discrete trials
    blocks_shuffled = [];
    xy = zeros(2,Nd,total_frames); % set up a 3D (2xNdxtotal_frames) matrix
                                   % for x-y positions, which will be part
                                   % of output
    
    % pre_allocate frames for incoh motion before actual stim starts
    pre_incoh_mo_coh = zeros(pre_incoh_mo,1);

    for i = 1:3 % random dot positions for first frame of each dot set
        xy(:,:,i) = xypos(Nd, ap_radius); % create random positions 
                                          % (xypos() function defined 
                                          % below)
    end
elseif discrete_trials == 2 
     blocks_shuffled = [];
     xy = zeros(2,Nd,total_frames);
    
    % pre_allocate frames for incoh motion before actual stim starts
    pre_incoh_mo_coh = zeros(pre_incoh_mo,1);
    
    for i = 1:3 % random dot location for first frame of each dot set
        xy(:,:,i) = xypos(Nd, ap_radius);
    end

    % create coherence vectors (i.e. vectors which are as long as the frame
    % length of either coherent or incoherent motion periods and contain
    % the coherence value at every frame)
    [disc_coherence_vec] = calculate_coherence_vec(total_frames,sd_duration(2),mean_duration(2),coherence_sd(2),coherence_list(trial),[], [], stim_function, S.vp.min_duration, S.vp.max_duration); 
    [disc_incoherence_vec] = calculate_coherence_vec(pre_incoh_mo,sd_duration(1),mean_duration(1),coherence_sd(1),0,[], [], stim_function, S.vp.min_duration, S.vp.max_duration); 
    % combine both into one vector
    discrete_trial_vec = [disc_incoherence_vec; disc_coherence_vec];
    % Do the same for vertical motion, if flagged.
    % mean coherence is not needed, so just set to zero
    mean_coherence_v = zeros(ITIS_vec(1),1);
    if vert_motion == 1
        [disc_coherence_vec_v] = calculate_coherence_vec(total_frames,sd_duration(2),mean_duration(2),coherence_sd(2),coherence_list(trial),[], [], stim_function, S.vp.min_duration, S.vp.max_duration); 
        [disc_incoherence_vec_v] = calculate_coherence_vec(pre_incoh_mo,sd_duration(1),mean_duration(1),coherence_sd(1),0,[], [], stim_function, S.vp.min_duration, S.vp.max_duration); 
        % combine both into one vector
        coherence_frame_v = [disc_incoherence_vec_v; disc_coherence_vec_v];
    else
        coherence_frame_v = zeros(total_frames+pre_incoh_mo, 1);
    end
else % if we are moving dots for continuous trials
    xy = zeros(2,Nd,total_frames); % simply set the x-y matrix to all zeroes (for now)
end % diskreite trials

idx = 1; % index to loop through incoherent motion periods (first frame of
         % incoherent motion period)
idx_v = 1; % same, but for VMPs

tr = 1;  % index to loop through coherent motion periods
tr_v = 1; % same, but for VMPs

% design filter to lowpass filter noise 
% sample rate is screen refresh rate
ft = designfilt('lowpassfir', 'PassbandFrequency', passbandfreq, 'StopbandFrequency', stopbandfreq,...
    'PassbandRipple', passrip, 'StopbandAttenuation', stopbandatten, 'SampleRate', framerate);

%%% CALCULATE COHERENCE/INCOHERENCE PER FRAME %%%
% (continuous trials only) Now, we take the 'epochs' we had calculated
% earlier (in init_task_param(), using calculate_epoch_lengths()) and give
% each ITI and coherent motion period a mean coherence and each frame an
% individual coherence
if ~discrete_trials
    if noise == 0 % if we are not generating a noise vector for replacing 
                  % coherence motion after button press
        for i = 1:numel(ITIS_vec) % loop through incoherent motion periods 
            % of a block, generating an incoherence vector for each (i.e.
            % a vector containing a coherence value per frame of current
            % iteration of incoherent motion period) with certain mean
            % coherence, sd, etc. which we set
            incoh_filtered = calculate_coherence_vec( ITIS_vec(i), ...
                sd_duration(1), mean_duration(1), ...
                coherence_sd(1), 0, ft, noise_amplitude,...
                noise_function, S.vp.min_duration, S.vp.max_duration );

            % get idx of last frame of this period of incoherent motion
            end_of_incoh_mot = idx + ITIS_vec(i)-1;
            
            % set incoherent motion period in mean_coherence vector to a 
            % mean coherence of 0
            mean_coherence(idx:end_of_incoh_mot) = zeros(ITIS_vec(i),1);
            blocks_shuffled(idx:end_of_incoh_mot) = zeros(ITIS_vec(i),1);
            % fill the same epoch with the filtered incoherent motion in 
            % the coherence_frame vector
            coherence_frame(idx:end_of_incoh_mot) = incoh_filtered;
            
            % calculate first idx of coherent motion period
            first_coh_mot_f = idx + ITIS_vec(i);
            
            % calculate last idx of coherent motion period
            % last_coh_mot_f = first_coh_mot_f + integration_long -1;
            
            %%% ADD COHERENT MOTION PERIOD AFTER EACH ITI (except last) %%%
            if i < numel(ITIS_vec) % if we are not in last incoherent motion period
                % before block ends, add coherent motion period right after
                % last incoherent motion period
                mean_coh_vec = ...
                    calculate_coherence_vec( integration_long+1, ...
                    sd_duration(2), mean_duration(2), coherence_sd(2), ...
                    blocks_coherence_cells(tr), [], [], stim_function, ...
                    S.vp.min_duration, S.vp.max_duration);

                % last frame of last coherent motion period (just added)
                last_coh_mot_f = first_coh_mot_f + length(mean_coh_vec) -1;
                
                % update output variables with adjustments just made
                coherence_frame(first_coh_mot_f:last_coh_mot_f) = mean_coh_vec;
                % now set the mean coherence (blocks_coherence_cells(x)
                % contains the coh. value for each block, returned by
                % calculate_epoch_lengths())
                mean_coherence(first_coh_mot_f:last_coh_mot_f) = zeros(length(mean_coh_vec),1)+ blocks_coherence_cells(tr);
                blocks_shuffled(first_coh_mot_f:last_coh_mot_f) = zeros(length(mean_coh_vec),1) + tr; 
            end
            idx = last_coh_mot_f + 1; % update first frame of next incohrent motion period
            tr = tr + 1; % update trial for next coherent motion period
        end
        
        %%% SAME THING, BUT FOR VERTICAL MOTION %%%
        if vert_motion == 1
            for i = 1:numel(iti_vec_v)
                incoh_filtered = calculate_coherence_vec( iti_vec_v(i), ...
                    sd_duration(1), mean_duration(1), ...
                    coherence_sd(1), 0, ft, noise_amplitude,...
                    noise_function, S.vp.min_duration, ...
                    S.vp.max_duration );

                % get idx of last frame of this period of incoherent motion
                end_of_incoh_mot = idx_v + iti_vec_v(i)-1;

                % set incoherent motion period in mean_coherence vector to a 
                % mean coherence of 0
                mean_coherence_v(idx_v:end_of_incoh_mot) = zeros(iti_vec_v(i),1);
                blocks_shuffled_v(idx_v:end_of_incoh_mot) = zeros(iti_vec_v(i),1);
                % fill the same epoch with the filtered incoherent motion in 
                % the coherence_frame vector
                coherence_frame_v(idx_v:end_of_incoh_mot, 1) = incoh_filtered;

                % calculate first idx of coherent motion period
                first_coh_mot_f = idx_v + iti_vec_v(i);

                %%% ADD COHERENT MOTION PERIOD AFTER EACH ITI (except last) %%%
                if i < numel(iti_vec_v) % if we are not in last incoherent motion period
                    % before block ends, add coherent motion period right after
                    % last incoherent motion period
                    mean_coh_vec = ...
                        calculate_coherence_vec( integration_long+1, ...
                        sd_duration(2), mean_duration(2), coherence_sd(2), ...
                        cohs_v(tr_v), [], [], stim_function, ...
                        S.vp.min_duration, S.vp.max_duration );

                    % last frame of last coherent motion period (just added)
                    last_coh_mot_f = first_coh_mot_f + length(mean_coh_vec) -1;

                    % update output variables with adjustments just made
                    coherence_frame_v(first_coh_mot_f:last_coh_mot_f, 1) = mean_coh_vec;
                    % now set the mean coherence (blocks_coherence_cells(x)
                    % contains the coh. value for each block, returned by
                    % calculate_epoch_lengths())
                    mean_coherence_v(first_coh_mot_f:last_coh_mot_f) = zeros(length(mean_coh_vec),1) + cohs_v(tr_v);
                    blocks_shuffled_v(first_coh_mot_f:last_coh_mot_f) = zeros(length(mean_coh_vec),1) + tr_v; 
                end
                idx_v = last_coh_mot_f + 1; % update first frame of next incohrent motion period
                tr_v = tr_v + 1; % update trial for next coherent motion period
            end
        else
            mean_coherence_v = zeros(length(mean_coherence), 1);
            coherence_frame_v = zeros(length(mean_coherence), 1);
        end
    else % if creating noise vector from which we draw frames when 
         % participant has pressed button
        noise_vec = calculate_coherence_vec( ITIS_vec(1), ...
            sd_duration(1), mean_duration(1), coherence_sd(1), 0, ft, ...
            noise_amplitude, noise_function, S.vp.min_duration, ...
            S.vp.max_duration);

        mean_coherence = zeros(ITIS_vec(1),1);
        % ensure vertical mean coherence is also zero
        mean_coherence_v = zeros(ITIS_vec(1),1);
        coherence_frame = noise_vec;
        coherence_frame_v = noise_vec;
        
        total_frames = size(noise_vec,1); 
    end % if noise vector
    %% FIGURE THIS OUT! It's a bug, and shouldn't have to be patched up like
    % this! (mean_coherence_v is often shorter than mean_coherence for
    % some reason...)
    if length(mean_coherence) ~= length(mean_coherence_v)
        mean_coherence_v(end:length(mean_coherence)) = 0; % just add more 0s
    end
    if length(coherence_frame) ~= length(coherence_frame_v)
        coherence_frame_v(end:length(coherence_frame)) = 0; % just add more 0s
    end
end % if ~discrete trials

if discrete_trials > 0 % but if we have discrete trials...
    total_frames = total_frames + pre_incoh_mo; 
end 

%% LOOPING THROUGH FRAMES to SET DOT X-Y POS'N FOR EACH FRAME %%%

% debug (REMOVE!)
% coherence_frame(1:end) = 0.5;
% coherence_frame_v(1:end) = 1;
% to follow how the 'b' value evolves over time
b_vector = zeros(1, length(coherence_frame));
% to follow how many dots there are moving either horizontally or
% vertically (summing both vectors should equal Nd, the number of dots,
% ALWAYS)
% num_x_movers = zeros(1, length(coherence_frame));
% num_y_movers = zeros(1, length(coherence_frame));
% to follow how many dots escaped each frame
% num_x_escaped = zeros(1, length(coherence_frame));
% num_y_escaped = zeros(1, length(coherence_frame));
% overlap = 0;

for f = 1:total_frames
    % infer the coherence for the current frame from the relevant
    % coherence_frame vector (both for horizontal and vertical movement)
    if discrete_trials == 1
        if f <= pre_incoh_mo % incoherent motion at start of trial with certain sd
            pre_incoh_mo_coh(f) = 0;
            coherence = pre_incoh_mo_coh(f);
        else % if incoherent phase over show coherent motion
            coherence = coherence_list(trial);
        end
    elseif discrete_trials == 2 
        coherence = discrete_trial_vec(f); 
        coherence_v = coherence_frame_v(f, 1);
    else % if continuous
        coherence = coherence_frame(f);
        coherence_v = coherence_frame_v(f, 1);
    end
    
    % if coherence negative, change motion direction and turn coherence in
    % positive number
    if coherence < 0
        x_dir = -1;
    else
        x_dir = 1;
    end
    if coherence_v < 0
        y_dir = -1;
    else
        y_dir = 1;
    end

    % move dots - but first determine whether dots move in coherence
    % direction or randomly
    coh_prob = rand(1,Nd);
    
    % index vectors to noise, signal_x, and signal_y dots
    % NB. signal_x and signal_y dots are *not* allowed to be the same dots
    index_signal_x = find(coh_prob <= abs(coherence));
    % ensure (horizontal coherence + vertical coherence) is always <= 1
    if (abs(coherence) + abs(coherence_v) > 1)
        % if it's > 1, then vertical coherence must be exactly the
        % difference between horizontal coherence and 100%
        new_coherence_v = 1 - abs(coherence);
        coherence_v = (coherence_v/abs(coherence_v))*new_coherence_v;
        coherence_frame_v(f) = coherence_v;
        % therefore, after this block of code, coherence_v (B below) can
        % never be larger than 1-coherence (i.e. 1-A)
    end
    
    % Find proportion of noise dots moving vertically which is equivalent
    % to proportion of all dots moving vertically
    % A = coherence (signal dots)
    % 1-A = noise dots
    % B = coherence_v
    % b = proportion of vertically moving noise dots equal in amount to
    % proportion of vertically moving all dots.
    % also just in case coherence == 0, we set b manually to 1 so it
    % doesn't NaN and mess up things
    if abs(coherence) ~= 1
        b = abs(coherence_v)/(1-abs(coherence));
    else
        b = 1;
    end
    b_vector(1, f) = b;
    % create coh_prob values for vertical motion for only noise dots
    coh_prob_v_unassigned = rand(1, Nd-length(index_signal_x));
    % assign *each* dot a vertical coherence (5 for horizontal moving dots)
    coh_prob_v = 5*ones(1, Nd);
    % those dots which aren't horizontal moving get assigned the vertical
    % coherences
    coh_prob_v(coh_prob > abs(coherence)) = coh_prob_v_unassigned;
    % we now have a coh_prob_v vector (length = number of total dots) whose
    % value at each index (dot) is either 1 (dot will be moving
    % horizontally during some coherent motion periods) or some value less
    % than one, which is used to see whether it will be moving vertically
    % and in which vertical coherence periods.
    % now retrieve the indices of vertical moving dots
    index_signal_y = find(coh_prob_v <= abs(b));% return an array of 
    % which dots will be vertical moving dots
    index_noise = coh_prob > abs(coherence);
    %index_noise_y = (coh_prob > abs(coherence) & rescaled > abs(coherence_v));
    
    % check to see if any intersections...
    if length(intersect(index_signal_x, index_signal_y)) > 0
        overlap = overlap + 1;
    end
    
    % debug (saves number of horz-moving and vert-moving dots per frame)
    % num_x_movers(1, f) = length(index_signal_x);
    % num_y_movers(1, f) = length(index_signal_y);
    
    %%% MOVE DOTS %%%
    % Move noise dots
    xy(:,index_noise,f) = xypos(sum(index_noise), ap_radius);
    
    % Move signal dots - but only if we are above 3 frames because every
    % set of dots is shown only on every 3rd frame, otherwise all dots move
    % randomly. Note that each third frame copies and modifies the
    % positions of the one three frame previous.
    if f > 3
        xy(1,index_signal_x,f) = xy(1,index_signal_x,f-3) + (step * x_dir * 3); % change X position of each signal dot
        xy(1,index_signal_y,f) = xy(1,index_signal_y,f-3); % but not for vertical dots
        xy(2,index_signal_x,f) = xy(2,index_signal_x,f-3); % maintain Y position for horizontal dots...
        xy(2,index_signal_y,f) = xy(2,index_signal_y,f-3) + (step * y_dir * 3); % but not for vertical dots
    else
        xy(:,index_signal_x,f) = xypos(numel(index_signal_x), ap_radius); % set up dots' position in first three frames
    end % if f > 3
    
    % check whether dot crossed apperture, if dot crossed aperture -
    % re-plot at random location on opposite side of moving direction
    % outside the aperture then move dot with a random distance back into
    % the aperture
    
    % calculate distance to aperture centre
    distance_x_centre = sqrt(xy(1,index_signal_x,f).^2 + xy(2,index_signal_x,f).^2);
    distance_y_centre = sqrt(xy(1,index_signal_y,f).^2 + xy(2,index_signal_y,f).^2);
    
    % get INDICES OF signal dots that have a distance greater than the 
    % radius meaning that they are outside the aperture
    idx_dist_x = index_signal_x(distance_x_centre >= ap_radius);
    idx_dist_y = index_signal_y(distance_y_centre >= ap_radius);
    %tangent_dots_x = zeros(2, size(idx_dist_x, 2));
    
    if ~isempty(idx_dist_x) % if X dots moved outside apperture
         xy(2,idx_dist_x,f) = 2 .* ap_radius .* rand(size(idx_dist_x)) - ap_radius;
         xy(1,idx_dist_x,f) = sqrt((ap_radius^2) - (xy(2,idx_dist_x,f).^2) );
        
        % move signal dots back into aperture
        xy(1,idx_dist_x,f) = xy(1,idx_dist_x,f) - rand(size(idx_dist_x)) .* step;
        
        % needs to be mirrored if coherence is positive
        if x_dir > 0 % | frame_vector(1, f) < 0
            xy(1,idx_dist_x,f) = - xy(1,idx_dist_x,f);
        end
    end % if dots moved outside apperture
    
    if ~isempty(idx_dist_y) % if Y dots moved outside apperture
        xy(1,idx_dist_y,f) = 2 .* ap_radius .* rand(size(idx_dist_y)) - ap_radius; % assign random X value
        xy(2,idx_dist_y,f) = sqrt((ap_radius^2) - (xy(1,idx_dist_y,f).^2) ); % place on edge of ring
        
        % move signal dots back into aperture
        xy(2,idx_dist_y,f) = xy(2,idx_dist_y,f) - rand(size(idx_dist_y)) .* step_v;
        
        % needs to be mirrored if coherence is positive
        if y_dir > 0
            xy(2,idx_dist_y,f) = -xy(2,idx_dist_y,f);
        end
    end % if dots moved outside apperture
    
    % debug (saves number of escaped horz-movers and vert-movers)
    % num_x_escaped(1, f) = length(idx_dist_x);
    % num_y_escaped(1, f) = length(idx_dist_y);
end % loop through frames

end % main function

%% additional functions
% xypos function - creates randomised x and y coordinates for n number of
% dots, for a given aperture radius r. It does this by giving each dot a
% random radius (between 0 and r) and a random angle (between 0 and 2pi
% radians, which corresponds to between 0 and 360 degrees). Then, it uses
% trigonometric functions through the Pythagorean theorem to convert these
% to X/Y positions and assign them to the dot.

% Returns a 2xn double, with rows for x and y coordinates, and one column 
% for each dot

function [XY] = xypos(n, r)

% create random angle (in radians) for EACH dot
theta = 2*pi*rand(1,n);

% create random radius (in pixels) for EACH dot
radius = r * sqrt(rand(1,n));

% back to cartesian coordinate system
XY = [radius.*cos(theta); radius.*sin(theta)];

end %xypos
