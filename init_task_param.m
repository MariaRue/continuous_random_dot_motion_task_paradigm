function [S,tconst] = init_task_param (vpar,debug,discrete_trials,integration_window,ordered_coherences, vert_motion)

% PURPOSE: This function is important for the initialisation of a session. 
% It initiates screen and computer parameters important for the screen
% settings in the task such as pixel size of screen and flip interval and
% saves it in the tconst structure. 
% Sets parameters and transforms parameters from the .csv file in units 
% appropriate for PTB, i.e. transform visual degrees in pixels. All 
% parameters more stimulus specfic, i.e. dot size, speed of dots etc. are 
% kept in the structure S for Stimulus. It also keeps a copy of all initial
% parameters specified in the .csv file under S.vp. 
%
% Additionally, in this file, we initiate the metpixperdeg() function,
% which converts visual degrees (found in the .csv parameters file) to
% pixels, so that stimuli can be drawn on the screen.

% Input: 
%   vpar ---------- : structure with all parameters in original units from 
%                       .csv file 
%   debug ------- 0 : on any other computer tha mac full screen 
%                       window and framerate set to monitor refresh rate task 
%                 1 : small window for debuging 
%                 2 : full window but monitor refresh rate set to 60hz. Use
%                       use on a mac laptop (or windows surface)
%                 3 : small window, refresh rate set to 60hz 
%    discrete_trials: 1 discrete trials, 0 continous rdk session 
% integration_window: only for discrete rdk, defines length of stimulus
%                       shown, 1 means long integration, stimulus shown for a 
%                       long period, 0 = short integration, stimulus shown
%                       for short period 
% ordered_coherences: see create_stimuli.m

% Output: 
%   (Returns two structures that are important to run task with
%    rdk_contionous_motion, as follows)
%   S ---- : structure with stim paramaters, trial info; the 'vp' field has 
%              a copy of all the parameters in their original units 
%   tconst : screen and PTB parameters, including
%               - .winptr: the number of the screen on which the task will
%                            be shown
%               - .win: the window in which we will display the task
%               - .framerate: obtains and holds the screen framerate
%               - .flipint: flip interval
%               - .pixperdeg: used to calculate how many pixels/degree to 
%                               assign to dots (this is why visual degrees
%                               are important!)

% Maria Ruesseler, University of Oxford, 2018

%%% Build stimulus descriptor %%%

% Keep a copy of variable parameters from csv file in their original units
S.vp = vpar;

%%%--- SETUP: screen parameters ---%%%
% set colour parameters, e.g. to colour screen background grey - some of
% these colours might be unused
S.grey= [0.5 0.5 0.5]; % screen background
S.red=[0.8 0 0]; % missed coherent motion epoch 
S.green = [0 0.6 0]; % correct response during coherent motin
S.blue = [0 1 1]; % incorrect response during coherent motion
S.black = [0 0 0]; % color of dots and targets and fix before task starts
S.yellow= [1 1 0]; % response during incoherent motion (i.e. also incorrect)
S.white=[1 1 1]; % colour of fixdot during training if there is coherent motion 

%%%--- SETUP: screens ---%%%
% 0 should be preferred but synch problems on mac prohibit that. 
if debug == 2 || debug == 3
    Screen('Preference', 'SkipSyncTests',1);
elseif debug == 0 || debug == 1
    Screen('Preference', 'SkipSyncTests',0);
end 
PsychDefaultSetup(2);
screens = Screen('Screens');

% get correct screen number for screen on which we want to show task
tconst.winptr = max(screens);

% confirm!
disp('Screen is set up.');

%%%%%% rewardbar parameters %%%%%% 
S.x_rect_old = 0; % variable saves x position (in pixels) of how far reward bar was filled  
S.coins_counter = 0; % counts how many pounds have been won within and  
                     % across sessions, 0.15� are added each time reward
                     % bar is filled up
%S.total_rect_x_size = 500; % length of reward bar in pixels 
S.totalPointsbar = S.vp.trialsperpound .* S.vp.point(1); % points subject has to earn in order to win 0.15�
S.totalPoints = 0; % total number of points earned so far - determining how far rewardbar will be filled up 

