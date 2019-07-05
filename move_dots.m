function [xy,coherence_frame,mean_coherence,pre_incoh_mo_coh,blocks_shuffled] = ...
    move_dots(discrete_trials,trial,total_frames,ap_radius,...
    coherence_sd,direction_org,step,Nd,pre_incoh_mo,...
    mean_coherence,blocks_coherence_cells,coherence_frame,...
    coherence_list,ITIS_vec,integration_long,noise,passbandfreq,...
    stopbandfreq,passrip,stopbandatten,framerate,noise_amplitude,...
    mean_duration,sd_duration,noise_function,stim_function, mean_vcoh, ...
    mean_vcoh_sd, mean_vfreq, mean_vfreq_sd, mean_vlength, mean_vlength_sd, ...
    step_v)

% This function creates the dots' X/Y positions for discrete trials or 
% continuous blocks of motion and saves those coordinates for *each* frame.
% THus, every dot has its own X/Y coordinates for each frame, and
% all of this is saved in the matrix 'xy' which is output. This matrix is
% then used to render all the dots in either discrete_rdk_trials_training
% (when doing discrete trials) or present_rdk (when doing continous trials)
%
% Two types of dots: SIGNAL dots (which move in a specific direction during
% a trial, i.e. during "coherence") and NOISE dots (which just move
% randomly)
%
% NB. The stimulus is coded in a way that there are 3 sets of dots, whose
% positions are calculated randomly each for the first three frames, and 
% every set of dots is "reshuffled" (noise dots) and moved (signal dots)
% every third frame, depending on the positions of its dots three frames
% previous.
% 
% Neb to Maria: I have added extra parameters to this function (detailed
% below). The y-movement code that I have added works like this:
%   1. Decides how many VMPs (vertical movement periods) there will be in
%      the block (using mean_vfreq and mean_vfreq_sd).
%   2. Decides how long those VMPs will be, including how long the ITIs
%      (i.e. periods in-between VMPs) will be.
%   3. Creates a frame_vector which is a vector, as long as all of the
%      frames in the block, and for each frame assigns either 0 (no
%      y-movement), 1 (upwards movements) or -1 (downwards movement).
%   4. In the same FOR loop that you coded (going through all the frames to
%      change the X position) I added code which changes the Y position of
%      each dot as well, as long as the equivalent frame in frame_vector is
%      either 1 or -1.
%   5. Brings dots back if they escape the annulus (this is bugged--I am
%      trying to fix this now).
%
% Input:

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
%
%%% Input (continued, but for Y movement)
%   mean_vcoh       = proportion of dots you want to move vertically
%
%   mean_vcoh_sd    = the standard deviation of mean_coh
%
%   mean_vfreq      = mean frequency of vertical motion periods (as a *number
%                     per block*, e.g. if mean_freq == 5, then on average 
%                     there will be 5 vertical motion periods per block)
%                   
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
% coherence_frame   = vector with coherence
%                     values during incoherent and coherent motion periods
%                     for each frame
% mean_coherence    = vector of zeros for incoherent motion periods and the level of
%                     coherence at periods of coherent motion for each frame
%                     (for continuous task version only)
% pre_incoh_mo_coh  = vector with incoherent motion frames for incoherent
%                     motion periods before coherent motion periods during
%                     discrete trials
% blocks_shuffled   = vector, only returned for continuous trials (if
%                       discrete, returns empty vector i.e. []) 

% Maria Ruesseler, University of Oxford, 2018



% here we pre-allocate frames 
pre_incoh_mo_coh = [];

% Neb note to self: remember to check if discrete_trials == 2 is even set
% anymore (I just remember it being either 0 or 1, always)

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
    [disc_coherence_vec] = calculate_coherence_vec(total_frames,sd_duration(2),mean_duration(2),coherence_sd(2),coherence_list(trial),[], [], stim_function); 
    [disc_incoherence_vec] = calculate_coherence_vec(pre_incoh_mo,sd_duration(1),mean_duration(1),coherence_sd(1),0,[], [], stim_function); 
     
    % combine both into one vector
    discrete_trial_vec = [disc_incoherence_vec; disc_coherence_vec];
