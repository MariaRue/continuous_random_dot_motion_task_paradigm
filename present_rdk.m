function [S,respMat,tconst] = present_rdk(S, tconst,training,outdir,outfile,rewardbar,EEG,elink,diode,annulus,fixdisp)
% This function displays continuous rdks, records subject responses and
% gives feedback to the subject

% Input:
%       S = structure with stimulus information
%       tconst = structure with PTB parameters
%       outdir = folder in which behavioural performance is saved
%       outfile = name of file in which behavioural response is saved
%       rewardbar = flag, if 1 a reward bar is shown below stimulus, that
%       fills up by reaching sixty points which equals 0.15£

% Output: respMat = response matrix, as described in
% rdk_continuyous_motion.mat - also saves respMat, tconst, S in file
% specified in outfile and saves a reward_info.mat which is a file that
% contains info about how much reward has been earned in a session that is
% built on in the next session

% Open window

%%%--- SETUP: screens ---%%%
if S.debug == 2 || S.debug == 3
    flipt = Screen('Preference', 'SkipSyncTests',1);% 0 should be preferred but synch
    % problems on mac prohibit that. Exact synchronization not necessary because
    % integration across frames not measured as in single neuron electrophys
else
    flipt = Screen('Preference', 'SkipSyncTests',0);% 0 should be preferred but synch
    %     % problems on mac prohibit that. Exact synchronization for EEG experiment
end


if S.debug == 0 % hide cursor and suppress keyboard input in command window
    HideCursor;
end

PsychDefaultSetup(2);
screens = Screen('Screens');

% get correct screen number for screen on which we want to show task
tconst.winptr = max(screens);

%%%--- open window to display task ---%%%

% dev_mode=1 puts window in one corner of screen for easier debugging

if S.debug == 1 || S.debug == 3
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr,S.grey,[0 0 1048 786]);
else % use full screen window
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr, S.grey);
end
disp('Screen is set up.');

%%%---SETUP: key response ---%%%
% Define the keyboard keys that are listened for. Here, we use A and L
% as response keys
KbName('UnifyKeyNames');
% feedback on every trial
leftkey = KbName('A');
rightkey = KbName('L');

response_device = 'keyboard';
disp(['Response device is ' response_device '.']);
[keyboardIndices, ~, ~] = GetKeyboardIndices;

% different on mac and windows, mac gives two numbers, windows only one
% indes, also for some reason on my personal laptop I have to use the 2nd
% entry, for other mac users it might be the first one
if S.debug == 2 || S.debug == 3
    device_number = keyboardIndices(2); % mac keyboard
else
    device_number = keyboardIndices; % mac keyboard
end

% set time little point bar at end of reward bar is shown

S.rewardcountdown = 0;
% create queue to wait for button press from keyboard
KbQueueCreate(device_number(1));

missedflag = 0; % flag to signal that trial has been missed and that totalpoints have to be updated

%%%--- load reward matrix if exists if not create one---%%%

% This is the matrix saved in reward_info.mat that contains information
% about reward earned in this session which is starting point for next
% session (so that reward is carried over)

% check whether a reward_info file exists
reward_file = sprintf('sub%03.0f_reward_info.mat',S.vp.subid);
if exist(fullfile(outdir,reward_file),'file') % if it does, load it
    matrix = load(reward_file);
    reward_matrix = matrix.reward_matrix;
    S.coins_counter = reward_matrix(1,2); % money already won
    S.totalPoints = reward_matrix(1,1); % how far reward bar has been filled up in last session
else % if first session and reward matrix doesnt exist make one
    reward_matrix = zeros(1,2);
    S.coins_counter = 0;
    S.totalPoints = 0;
end % if reward_matrix exists


%%%% to save time call functions used in while loop through frames and call
%%%% all screen functions to draw different feedback shapes (Matlab needs a
%%%% little bit of time to find all functions and to draw feedback shapes
%%%% first time for some reason which leads to dropping frames)

% find moneybar function for reward bar
[S.coins_counter,S.x_rect_old,textcoin,centeredRect,centeredFrame,centeredrewardRect,S.totalPoints,reward_m] = ...
    moneybar(S.x_rect_old,S.coins_counter,S.rewbarsize,S.centre(1), ...
    S.centre(2),S.ap_radius,S.totalPoints,S.totalPointsbar,0,S.rewbarlocation);

Screen('FrameRect',tconst.win,S.black,centeredFrame,4); % display frame of bar always black
DrawFormattedText(tconst.win, textcoin, S.centre(1)+round(S.rewbarsize(1)/2)+30,...
    S.rewbarlocation(2), 0);

Screen('Flip',tconst.win);

DrawFormattedText(tconst.win, '', 'center', 'center', 0);
Screen('Flip',tconst.win);

if annulus
    S.annulusflag = 1;
    % calling annulus for first time for speed
    Screen('FillOval', tconst.win, S.grey, S.annulus_rect, S.annulus_diameter);
end
% calling reallocation first time for speed
recalculate_xy_position(S,1,0,1,1);

% reset frame sequence to original sequence and reset start_f
S.mean_coherence = S.mean_coherence_org;
S.coherence_frame = S.coherence_frame_org;