%%%--- open window to get screen specific parameters ---%%%

%%% DEBUG SETTINGS %%%
% Used for figuring out what went wrong when something goes wrong...
S.debug = debug; 

if debug == 1 
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr,S.grey,[0 0 1048 786]);
     tconst.framerate = Screen('FrameRate',tconst.win); % get frame rate and open small window
elseif debug == 2
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr, S.grey);
    tconst.framerate = 60;% on mac framerate sometimes cannot be determined but 60 Hz 
    % is could approximation,3 if small window on screen, 2 if full screen
elseif debug == 3 
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr,S.grey,[0 0 1048 786]);
    tconst.framerate = 59;
    %% Neb: change above to 60 when on Mac
else % opens window full screen for running task with participants 
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr, S.grey);
    tconst.framerate = Screen('FrameRate',tconst.win); % get frame rate 
end
%%% END DEBUG SETTINGS %%%

tconst.flipint = Screen ( 'GetFlipInterval' , tconst.win ); % get flip interval 

% calculate constant to transform visual degrees into pixels 
tconst.pixperdeg = metpixperdeg(S.vp.scrwidth, tconst.rect(3), S.vp.subdist);

% get window centre
[S.centre_x, S.centre_y] = RectCenter(tconst.rect);
S.centre = [S.centre_x, S.centre_y];

% dots per frame = dots/deg^2, round up so that we always get at least
% one dot if density is non-zero
S.Nd = ceil(pi * (S.vp.ap_rad^2) * S.vp.density);

% dotdiameter in pixels
S.dotdiameter = tconst.pixperdeg * S.vp.dotsize; % dots in rdk 
S.fixdiameter = tconst.pixperdeg .* S.vp.fixsize; % fix dot 
if S.fixdiameter(1) > 20
    S.fixdiameter(1) = 20; % max value is 20, screen too small (in mm) if >20
    disp('Fix dot 1 (smaller circle) diameter too high! Check init_task_param().');
end
if S.fixdiameter(2) > 20
    S.fixdiameter(2) = 20; % max value is 20, screen too small (in mm) if >20
    disp('Fix dot 2 (larger circle) diameter too high! Check init_task_param().');
end

% all parameters for Screen FillOval to draw annulus around fix dot. 
S.annulus = tconst.pixperdeg * S.vp.annulus; 

S.annulus_rect = [S.centre(1)-S.annulus, S.centre(2) - S.annulus, S.centre(1)+S.annulus, S.centre(2) + S.annulus]; % defining size and where annulus will be
S.annulus_diameter = 2.*S.annulus; % defining diameter should help with speeed 

% S.targetdiameter = tconst.pixperdeg * S.vp.trgsize; % targets - not used in current version 
% % target location in pixel - not used in current version 
% S.target_location = S.vp.target_location * tconst.pixperdeg;
% % coordinates to draw target dots - not used in current version 
% S.target = [- S.target_location, S.target_location; 0 0];

% size parameters of fixdot for training 
S.linewidth = S.vp.linewidth .* tconst.pixperdeg; 
S.linesize = S.vp.linesize .* tconst.pixperdeg; 

% Neb: Triangles seem never to be used (maybe it's something left over 
% from the past?) We should get rid of this code if that's true.

% % triangle for feedback 
% S.triangle_size = S.vp.triangle_size .* tconst.pixperdeg; 
% S.triangle_pen_width = S.vp.triangle_pen_width .* tconst.pixperdeg;
% 
% % list of x/y positions to position triangle if trial has been missed 
% S.triangle_vector = [S.centre(1) - (S.triangle_size(1)/2), S.centre(2); ...
%                     S.centre(1) + (S.triangle_size(1)/2), S.centre(2); ...
%                     S.centre(1), S.centre(2) + S.triangle_size(2)];        
                 
%aperture radius in pixels in which dots are displayed
S.ap_radius = tconst.pixperdeg * S.vp.ap_rad;