else % if we are moving dots for continuous trials
    xy = zeros(2,Nd,total_frames); % simply set the x-y matrix to all zeroes (for now)
end % diskreite trials

idx = 1; % index to loop through incoherent motion periods (first frame of
         % incoherent motion period)
tr = 1;  % index to loop through coherent motion periods

% design filter to lowpass filter noise 
% sample rate is screen refresh rate
ft = designfilt('lowpassfir', 'PassbandFrequency', passbandfreq, 'StopbandFrequency', stopbandfreq,...
    'PassbandRipple', passrip, 'StopbandAttenuation', stopbandatten, 'SampleRate', framerate);

% now we calculate which frames have coherent and incoherent motion
% (continous trials only)
if ~discrete_trials
    if noise == 0 % if we are not generating a noise vector for replacing coherence motion after button press
        for i = 1:numel(ITIS_vec) % loop through incoherent motion periods of a block
            incoh_filtered = calculate_coherence_vec(ITIS_vec(i),sd_duration(1),mean_duration(1),...
                coherence_sd(1),0,ft, noise_amplitude,...
                noise_function);

            % get idx of last frame of this period of incoherent motion
            end_of_incoh_mot = idx + ITIS_vec(i)-1;
            
            % set incoherent motion period in mean_coherence vector to a 
            % mean coherence of 0
            mean_coherence(idx : end_of_incoh_mot)= zeros(ITIS_vec(i),1); % incoh_motion mean for ITIS interval
            blocks_shuffled(idx : end_of_incoh_mot)= zeros(ITIS_vec(i),1);
            % fill the same epoch with the filtered incoherent motion in 
            % the coherencne_frame vector
            coherence_frame(idx:end_of_incoh_mot) = incoh_filtered;
            
            % calculate first idx of coherent motion period
            first_coh_mot_f = idx + ITIS_vec(i);
            
            % calculate last idx of coherent motion period
            % last_coh_mot_f = first_coh_mot_f + integration_long -1;
            
            if i < numel(ITIS_vec) % if we are not in last incoherent motion period
                % before block ends add coherent motion period onto last incoherent motion period

                mean_coh_vec = ...
                    calculate_coherence_vec(integration_long+1,sd_duration(2),mean_duration(2),coherence_sd(2),...
                    blocks_coherence_cells(tr),[], [], stim_function);

                last_coh_mot_f = first_coh_mot_f + length(mean_coh_vec) -1;
                
                %mean_coherence(first_coh_mot_f :last_coh_mot_f )= mean_coh_vec;
                coherence_frame(first_coh_mot_f:last_coh_mot_f)= mean_coh_vec;
                mean_coherence(first_coh_mot_f :last_coh_mot_f )= zeros(length(mean_coh_vec),1)+ blocks_coherence_cells(tr);
                blocks_shuffled(first_coh_mot_f :last_coh_mot_f )= zeros(length(mean_coh_vec),1) + tr; 
                %      coherence_frame(first_coh_mot_f:last_coh_mot_f)= blocks_coherence_cells(tr);
            end
            %
            %
            idx = last_coh_mot_f + 1; % update first frame of next incohrent motion period
            tr = tr + 1; % update trial for next coherent motion period
        end
        %
    else % if creating noise vector from which we draw frames when participant has pressed button
        noise_vec = calculate_coherence_vec(ITIS_vec(1),sd_duration(1),mean_duration(1),...
            coherence_sd(1),0,ft, noise_amplitude,...
            noise_function);

        mean_coherence = zeros(ITIS_vec(1),1);
        coherence_frame = noise_vec;
        
        total_frames = size(noise_vec,1); 
    end % if noise vector