keydown = 0; % flag that keeps track whether a response has been made and
% rewardbar needs to be updated, if 1 then rewardbar needs updating

% pre-allocate cells to respMat matrix to record responses later on
respMat = cell (numel(S.vp.condition_vec),1);

%%%%%----- setup eye tracker at start of each session ------%%%%%%%

if elink % start eye tracker
    if EyelinkInit() ~= 1
        return
    end
    el = EyelinkInitDefaults(tconst.win);
    Eyelink('Command','binocular_enabled = YES');
    Eyelink('Command','pupil_size_diameter = YES');
    Eyelink('Command','file_sample_data = GAZE,AREA');
    Eyelink('Command','file_event_data = GAZE,AREA,VELOCITY');
    Eyelink('Command','file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK');
    Eyelink('Command','link_sample_data = GAZE,AREA');
    Eyelink('Command','link_event_data = GAZE,AREA,VELOCITY');
    Eyelink('Command','link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK');
    EyelinkDoTrackerSetup(el);
    eyefile = sprintf('s%dse%d',S.vp.subid,S.vp.session);
    
    ETfilename = eyefile; % define edf file name
    
    Eyelink('OpenFile',ETfilename);
    Eyelink('StartRecording');
end

Screen('TextFont',tconst.win,'Arial')

%%%%----- internal eye calibration -------%%%%%
% instructions for participant - button press leads to next display

if elink
    text = 'We will now calibrate the eyes for the task. \n Press any key to move on.';
    Screen('TextSize',tconst.win,25);
    Screen('TextStyle',tconst.win,1);
    DrawFormattedText(tconst.win, text, 'center', 'center', [0 0 0]);
    Screen('Flip', tconst.win);
    KbStrokeWait(device_number)
    
    text = 'Please follow the dot with your eyes.';
    DrawFormattedText(tconst.win, text, 'center', 'center', [0 0 0]);
    flipt=Screen('Flip', tconst.win);
    WaitSecs(1);
    
    flipt = internal_eye_calibration(tconst.win,tconst.pixperdeg,S.centre,flipt);
    
    % calibration finished, move on to main taks
    text = ['Thank you. We will now move onto the task.'];
    Screen('TextSize',tconst.win,25);
    Screen('TextStyle',tconst.win,1);
    DrawFormattedText(tconst.win, text, 'center', 'center', [0 0 0]);
    Screen('Flip', tconst.win, flipt+1.2);
    KbStrokeWait([device_number])
end % eyelink

%%%--- Task Instructions ---%%%

% Simply present the instruction to the user.
coher_motion_text = 'In this task you will see a continuous stream of randomly moving dots (trial periods).\n\n You will have to respond every time you think that the dots are going mostly to the left or the right. \n\n Use the A key if dots move to the left, and the L key if dots move to the right.';
block_info = ['You will do ',num2str(numel(S.vp.condition_vec)), ...
    ' blocks of ',num2str(S.vp.block_length), ' minutes each.\n\n At the beginning of each block, you will be told how frequent and how long trial periods will be.'];
feedback_info = ['After every button press you will be given feedback. \n\n The fixation dot in the centre of the moving dots will change its colour. \n\n You can win points for correct button presses and lose points for incorrect or missed button presses. \n\n Green: correct response during trial period \n\n Red: incorrect response during trial period \n\n Yellow: Response during random motion (too early) \n\n Blue: Missed trial period (too late)'];

DrawFormattedText(tconst.win, coher_motion_text, 'center', 'center', 0);
Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

DrawFormattedText(tconst.win, 'Please try to fixate on the fixation dot at all times!', 'center', 'center', 0);
Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

DrawFormattedText(tconst.win, block_info, 'center', 'center', 0);
Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

DrawFormattedText(tconst.win, feedback_info, 'center', 'center', 0);
Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

if training % task instructions
    training_text = 'The fix dot will change to white during trials.';
    DrawFormattedText(tconst.win, training_text, 'center', 'center', 0);
    Screen('Flip',tconst.win);
    KbStrokeWait(device_number) % next block starts after participant presses button
end