% rewardbar size and location 
S.rewbarlocation = [S.centre(1) + (S.vp.rewbarlocation(1).*tconst.pixperdeg), S.centre(2) + (S.ap_radius +  (S.vp.rewbarlocation(2).*tconst.pixperdeg))];
S.rewbarsize = S.vp.rewbarsize .* tconst.pixperdeg; 

% location of the fixdot 
S.fixdotlocation = S.centre;

%%% Neb: Squares also seem not to be used...

% square for feedback for replies during incoherent motion 
S.square_size = S.vp.square_size .* tconst.pixperdeg; 

% vector with coordinates of square indicating long intertrial periods,
% left, upper corner, right, lower corner

% big square for long integration periods 
S.square_vector_big = [0 0 S.square_size(2) S.square_size(2)];
S.square_centred_big = CenterRectOnPointd(S.square_vector_big,S.fixdotlocation(1), S.fixdotlocation(2)); 

% small square for short integration periods 
S.square_vector_sm = [0 0 S.square_size(1) S.square_size(1)];
S.square_centred_sm = CenterRectOnPointd(S.square_vector_sm, S.fixdotlocation(1), S.fixdotlocation(2)); 

% square for photo-diode in upperleft corner of screen 
S.square_diode_length = 20; % in pix 
S.square_diode_vector = [0 0 S.square_diode_length S.square_diode_length]; 
S.square_diode_centred = CenterRectOnPointd(S.square_diode_vector,S.square_diode_length/2, S.square_diode_length/2); 
S.square_diode_colour = [0 0 0];

% Pixels travelled by a signal dot between each frame * 3 because I have 3
% sets of dots
S.step = tconst.pixperdeg  *  S.vp.speed  *  tconst.flipint;

% amount of time in frames participants have to give feedback after the stimulus has
% disappeared 
S.flex_feedback = round(S.vp.flex_feedback / tconst.flipint);

% calculate duration feedback is shown
S.feedback_frames = round(S.vp.feedback_duration / tconst.flipint);

% mean duration of coh level during incoherent motoin
S.mean_duration = round(S.vp.mean_duration / tconst.flipint);
S.sd_duration = round(S.vp.sd_duration / tconst.flipint);

% save discrete trials flag - used in task code to determine whether to
% display single trials or continuous rdk 
S.discrete_trials = discrete_trials; 