end % if ~discrete trials

if discrete_trials > 0 % but if we have discrete trials...
    total_frames = total_frames + pre_incoh_mo; 
end 

%% Vertical motion code (Maria, you should read below this--this is what I wrote)

block_length = size(xy, 3); % get total number of frames in block
coherence_v = normrnd(mean_vcoh, mean_vcoh_sd); % get coherence for these VMPs
% disp(['Coherence: ' num2str(coherence)]);

frame_vector = zeros(1, block_length); % create initial frame vector

%%% CALCULATE VERTICAL MOTION PERIODS (VMPs)
% calculate amount of VMPs in this block (from distribution)
number_vmps = round(normrnd(mean_vfreq, mean_vfreq_sd));

vmp = zeros(number_vmps, 1); % preallocate vmp for speed
% calculate amount of ITIs (between VMPs)
iti = zeros(number_vmps+1, 1); % +1 because there is always an ITI at beginning

for i = 1:number_vmps
    % give each VMP a length sampled from a normal distribution
    vmp(i,1) = round(normrnd(mean_vlength, mean_vlength_sd)); 
end

% Determine ITI lengths
vmp_total_frames = sum(vmp(:, 1)); % sum of VMP lengths in frames
% determine mean ITI frame length
iti_mean_frames = round((block_length - vmp_total_frames)/size(iti, 1));
% NB. Haven't got this script to work with discrete trials yet, only
% continuous
if iti_mean_frames <= 0
    disp('ERROR: init_mean_frames <= 0!');
    keyboard
elseif vmp_total_frames >= block_length
    disp('ERROR: vmp_total_Frames >= block_length!');
    keyboard
end