%%%--- START TASK ---%%%
block_time = tic; % time how long it takes to run a block - together with toc furter down at end of loop
% loop through the different blocks of different conditions of integration
% and intertrial interval (ITI) periods
for block = 1:numel(S.vp.condition_vec)
    if EEG
        % set up IO path for sending triggers  in EEG
        [trig.portobject, trig.portaddress] = OpenIOPort;
        
        trig.triggerlength = 0.010; % what does that mean? isn't that too long?
        trig.holdvalue = 0;
        io64( trig.portobject, trig.portaddress,0);
    elseif elink
        trig.holdvalue = 0;
    end % EEG
    
    % define triggers to be sent to EEG recorder
    
    S.trig.coherent_motion_fb_right = 201; % trigger that gets send everytime person hits right button during coherent motion
    S.trig.coherent_motion_fb_left = 205; % same, but for left
    S.trig.coherent_motion_missed = 203; % every time person missed to respond to coherent motion
    S.trig.resp_incoherent_motion_right = 202;% every time person pressed right button during incohrent motion
    S.trig.resp_incoherent_motion_left = 206;
    S.trig.trigger_per_10_secs = 11;% trigger for counting minutes and 10seconds of time passed
    S.trig.last_frame = 210; % trigger send on last frame
    S.trig.trigger_min = 12;% for updating trigger code every time minute is
    S.trig.incoh_motion = 23; % trigger for onset of incoh motion
    % full, full minute is a value between 11 and 19 that gets updated every
    % time a minute is hit, for 10seconds it is a 3 digit code starting at 102
    S.trig.jump = 24;
    
    trig_num = 0; % initialise counter for sending a trigger every S.trig_thresh jump
    
    %%%--- Display Block Information ---%%%
    
    % HideCursor;
    block_info = S.block_ID_cells{block};
    
    % Show info to subject about what kind of ITIs they will have (frequent
    % or infrequent trials) and trial length (short or long)
    % Here we first set the info_text according to block_info (originally 
    % from imported .csv parameters)
    switch block_info
        case '1'
            info_text = ['Block: ',num2str(block),...
                '\n\n Trials are frequent. \n\n Trial periods are short.'];
            shape = 'C';
            size = S.fixdiameter(1);
            Screen('Drawdots', tconst.win,[0 0],size, S.black, S.fixdotlocation, S.vp.dot_type)
        case '2'
            info_text = ['Block: ',num2str(block),...
                '\n\n Trials are frequent. \n\n Trial periods are long.'];
            shape = 'C';
            size = S.fixdiameter(2);
            Screen('Drawdots', tconst.win,[0 0],size, S.black, S.fixdotlocation, S.vp.dot_type)
        case '3'
            info_text = ['Block: ',num2str(block),...
                '\n\n Trials are NOT frequent. \n\n Trial periods are short.'];
            shape = 'S';
            size = S.square_centred_sm;
            Screen('FillRect', tconst.win, S.black, size)
        case '4'
            info_text = ['Block: ',num2str(block),...
                '\n\n Trial are NOT frequent. \n\n Trial periods are long.'];
            shape = 'S';
            size = S.square_centred_big;
            Screen('FillRect', tconst.win, S.black, size)
    end
    
    % Actually draw the info_text
    DrawFormattedText(tconst.win, info_text, 'center', S.centre(2)-200, 0);
    Screen('Flip',tconst.win);
    
    % Wait for (any) keyboard button
    KbStrokeWait(device_number);
    KbEventFlush(device_number);
    KbQueueStop(device_number);
    %%%--- Reset block parameters ---%%%
    
    resp_counter = 2; % index (idx) for counting rows in response Matrix
    tstart = 0; % used to get time on first coherent motion frame of a 
    % trial and to calculate rt later
    
    Fb.feedback_countdown = 0; % set to a certain number of frames for 
                               % which fb will be displayed
    trial = 0; % trial counter - needed to idx into epochs (trials) of 
               % coherent motion periods
    
    %%%--- SETUP: matrix for behavioural responses ---%%%
    respMat{block} = NaN(numel(S.blocks_coherence_cells{block})+50,8);
    
    KbQueueStart(device_number); % start recording button presses

    f = 1; % looping through frames idx
    S.start_frame_trial = 0; % save first trial frame in this matrix
    S.coh_f{block} = zeros(40,2);
    counter_coh = 1; % counter for this vector
    % idx into noise vector to fill up coherent motion frames after button
    % press
    start_f = 1;
    
    % set max priority level to PTB (all other processes on computer now
    % secondary)
    topPriorityLevel = MaxPriority(tconst.win);
    Priority(topPriorityLevel);
    
    % set keycounter for keypress matrix that saves which button has been
    % pressed when to 1
    keycounter = 1;
    
    % initialise keypress matrix to save all keypresses
    keypress = cell(100,3);
    
    %%%--- display coherent and incoherent motion for duration of total time---%%%
    
    % save how often we loop through the WHILE loop, and how long each 
    % loop takes
    
    all_while_calls = nan(S.totalframes_per_block+100,1);
    all_frames = nan(S.totalframes_per_block+100,1);
    stimonsettimes = nan(S.totalframes_per_block+100,1);
    missbeam = nan(S.totalframes_per_block+100,1);
    vbltimestamps = nan(S.totalframes_per_block+100,1);
    fliptimes = nan(S.totalframes_per_block+100,1);
    
    while_calls = 0;
    idx_last_trigger(1) = 1;
    while_loop_time = tic;
    S.blockstartsecs{block} = GetSecs;
    trigger_time_1 =   1; % save start time of stimulus for sending triggers every 10 sec
    trigger_time_min = 1; % save start time of stimulus for sending triggers every minute
    S.trigger_vals{block} = nan(S.totalframes_per_block,1);
    while f <= S.totalframes_per_block % loop through all frames of block
        
        if EEG || elink % set trigger back to 0 so that we can record next trigger
            current_trigger_value = trig.holdvalue;
            if f == 1 && (EEG || elink)  % send trigger on first frame of block this is first trigger of 10 secs interspersed triggers and is 11
                current_trigger_value = S.trig.trigger_per_10_secs; % send trigger
            end
            if f > 1
                % send trigger at start of incoherent motion period
                if  abs(S.mean_coherence_org{block}(f-1)) ~= 0 && abs(S.mean_coherence_org{block}(f)) == 0
                    current_trigger_value = S.trig.incoh_motion;
                end
                
                % send a trigger on every trig_thres jump of coherence (in
                % intertrial and trial periods) This is later used for matching the
                % eeg and behavioural recordings
                if  S.coherence_frame{block}(f) ~= S.coherence_frame{block}(f-1)
                    current_trigger_value = S.trig.jump;
                    trig_num = trig_num + 1;
                    if trig_num == S.vp.trig_thresh
                        trig_num = 0;
                    end
                end % check for occurance of jump
            end % if f > 1
        end % if EEG

        if f == S.totalframes_per_block && (EEG || elink)
            current_trigger_value = S.trig.last_frame; % send trigger
        end
        
        % send EEG trigger every 10 seconds
        trigger_time_2 = f; % this measures time that has passed and is used in the following
        % if statement whether 10 seconds since the last trigger have passed,
        % if so this time gets the new start time and the process repeats,
        % every time we have a full minute we update the minute variabe with time_2 value
        % and change the trigger to a 2 digit code (all other times a 3 digit code is used)
        % time is measured in number of frames
        if (EEG || elink) && trigger_time_2 >= trigger_time_1 + 600
            if trigger_time_2 >= trigger_time_min + 3600 % if we pass 1 minute change trigger code to 2 digit between 11 and 19
                trigger_time_min = trigger_time_2; % update old time that indicates when minute started
                S.trig.trigger_per_10_secs = S.trig.trigger_min; % set trigger to be send
                S.trig.trigger_min =  S.trig.trigger_min + 1; % update trigger code for counting minutes
            else % if only 10 seconds are full but no minute
                if S.trig.trigger_per_10_secs == S.trig.trigger_min-1; % if it is the first 10 seconds of minute then trigger code is 102 all other times it gets incremented by one
                    S.trig.trigger_per_10_secs = 102;
                else
                    S.trig.trigger_per_10_secs =  S.trig.trigger_per_10_secs + 1;
                end % checking whether first 1o second of new minute
            end % if  1min full
            
            trigger_time_1 = trigger_time_2; % update old trigger time for counting 10 seconds
            
            current_trigger_value =  S.trig.trigger_per_10_secs;
        end % trigger loop for every 10 secs

        S.f{block}(f) = f;
        
        % trial counter needed for feedback to know in which coherent
        % motion period (i.e. trial) we are in
        if abs(S.mean_coherence{block}(f)) > 0 && abs(S.mean_coherence{block}(f-1)) == 0
            trial = trial+1;
            S.coh_check = S.mean_coherence{block}(f);
            S.start_frame_trial = f;
            % send EEG trigger that next coherent motion period is starting
            if EEG || elink
                if S.mean_coherence{block}(f) < 0
                    coherence_motion = (abs(S.mean_coherence{block}(f)) .* 100) + 100;
                else
                    coherence_motion = (abs(S.mean_coherence{block}(f)) .* 100);
                end
                current_trigger_value = coherence_motion;
            end
        end

        if S.rewardcountdown > 0 %% S. % if keydown = 1 update reward bar, because on last
                % frame a response occured or coherent motion period has been missed
            if keydown || missedflag == 1
                S.totalPoints = S.totalPoints + respMat{block}(resp_counter-1,1);
                missedflag = 0;
            end
               
                % calculate how far rewardbar is filled and how many $ won
            [S.coins_counter,S.x_rect_old,textcoin,centeredRect,centeredFrame,centeredrewardRect,S.totalPoints,reward_m] = ...
                moneybar(S.x_rect_old,S.coins_counter,S.rewbarsize,S.centre(1), ...
                S.centre(2),S.ap_radius,S.totalPoints,S.totalPointsbar,respMat{block}(resp_counter-1,1),S.rewbarlocation);
        end % if key down
            
        if rewardbar % if reward bar is shown under stimuli
            if S.totalPoints > 0 % depending on totalPoints reward bar is either green or red
                % positive number of points won = green
                Screen('FillRect',tconst.win,S.green, centeredRect); % display green bar
            else
                % negative number of points won = red
                Screen('FillRect',tconst.win,S.red, centeredRect); % display red bar
            end
            
            Screen('FrameRect',tconst.win,S.black,centeredFrame,4); % display frame of bar (always black)
            DrawFormattedText(tconst.win, textcoin, S.centre(1)+round(S.rewbarsize(1)/2)+30,...
                S.rewbarlocation(2), 0);
            
            % if response occured in last frame show in white how many
            % points won/lost
            if S.rewardcountdown >= S.rewardbartime
                S.rewardcountdown = S.rewardcountdown - 1;
                Screen('FillRect',tconst.win,S.white, centeredrewardRect);
                % if feedback is half way through, turn points won in trial
                % bar at end of reward par in respective colour
            elseif S.rewardcountdown < S.rewardbartime && S.rewardcountdown > 0
                S.rewardcountdown = S.rewardcountdown - 1;
                if respMat{block}(resp_counter-1,1) >= 0 % draw green reward bar at
                    % end of main reward bar, if participant has positive number of points
                    Screen('FillRect',tconst.win,S.green, centeredrewardRect); % display bar
                else % and red if  points won is negative
                    Screen('FillRect',tconst.win,S.red, centeredrewardRect); % display bar
                end % if respMat
            end % Fb.feedback_countdown >= 0.5 * Fb.feedback_countdown
        end % if rewardbar

        % Submit drawing instructions of moving dots to PTB

        if diode % if we test screen flip with photo diode display square in upper left corner that changes between black and white from frame to frame
            Screen('FillRect',tconst.win, abs(S.square_diode_colour), S.square_diode_centred);
            S.square_diode_colour = abs(S.square_diode_colour)-1;
        end % diode
        
        % draw rdk dots
        Screen('DrawDots' , tconst.win , S.xy{block}(:,:,f), S.dotdiameter, S.black,...
            S.centre, S.vp.dot_type);

        % draw annulus
        if annulus
            Screen('FillOval', tconst.win, S.grey, S.annulus_rect, S.annulus_diameter);
        end
        
        % display feedback for specified time after button has been pressed or
        % coherent motion has been missed Fb.feedback_countdowns is set below
        % in feedback loop. fix dot changes colour and shape with respect
        % to response particitant made
        if Fb.feedback_countdown > 0
            Fb.feedback_countdown = Fb.feedback_countdown -1; % count down time  in which fb has been presented
            
            % correct or incorrect response during coherent motion = dot
            if respMat{block}(resp_counter-1,7) == 0 || respMat{block}(resp_counter-1,7) == 1 ...
                    || respMat{block}(resp_counter-1,7) == 2 || respMat{block}(resp_counter-1,7) == 3
                colour = Fb.colour;
            elseif  training == 1
                if  S.mean_coherence{block}(f) ~= 0 % this is defined by the
                    % previous trial having a mean coherence of 0 in contrast to the current
                    
                    % Draw the fixation cross in white, set it to the center of our screen and
                    % set good quality antialiasing
                    colour = [0.8 0.8 0.8];
                else
                    colour = S.black;
                end
            else
                colour = S.black;
            end
        else
            colour = S.black;
            if  training && S.mean_coherence{block}(f) ~= 0 % this is defined by the
                % previous trial having a mean coherence of 0 in contrast to the current
                
                % Draw the fixation cross in white, set it to the center of our screen and
                % set good quality antialiasing
                colour = [0.8 0.8 0.8];
            end
        end % draw fb on screen

        switch shape
            case 'S'
                Screen('FillRect',tconst.win,colour,size)
            case 'C'
                Screen('Drawdots',tconst.win,[0 0],size,colour,S.fixdotlocation,S.vp.dot_type)
        end
        
        % Set appropriate alpha blending for correct anti-aliasing of dots
        Screen (  'BlendFunction'  ,  tconst.win  ,  ...
            'GL_SRC_ALPHA'  ,  'GL_ONE_MINUS_SRC_ALPHA'  ) ;
        
        % get start time of first coherent motion frame of each trial
        if f > 1
            if S.mean_coherence{block}(f-1) == 0 && abs(S.mean_coherence{block}(f)) ~= 0
                % this is defined by the previous trial heaving a mean coherence of 0 in contrast to the current
                tstart = GetSecs;
                S.coh_f{block}(counter_coh,:) = [f, tstart];
                counter_coh = counter_coh + 1;
            end
        end
        
        [vbltimestamps(f),stimonsettimes(f),flipt,missbeam(f)] = Screen('Flip', tconst.win, flipt+(1-0.5) * tconst.flipint);
        
        fliptimes(f) = flipt;
        
        if f > S.flex_feedback+1 % check whether coherent motion stim has been missed if frame number is at least 2
            if resp_counter == 2 % if response counter has not been updated yet, we don't need to calculate the time between now and the last response made
                if S.start_frame_trial + S.block_coherent_cells{block} + S.flex_feedback + 1 == f && S.start_frame_trial ~= 0
                    % coherent motion has been missed in case the current frame
                    % has 0 mean coherence and the frame 500ms or flex_feedback frames
                    % before has a mean coherence  not
                    % equal to 0 only if no response has been made yet
                    
                    % fill response matrix accordingly
                    respMat{block}(resp_counter,1) = S.vp.point(4); %points lost
                    respMat{block}(resp_counter,3) = 2; % choice missed
                    respMat{block}(resp_counter,4) = S.mean_coherence_org{block}(f-1); % coherence of missed coherent motion
                    respMat{block}(resp_counter,5) = 0; % choice incorrect
                    respMat{block}(resp_counter,6) = f; % frame it occured
                    respMat{block}(resp_counter,7) = 3; % missed coherent motion
                    
                    Fb.feedback_countdown  = S.feedback_frames; % set feedback_countdown so that feedback is displayed in next frames
                    Fb.colour = S.blue; % set colour of feedback
                    
                    % increase counter for index into respMat
                    resp_counter = resp_counter + 1;
                    
                    S.rewardcountdown = 2 .* S.rewardbartime; % this is the time the points won bar at
                    %  end of reward bar is shown first in white and then in green and red for won and lost
                    % respectively, this is why we have to doulbe this variable, because we want bar in white
                    % and green/red to be displayed same amount of time
                    
                    keydown = 1;
                    missedflag = 1;
                    S.start_frame_trial = 0;
                    if  EEG || elink % send trigger if trial missed
                        current_trigger_value = S.trig.coherent_motion_missed;
                    end % set flag that response bar needs to be updated on next frame
                else
                    keydown = 0; % coherent motion has not been missed don't re-calculate reward bar
                end % if coherent stim has been missed
            else % if resonse counter is above 2, we need to take into account the amount of time since last time response has been made
                if S.start_frame_trial + S.block_coherent_cells{block} + S.flex_feedback + 1 == f && S.start_frame_trial ~= 0 && (f - respMat{block}(resp_counter - 1,6)) >= S.block_coherent_cells{block}+S.flex_feedback
                    % coherent motion has been missed in case the current frame
                    % has 0 mean coherence and the frame 500ms or flex_feedback frames
                    % before has a mean coherence  not
                    % equal to 0. Since we randomize dot positions everytime
                    % participant has respondend in time i.e. setting the mean
                    % coherence 0 after button press, this leads to feedback of
                    % misses even if they havent been missed. Therefore, we
                    % also have to check whether the amount of frames passed
                    % since coherent motion onset equals the total length of
                    % coherent motion period, only then a coherent motion
                    % stimulus has been really missed
                    
                    missedflag = 1;
                    respMat{block}(resp_counter,1) = S.vp.point(4);
                    respMat{block}(resp_counter,3) = 2;
                    respMat{block}(resp_counter,4) = S.mean_coherence_org{block}(f-1);
                    respMat{block}(resp_counter,5) = 0;
                    respMat{block}(resp_counter,6) = f;
                    respMat{block}(resp_counter,7) = 3;
                    % missed coherent motion
                    
                    Fb.feedback_countdown  = S.feedback_frames;
                    S.start_frame_trial = 0;
                    
                    Fb.colour = S.blue;
                    
                    resp_counter = resp_counter + 1;
                    
                    S.rewardcountdown = 2 .* S.rewardbartime; % this is the time the points won bar at
                    %  end of reward bar is shown first in white and then in green and red for won and lost
                    % respectively, this is why we have to doulbe this variable, because we want bar in white
                    % and green/red to be displayed same amount of time
                    
                    keydown = 1; % set flag that response bar needs to be updated on next frame
                    if  EEG || elink % send trigger if trial missed
                        current_trigger_value = S.trig.coherent_motion_missed;
                    end
                else
                    keydown = 0; % coherent motion has not been missed don't re-calculate reward b
                end % if coherent stim has been missed if resp_counter > 2
            end % resp_counter == 2
        end % if frame > 1

        % check for subject response
        [keyIsDown,firstpress] = KbQueueCheck(device_number(1)); % check wheter arrow key has been pressed
        
        % if key has been pressed fill response matrix and prepare display of
        % feedback
        
        if keyIsDown % if any key has been pressed on current frame
            rts = GetSecs;
            % check whether this button is a response key : left or right
            % key if yes check for coherence and determine what sort of
            % response, correct, incorrect, during incohrent motion it is,
            % if other key has been pressed save which key it was and frame
            %
            % if we are not in a feedback loop at the moment count this as
            % actual response if not just save the button that has been
            % pressed and on which frame and its coherence
            
            if Fb.feedback_countdown <= 0
                if firstpress(leftkey) > 0
                    keydown = 1;
                    
                    Fb.feedback_countdown  = S.feedback_frames; % amount feedback in form of changing fixdot is shown
                    S.rewardcountdown = 2 .* S.rewardbartime; % this is the time the points won bar at
                    %             %  end of reward bar is shown first in white and then in green and red for won and lost
                    %             % respectively, this is why we have to doulbe this variable, because we want bar in white
                    %             % and green/red to be displayed same amount of time
                    
                    respMat{block}(resp_counter,2) =  rts - tstart; % rt
                    respMat{block}(resp_counter,3) = 0; % choice - 0 left, 1 right
                    respMat{block}(resp_counter,4) = S.mean_coherence{block}(f); % coherence on trial
                    respMat{block}(resp_counter,6) = f; % frame on which button press occured
                    
                    if S.mean_coherence{block}(f) > 0 % for leftkey
                        respMat{block}(resp_counter,1) = S.vp.point(2); % points lost
                        respMat{block}(resp_counter,5) = 0; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 0;
                        
                        Fb.colour = S.red; % colour of FB
                        [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f); % get incoherent frames for reminder of coherent motion period
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                        
                        S.start_frame_trial = 0;
                        
                        if  EEG || elink % send trigger if responded to coherent motion
                            %                             io64( trig.portobject, trig.portaddress, S.trig.coherent_motion_fb_left);
                            current_trigger_value = S.trig.coherent_motion_fb_left;
                        end
                    elseif S.mean_coherence{block}(f) < 0
                        respMat{block}(resp_counter,1) = S.vp.point(1); % points lost
                        respMat{block}(resp_counter,5) = 1; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 1;
                        
                        Fb.colour = S.green; % colour of FB
                        [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f); % get incoherent frames for reminder of coherent motion period
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                        
                          S.start_frame_trial = 0;
                        
                        
                        if  EEG || elink % send trigger if responded to coherent motion
                            %                             io64( trig.portobject, trig.portaddress, S.trig.coherent_motion_fb_left);
                            current_trigger_value = S.trig.coherent_motion_fb_left;
                        end
                    else
                        respMat{block}(resp_counter,1) = S.vp.point(3); % points lost
                        respMat{block}(resp_counter,5) = 0; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 2;
                        
                        Fb.colour = S.yellow; % colour of FB
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                        
                        
                        if  EEG || elink % send trigger if responded to incoherent motion
                            current_trigger_value =  S.trig.resp_incoherent_motion_left;
                        end
                    end % mean coherence > 0 for left key
                    
                elseif firstpress(rightkey) > 0
                    keydown = 1;
                    
                    Fb.feedback_countdown  = S.feedback_frames;% amount feedback in form of changing fixdot is shown
                    S.rewardcountdown = 2 .* S.rewardbartime; % this is the time the points won bar at
                    %             %  end of reward bar is shown first in white and then in green and red for won and lost
                    %             % respectively, this is why we have to doulbe this variable, because we want bar in white
                    %             % and green/red to be displayed same amount of time
                    %
                    respMat{block}(resp_counter,2) = rts - tstart; % rt
                    respMat{block}(resp_counter,3) = 1; % choice - 0 left, 1 right
                    respMat{block}(resp_counter,4) = S.mean_coherence{block}(f); % coherence on trial
                    respMat{block}(resp_counter,6) = f; % frame on which button press occured

                    if S.mean_coherence{block}(f) > 0 % for right key
                        respMat{block}(resp_counter,1) = S.vp.point(1); % points lost
                        respMat{block}(resp_counter,5) = 1; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 1;
                        
                        Fb.colour = S.green; % colour of FB
                        [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f); % get incoherent frames for reminder of coherent motion period
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                          S.start_frame_trial = 0;
                        if  EEG || elink% send trigger if responded to coherent motion
                            current_trigger_value =  S.trig.coherent_motion_fb_right;
                        end
                    elseif S.mean_coherence{block}(f) < 0
                        respMat{block}(resp_counter,1) = S.vp.point(2); % points lost
                        respMat{block}(resp_counter,5) = 0; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 0;
                        
                        Fb.colour = S.red; % colour of FB
                        [S,start_f] = recalculate_xy_position(S,f,trial,block,start_f); % get incoherent frames for reminder of coherent motion period
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                        
                        S.start_frame_trial = 0;

                        if  EEG || elink % send trigger if responded to coherent motion
                            current_trigger_value = S.trig.coherent_motion_fb_right;
                        end
                    else
                        respMat{block}(resp_counter,1) = S.vp.point(3); % points lost
                        respMat{block}(resp_counter,5) = 0; % choice correct = 1/incorrect = 0
                        respMat{block}(resp_counter,7) = 2;
                        
                        Fb.colour = S.yellow; % colour of FB
                        resp_counter = resp_counter + 1; % increase counter for row in response matrix
                        if  EEG || elink% send trigger if responded to incoherent motion
                            current_trigger_value =  S.trig.resp_incoherent_motion_right;
                        end
                    end % mean coherence > 0 for right key
                else % other button then left or right key is pressed
                    keydown = 0;

                    % save which key has been pressed and in what frame
                    keypress{keycounter,1} = KbName(firstpress);
                    keypress{keycounter,2} = f;
                    keypress{keycounter,3} = S.mean_coherence{block}(f);
                    
                    keycounter = keycounter + 1;
                end % if firspress(leftkey)
            else % if feedback countdown is not 0 because other button has been pressed before
                % save which button has been pressed
                keydown = 0;
                
                % save which key has been pressed and in what frame
                keypress{keycounter,1} = KbName(firstpress);
                keypress{keycounter,2} = f;
                keypress{keycounter,3} = S.mean_coherence{block}(f);
                
                keycounter = keycounter + 1;
            end % if feedback countdown == 0
        else % if no key has been pressed on current frame
            keydown = 0;
        end % if keyIsDown
        
        if  elink && f == 1
            Eyelink('Message', 'F %d T %d', f, 11);
            Eyelink('Command', ['record_status_message ', '11']);
        elseif elink && f == 200
            Eyelink('Message', 'F %d T %d', f, 2);
            Eyelink('Command', ['record_status_message ', '2']);
        elseif elink && f == 400
            Eyelink('Message', 'F %d T %d', f, 4);
            Eyelink('Command', ['record_status_message ', '4']);
        elseif elink && f == 600
            Eyelink('Message', 'F %d T %d', f, 6);
            Eyelink('Command', ['record_status_message ', '6']);
        elseif elink && f == 800
            Eyelink('Message', 'F %d T %d', f, 8);
            Eyelink('Command', ['record_status_message ', '8']);
        elseif elink && f == (S.totalframes_per_block -200)
            Eyelink('Message', 'eob_2');
            Eyelink('Command', ['record_status_message ', 'eob_2']);
        elseif elink && f == (S.totalframes_per_block -400)
            Eyelink('Message', 'eob_4');
            Eyelink('Command', ['record_status_message ', 'eob_4']);
        elseif elink && f == (S.totalframes_per_block -600)
            Eyelink('Message', 'eob_6');
            Eyelink('Command', ['record_status_message ', 'eob_6']);
        elseif elink && f == (S.totalframes_per_block -800)
            Eyelink('Message', 'eob_8');
            Eyelink('Command', ['record_status_message ', 'eob_8']);
        elseif elink && f == S.totalframes_per_block
            Eyelink('Message', 'eob');
            Eyelink('Command', ['record_status_message ', 'eob']);
        end

        if EEG
            io64( trig.portobject, trig.portaddress, current_trigger_value);
            S.trigger_vals{block}(f) = current_trigger_value;
        end

        f = f+1; % increase to next frame
        while_calls = while_calls + 1; % counter for while calls for displaying frames
        all_while_calls(while_calls) = toc(while_loop_time); % timing time between while calls
        all_frames(while_calls) = f; % saving frame from current while call
    end % while total num of frame is not reached
    
    % save while call info and flip info from screen flip function for each
    % block and frame
    S.stimonsettimes{block} = stimonsettimes;
    S.missbeam{block} = missbeam;
    S.vblstamp{block} = vbltimestamps;
    S.flipts{block} = fliptimes;
    S.while_calls{block} = while_calls;
    S.all_while_calls{block} = all_while_calls;
    S.all_frames{block} = all_frames;
    S.length_block{block} = toc(block_time);
    S.keypress{block} = keypress;
    S.last_trigger = idx_last_trigger;
    
    %%%--- take a break after each block---%%%
    
    % display how long block was
    
    disp(num2str(S.length_block{block}));
    
    % text displayed after block finished
    
    S.trial = trial;
    % total points possible to earn during last block
    S.total_possible_points = trial .* S.vp.point(1);
    
    % index to correct button responses during coherent motion
    S.idx_correct = respMat{block}(:,7) == 1;
    
    % index to incorrect button presses during coherent motion
    S.idx_incorrect = respMat{block}(:,7) == 0;
    
    % index to button presses during incoherent motion
    S.idx_false = respMat{block}(:,7) == 2;
    
    % index to missed coherent motion epochs
    S.idx_miss = respMat{block}(:,7) == 3;
    
    % total points won during last block
    S.points_won_correct_incorrect = sum(respMat{block}(~isnan(respMat{block}(:,1)),1));
    
    % total coins earned in block including misses and false resp
    S.total_coins_earned{block} = S.coins_counter;

    % text displayed after block finished
    
    text = 'Well done! \n \n Please take a break. \n You can look away from the screen.';
    
    DrawFormattedText(tconst.win, text, 'center', 'center', 0);
    Screen('Flip',tconst.win);
    
    % save info about reward for next session
    reward_matrix(1,:) = reward_m;
    
    savePath = fullfile(outdir,reward_file);
    save(savePath,'reward_matrix');
    
    %%% variables I want to save %%%%%
    % mean coherence
    % coherence frame
    % trigger_vals
    %
    B.total_coins_earned    = S.total_coins_earned;
    B.stimonsettimes        = S.stimonsettimes;
    B.missbeam              = S.missbeam;
    B.vblstamp              = S.vblstamp;
    B.flipts                = S.flipts;
    B.while_calls           = S.while_calls;
    B.all_while_calls       = S.all_while_calls;
    B.all_frame             = S.all_frames;
    B.length_block          = S.length_block;
    B.keypress              = S.keypress;
    B.last_trigger          = S.last_trigger;
    B.trig                  = S.trig;
    B.trigger_vals          = S.trigger_vals;
    B.mean_coherence        = S.mean_coherence;
    B.coherence_frame       = S.coherence_frame;
    B.session               = S.vp.session;
    B.subid                 = S.vp.subid;
    
    % after all blocks finished save response data, and S and tconst structs
    savePath = fullfile(outdir,outfile);
    save(savePath,'respMat','B','tconst');
    
    WaitSecs(2);
    Screen('FrameRect',tconst.win,S.black,centeredFrame,4); % display frame of bar always black
    DrawFormattedText(tconst.win, textcoin, S.centre(1)+round(S.rewbarsize(1)/2)+30,...
       S.rewbarlocation(2), 0);
            
    if S.totalPoints > 0 
        Screen('FillRect',tconst.win,S.green, centeredRect); % display bar
    else 
        Screen('FillRect',tconst.win,S.red, centeredRect); % display bar  
    end 

    Screen('Flip',tconst.win);
    
    KbStrokeWait(device_number) % next block starts after participant presses button
    
    ListenChar(0);
    
    if EEG
        io64( trig.portobject, trig.portaddress,0);
    end
    
    if EEG
        CloseIOPort % Close the port to EEG
    end
end % loop through blocks


if elink % close eyelink (eye tracker) and save file
    Eyelink('StopRecording'); % Niks code
    Eyelink('CloseFile');
    status  = Eyelink('ReceiveFile');
end

% delete all keyboard presses
KbQueueStop;
% close PTB window
sca;

end % stimulus present function