%%% CODE FOR DISCRETE TRIALS (SHADLEN STYLE) %%%
if discrete_trials % if during training discrete trials are shown 
    % remember flags in S strucuture to use in trial display later on 
    S.integration_window = integration_window; 
    % incoherent motion period shown before coherent motion starts in
    % discrete trials 
    S.pre_incoh_mo = round(S.vp.pre_incoh_mo / tconst.flipint);
    
    if ordered_coherences % for training purposes, this allows to present stimuli 
        % starting with the highes coh level and then gradually going down to the lowes, 
        % e.g. showing randomized 50/-50% coherence, then ranomized 40/-40% coherence and so on

        try % in case totaltrials not a multiple of cohlist, then catch error and return 
            % get unique coherences, disregarding their sign (+/-)
             cohlist = unique(abs(S.vp.cohlist)); 

             % repetitions per coherence 
             num_repeats_coh = (S.vp.totaltrials/numel(cohlist))/2;

             S.coherence_list = []; % vector in which sequence of coherences is saved 
             
             %%% SETTING UP ORDER OF COHERENCES %%% 

             for coherence_counter = numel(cohlist):-1:1 % loop through cohlist vector but start with highest coherence 
                 % duplicate coherence level with both signs, e.g. 0.5 -0.5 
                 coherence_matrix = repmat([cohlist(coherence_counter), -cohlist(coherence_counter )],[num_repeats_coh,1]);

                 % shuffle these duplications  e.g. 0.5 -0.5 0.5 0.5 ... 
                 shuffled_idx = randperm(numel(coherence_matrix));

                 % add to vector 
                 S.coherence_list = [S.coherence_list;reshape(coherence_matrix(shuffled_idx),[numel(coherence_matrix),1])];
             end % loop through cohlist 
        catch % if this doesnt work, return 
            error ( 'init_task_param:coherence:trial' , ...
            'init_task_param: error in oredered coherence sequence for training, possibly totaltrials not a multiple of coherences in cohlist ' );
        end
    else % if we don't want to order coherences based on size, just shuffle all coherences 
        try % in case totaltrials not a multiple of cohlist 
            % calculate repeats per coherence 
            num_repeats_coh = S.vp.totaltrials/numel(S.vp.cohlist);

            % duplicate all coherences 
            coherence_matrix = repmat(S.vp.cohlist,[num_repeats_coh,1]);
        catch 
            error ( 'init_task_param:coherence:trial' , ...
            'init_task_param: totaltrials must be a multiple of coherences in cohlist ' );
        end
    % shuffle indices of duplicates 
    shuffled_idx = randperm(numel(coherence_matrix));

    % build vector 
    S.coherence_list = reshape(coherence_matrix(shuffled_idx),[numel(coherence_matrix),1]);

    end

    if discrete_trials == 1
        S.discrete_stim_duration = round(S.vp.str_train/ tconst.flipint);  
    else
        if integration_window % determine how long stim duration will be in discrete trials 
            % stimulus long
            S.discrete_stim_duration = round(S.vp.longINT / tconst.flipint);  
        else
            % stimulus short
            S.discrete_stim_duration = round(S.vp.shortINT / tconst.flipint);
        end  % integration window 
    end 
 
 
    % total length of stimulus, with incoh motion at start of trial 
    S.discrete_stim_duration_total = S.pre_incoh_mo + S.discrete_stim_duration; 

    for i = 1:S.vp.totaltrials % loop through trials and create buffer for xy positions 
    % of all dots for whole stimulus duration of trial 

    % Matrix with 3 sets of dots 2 * S.ND * 3. First row is is x coordinate,
    % second is y coordinate, S.Nd number = of columns indicates numbers of dots
    % and 3rd dimension indicates the set of dots.
        S.xy{i} = zeros(2,S.Nd,S.discrete_stim_duration_total);
    end % loop through trials to build buffer for xy positon of dots 

    % buffer for coherence probability - coherence is used as probability.
    % Randomly assigned number between 0 and 1, all dots with number below coh
    % level will be signal dots
    S.coh_prob = zeros(1,S.Nd);