% Create each ITI with specific frame amount
for i = 1:size(iti, 1)
    length_decided = round(normrnd(iti_mean_frames, iti_mean_frames*.15)); 
    iti(i, 1) = iti(i, 1) + length_decided;
    if i ~= size(iti, 1) % unless we are on the last index...
        % add the excess or subtract the lack of frames (due to normrnd)
        % from our current ITI to the next one (if it exists). This helps
        % always balance (algebraically) the length of one ITI with the one
        % coming after it
        % Neb: might have to change this (i.e. don't "make up" for 
        % difference in length, because it could bias the experiments
        iti(i+1, 1) = iti(i+1, 1) + (length_decided - iti_mean_frames);
    end
end

first_frame = iti(1, 1) + 1; % determine first frame of first VMP

%%% ASSIGN VMPs TO FRAMES
for i = 1:number_vmps
    last_frame = first_frame + vmp(i, 1); % determine last frame of VMP
    % assign frames to vector, making them either upwards-moving (value 1)
    % or downwards-moving (value -1) w/ equal probability
    if randi(2) == 1 % going up
        frame_vector(1,first_frame:last_frame) = 1; % -1 = going up 
    else % going down
        frame_vector(1,first_frame:last_frame) = 1; % 1 = going down (remember the Y-axis on computers increases downwards)
    end
    
    % assign first frame of next VMP (for next loop iteration)
    first_frame = last_frame + iti(i+1,1) + 1;
end

%% LOOPING THROUGH FRAMES to SET DOT X-Y POS'N FOR EACH FRAME %%%

for f = 1:total_frames
    if discrete_trials == 1
        if f <= pre_incoh_mo % incoherent motion at start of trial with certain sd
            pre_incoh_mo_coh(f) = 0;
            coherence = pre_incoh_mo_coh(f);
        else % if incoherent phase over show coherent motion
            coherence = coherence_list(trial);
        end
    elseif discrete_trials == 2 
        coherence = discrete_trial_vec(f); 
    else % if continuous
        coherence = coherence_frame(f);
    end
    
    % if coherence negative, change motion direction and turn coherence in
    % positive number
    if coherence < 0
        x_dir = -1;
    else
        x_dir = 1;
    end

    % move dots - but first determine whether dots move in coherence
    % direction or randomly
    coh_prob = rand(1,Nd);
    
    % index vectors to noise and signal dots
    index_signal_x = find(coh_prob <= abs(coherence));
    index_signal_y = find(coh_prob <= abs(coherence_v));% return an array of 
    % which dots will be signal dots (those whose coh_prob is less or equal
    % to specified coherence for this trial, which comes from parameters)
    index_noise_x = coh_prob > abs(coherence);
    index_noise_y = coh_prob > abs(coherence_v);
    
    %%% MOVE DOTS %%%
    % Move noise dots
    xy(:,index_noise_x,f) = xypos(sum(index_noise_x), ap_radius);
    
    % Move signal dots - but only if we are above 3 frames because every
    % set of dots is shown only on every 3rd frame, otherwise all dots move
    % randomly. Note that each third frame copies and modifies the
    % positions of the one three frame previous.
    if f > 3
        xy(1,index_signal_x,f) = xy(1,index_signal_x,f-3) + (step * x_dir * 3); % change X position of each signal dot
        xy(2,index_signal_x,f) = xy(2,index_signal_x,f-3); % maintain Y position...
        xy(2,index_signal_y,f) = xy(2,index_signal_y,f-3) + (step * frame_vector(1,f) * 3); % ...unless you're moving vertically
    else
        xy(:,index_signal_x,f) = xypos(numel(index_signal_x), ap_radius); % set up dots' position in first three frames
    end % if f > 3
    
    % check whether dot crossed apperture, if dot crossed aperture -
    % re-plot at random location on opposite side of moving direction
    % outside the aperture then move dot with a random distance back into
    % the aperture
    
    % calculate distance to aperture centre
    distance_x_centre = sqrt(xy(1,index_signal_x,f).^2 + xy(2,index_signal_x,f).^2);
    
    % get INDICES OF signal dots that have a distance greater than the 
    % radius meaning that they are outside the aperture
    idx_dist_x = index_signal_x(distance_x_centre >= ap_radius);
    idx_dist_y = index_signal_y(distance_x_centre >= ap_radius);
    tangent_dots_x = zeros(2, size(idx_dist_x, 2));
    
    if ~isempty(idx_dist_x) % if dots moved outside apperture
        % replex y and x coordinates of the dots to a place on the opposite
        % site of the aperture
        
        % need this for division below...
        ap_radius_matrix = zeros(1, size(distance_x_centre, 2));
        ap_radius_matrix(1, 1:size(distance_x_centre)) = ap_radius;
        
        % calculate tangent equivalents for each dot
        tangent_dots_x(1,:) = (ap_radius_matrix ./ distance_x_centre(1, idx_dist_x)) .* xy(1, idx_dist_x, f); % X
        tangent_dots_x(2,:) = (ap_radius_matrix ./ distance_x_centre(1, idx_dist_x)) .* xy(2, idx_dist_x, f); % Y
        
        % and reflext to other side
        xy(1, idx_dist_x, f) = -tangent_dots_x(1, :); % reflect X
        xy(2, idx_dist_x, f) = -tangent_dots_x(2, :); % reflect Y
        
%         xy(2,idx_dist_x,f) = 2 .* ap_radius .* rand(size(idx_dist_x)) - ap_radius;
%         xy(1,idx_dist_x,f) = sqrt((ap_radius^2) - (xy(2,idx_dist_x,f).^2) );
        
        % move signal dots back into aperture
        xy(1,idx_dist_x,f) = xy(1,idx_dist_x,f) - rand(size(idx_dist_x)) .* step;
        
        % needs to be mirrored if coherence is positive
        if x_dir > 0 % | frame_vector(1, f) < 0
            xy(1,idx_dist_x,f) = - xy(1,idx_dist_x,f);
        end
    end % if dots moved outside apperture
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