%%% CONTINUOUS TRIALS %%%
else  % if continuous trials
    % time bar indicating points won on current trial at end of bar will be
    % shown 

    S.rewardbartime = round(S.vp.rewbarcol / tconst.flipint); 

    %%%--- calculating number of frames of incoherent motion between coherent
    %%% motion periods ---%%%%

    % get total number of frames
    S.totalframes_per_block = round((S.vp.block_length * 60) / tconst.flipint);

    % min number of frames before first stimulus can occur and min number of frames of
    % incoherent motion after last stimulus
    S.gap_after_last_onset = round(S.vp.gap_after_last_onset / tconst.flipint);
    S.gap_before_first_onset = round(S.vp.gap_before_first_onset / tconst.flipint);

    % vector with frame interval in which coherent stimuli can occur
    S.onsets_occur = [S.gap_before_first_onset  S.totalframes_per_block - S.gap_after_last_onset];

    S.total_stim_epoch = diff(S.onsets_occur); % total num of frames in which stim of coherent motion and incoherent motion can be shown


    % interstumulus interval for both conditions - long periods of intertrial
    % time and short periods of intertrial time. 

    % S.vp.itishor/long have 3 values. First value is lower min frame
    % number, second number mean frame number between trials and third number
    % upper frame number bound
    S.iti_short =  round(S.vp.itishort / tconst.flipint);
    S.iti_long =  round(S.vp.itilong / tconst.flipint);

    % trial/ coherent motion length in short and long condition
    S.integration_short = round(S.vp.shortINT / tconst.flipint);
    S.integration_long = round(S.vp.longINT / tconst.flipint);
    
    %%% DEFINING TIMES OF COHERENT AND INCOHERENT MOTION PERIODS %%%

    % define incoherent and coherent motion periods for each block, number of
    % blocks and sequence of blocks is defined by S.vp.condition_vec 

    for j = 1:numel(S.vp.condition_vec) % loop through vector with block information 
        condition = S.vp.condition_vec(j); % get condition 
        % depending which condition, vectors that have as many frames as block
        % is long and give information about when and which coherent motion or 
        % incoherent motion should be shown 

        % in all conditions only incoherent interstim intervals differ in
        % length, coherent motion lengths are constant in a block 

        % in each condition the following variables are computed for a block: 
        
                % S.ITIS_vec_intes = vector with diffeent ITIs frame lengths
                %                   used between coherent motion periods, name
                %                   of variable can vary depending on condition
                %                   
                % S.blocks_shuffled = each cell of this field has a vector as
                %                     long as total frames in block, out of 0s for incoherent
                %                     motion frames, and trial number for
                %                     coherent motion frames
                %                     e.g. 0 0 0 0 1 1 1 1 1 0 0 0 0 0 2 2 2 2
                %                     ... 

                % S.blocks_coherence_cells = vector which contains shuffled
                %                           coherences used for each trial/coherent motion period

                % S.block_coherent_cells = saves information whether coherent
                %                           motion period is long or short in this block 


                % S.block_ID_cells = cell structure is used in present_rdk to
                %                    give instructions before block how long ITI and coherent
                %                    motion periods are 

        switch condition
            case 1 %%'ITIS_INTES' %%%% short variable intertrial intervals, short integration period = coherent motion period 
                [ S.ITIS_vec_intes{j}, S.blocks_shuffled{j}, ...
                    S.blocks_coherence_cells{j} ] = ...
                    calculate_epoch_lengths( S.total_stim_epoch, ...
                    S.totalframes_per_block, S.iti_short(1), ...
                    S.iti_short(3), S.integration_short, ...
                    S.onsets_occur, S.iti_short(2), S.vp.cohlist );
                S.block_coherent_cells{j} =  S.integration_short;
                
                S.block_ID_cells{j} = '1';
                S.ITIS_vec{j} = S.ITIS_vec_intes{j};
                % calculate vertical motion periods (VMPs) and their respective
                % VITIs (VMP intertrial intervals). We use the same coherence list
                % as for HMPs but note that if at any frame the sum of these
                % coherences (vertical and horizontal) is > 1, the vertical gets
                % truncated so the sum is = 1
                if vert_motion == 1 % if we want vertical motion
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, ...
                        S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_short(1), ...
                        S.iti_short(3), S.integration_short, ...
                        S.onsets_occur, S.iti_short(2), S.vp.cohlist);
                else % otherwise
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, ...
                        S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_short(1), ...
                        S.iti_short(3), 0, ...
                        S.onsets_occur, S.iti_short(2), [0]);
                end
            case 2  %%%'ITIS_INTEL' %%%%% short variable intertrial intervals,long integration period = coherent motion period 
                [ S.ITIS_vec_intel{j}, S.blocks_shuffled{j}, ...
                    S.blocks_coherence_cells{j} ] = ...
                    calculate_epoch_lengths( S.total_stim_epoch, ...
                    S.totalframes_per_block, S.iti_short(1), ...
                    S.iti_short(3), S.integration_long, S.onsets_occur, ...
                    S.iti_short(2), S.vp.cohlist );
                S.block_coherent_cells{j} = S.integration_long;

                S.block_ID_cells{j} = '2';
                S.ITIS_vec{j} = S.ITIS_vec_intel{j}; 
                
                % calculate VMPs for this block (with the same parameters
                % i.e. frequency and length as for HMPs)
                if vert_motion == 1
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_short(1), ...
                        S.iti_short(3), S.integration_long, S.onsets_occur, ...
                        S.iti_short(2),S.vp.cohlist );
                else
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_short(1), ...
                        S.iti_short(3), 0, S.onsets_occur, ...
                        S.iti_short(2), [0] );
                end
            case 3 %%%'ITIL_INTES' %%%% long variable intertrial intervals, short integration period = coherent motion period 
                [ S.ITIL_vec_intes{j}, S.blocks_shuffled{j}, ...
                    S.blocks_coherence_cells{j} ] = ...
                    calculate_epoch_lengths( S.total_stim_epoch, ...
                    S.totalframes_per_block, S.iti_long(1), ...
                    S.iti_long(3), S.integration_short, S.onsets_occur, ...
                    S.iti_long(2), S.vp.cohlist );
                S.block_coherent_cells{j} = S.integration_short;   

                S.block_ID_cells{j}= '3';
                S.ITIS_vec{j} = S.ITIL_vec_intes{j};
                
                % calculate VMPs for this block
                if vert_motion == 1
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_long(1), ...
                        S.iti_long(3), S.integration_short, S.onsets_occur, ...
                        S.iti_long(2), S.vp.cohlist );
                else
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_long(1), ...
                        S.iti_long(3), 0, S.onsets_occur, ...
                        S.iti_long(2), [0] );
                end
            case 4 %%%'ITIL_INTEL' long variable intertrial intervals,long integration period = coherent motion period 
                [ S.ITIL_vec_intel{j}, S.blocks_shuffled{j}, ...
                    S.blocks_coherence_cells{j} ] = ...
                    calculate_epoch_lengths( S.total_stim_epoch, ...
                    S.totalframes_per_block, S.iti_long(1), ...
                    S.iti_long(3), S.integration_long, S.onsets_occur, ...
                    S.iti_long(2), S.vp.cohlist );
                S.block_coherent_cells{j} =  S.integration_long;

                S.block_ID_cells{j} = '4'; 
                S.ITIS_vec{j} = S.ITIL_vec_intel{j};
                % calculate VMPs for this block
                if vert_motion == 1
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_long(1), ...
                        S.iti_long(3), S.integration_long, S.onsets_occur, ...
                        S.iti_long(2), S.vp.cohlist );
                else
                    [S.iti_vec_v{j}, S.coh_incoh_vec_v{j}, S.cohs_v{j}] = ...
                        calculate_epoch_lengths( S.total_stim_epoch, ...
                        S.totalframes_per_block, S.iti_long(1), ...
                        S.iti_long(3), 0, S.onsets_occur, ...
                        S.iti_long(2), [0] );
                end
        end
    end % create blocks for each condition

    %%%--- Dot Buffers for continuous motion version ---%%%

    for i = 1:numel(S.vp.condition_vec) % loop through all blocks 
        % Matrix with 3 sets of dots 2 * S.ND * 3. First row is is x coordinate,
        % second is y coordinate, S.Nd number of columns indicates numbers of dots
        % and 3rd dimension indicates the set of dots.
        S.xy{i} = zeros(2,S.Nd,S.totalframes_per_block);


        % generate buffer for noise dots that come on after button press during
        % coherent motion in continuous motion version, number of frames we
        % generate is total number of coherent motion periods within block times
        % the integration time of the block 
        S.xy_noise{i} = zeros(2,S.Nd,(max(max(S.blocks_shuffled{i})).* S.block_coherent_cells{i}));


         % initialise vectors to save mean coherence and actual coherence for every
        % frame 
        S.mean_coherence{i} = zeros(S.totalframes_per_block,1); % mean coherence 

        % around which the actual coherence (S.coherence_frame) oscilllates 
        S.coherence_frame{i} = zeros(S.totalframes_per_block,1);

        % pre allocate space for noise frames, which is used to save coherences of
        % noise frames that fill up coherence frames after button presses 
        S.mean_coherence_noise{i} = zeros(S.block_coherent_cells{i}.* max(max(S.blocks_shuffled{i})),1);
        S.coherence_frame_noise{i} = zeros(S.block_coherent_cells{i}.* max(max(S.blocks_shuffled{i})),1);
        % S.blocks_shuffled_noise{i} = zeros(S.block_coherent_cells{i}.* max(max(S.blocks_shuffled{i})),1);
        S.blocks_shuffled_noise{i} = zeros(S.totalframes_per_block,1);
        % S.totalnoise_frames{i} = S.block_coherent_cells{i}.* max(max(S.blocks_shuffled{i}));
        S.totalnoise_frames{i} = S.totalframes_per_block;
        % pre-allocate space to vector saving frame sequence. Next frame is calculated
        % the following way: current time stamp of completed flip execution +
        % tconst.flipint (flip interval) to measure when next flip should occur -
        % starttime of first frame of motoin. This all gets divided by
        % tconst.flipint (flip interval) We round this number to get an integer. 
        S.f{i} = zeros(S.totalframes_per_block,1);
    end

    % buffer for coherence probability - coherence is used as probability.
    % Randomly assigned number between 0 and 1, all dots with number below coh
    % level will be signal dots
    S.coh_prob = zeros(1,S.Nd,S.totalframes_per_block);
end % if discrete trials 

sca % close ptb screen 

end % Init task param function


%% additional functions

function ppd = metpixperdeg(mm, px, sub)
%
% ppd = metpixperdeg ( mm , px , sub )
%
% MATLAB electrophysiology toolbox. Convenience function to calculate the
% pixels per degree of visual angle. mm is the length of the screen along a
% given dimension in millimetres, while px is the length along the same
% dimension in pixels. sub is the distance in millimetres from the
% subject's eyes to the nearest point on the screen i.e. the distance along
% a line that is perpendicular to the screen and passes through the eye.
%
% mm and px must be numeric matrices that have the same number of elements,
% such that mm( i ) and px( i ) refer to the ith dimension of the screen.
% sub must always be a scalar numeric value. All numbers must be rational
% and greater than zero.
%
% Returns column vector ppd that has the same number of elements as mm and
% px, where ppd( i ) is the number of pixels per degree along the ith
% dimension.
%
% Written by Jackson Smith - Dec 2016 - DPAG , University of Oxford
%

% NB. Maria: we use ppd(1) = xdimension as coefficient to transform visual
% deg ree in pixel, see Jacksons remark:

% To calculate the degree-to-pixel coefficient, you need to use some dimension
% of the screen. But the way that metpixperdeg estimates this coefficient gives
% you the same answer whether you use the width or height, assuming that pixels
% are an equal width in both dimensions. This is because it estimates the distance
% from the centre of the screen in mm for one degree of visual angle, and then
% divides that by pixels per millimetre. Width happens to be the most convenient
% dimension to use because it is the first value returned by PsychToolbox.
% It is also the most relevant dimension when you are studying stereoscopic vision.


%%% Error checking %%%

% Check millimetre dimension measurements
if  isempty ( mm )  ||  ~ isnumeric ( mm )  ||  ~ isreal ( mm )  ||  ...
        any (  ~ isfinite ( mm )  |  mm <= 0  )
    
    error ( 'MET:metpixperdeg:input' , ...
        [ 'metpixperdeg: Input arg mm must have finite real values ' , ...
        'greater than 0' ] )
    
    % Check pixel dimension measurements
elseif  isempty ( px )  ||  ~ isnumeric ( px )  ||  ...
        ~ isreal ( px )  ||  any (  ~ isfinite ( px )  |  px <= 0  )
    
    error ( 'MET:metpixperdeg:input' , ...
        [ 'metpixperdeg: Input arg px must have finite real values ' , ...
        'greater than 0' ] )
    
    % Check subject distance
elseif  numel ( sub ) ~= 1  ||  ~ isnumeric ( sub )  ||  ...
        ~ isreal ( sub )  ||  ~ isfinite ( sub )  ||  sub <= 0
    
    error ( 'MET:metpixperdeg:input' , ...
        [ 'metpixperdeg: Input arg sub must be a scalar, finite ' , ...
        'real value greater than 0' ] )
    
    % Check that mm and px have the same number of values
elseif  numel ( mm )  ~=  numel ( px )
    
    error ( 'MET:metpixperdeg:input' , ...
        'metpixperdeg: mm and px must have the same number of elements' )
    
end


%%% Compute pixels per degree %%%

% Compute millimetres of screen per degree of visual angle
mm_deg = sub  *  tand ( 1 ) ;

% Then compute pixels per millimetre of screen
pix_mm = px( : )  ./  mm( : ) ;

% And finally, pixels per degree
ppd = mm_deg  *  pix_mm ;


end % metpixperdeg

