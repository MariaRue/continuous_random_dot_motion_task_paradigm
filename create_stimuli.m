function [S,tconst] = create_stimuli(paramstxt,debug,session,discrete_trials,integration_window,ordered_coherences,filter_on)

% PURPOSE: This function creates either (1) continous random dot or (2) discrete 
% random dot stimuli, by creating a structure 'S' which has all
% the relevant stimulus information. (tconst is another structure which 
% holds screen and PTB parameters.) This structure is then used when 
% calling the rdk_continuous_motion function, to actually render the 
% stimuli on the screen.

%%% continuous rdm version 
% During a session of continous random dots, periods of incoherent and
% coherent dot motion are interleaved. In the coherent motion periods,
% some dots will move either to the left or to the right while the others 
% continue to move randomly. Each session consists of several blocks in 
% which the length of incoherent and coherent motion periods can be 
% altered. In the continuous rdk version, the coherence level oscillates 
% with some sd around 0 during incoherent motion periods.

%%% discrete trials rdm 
% In sessions with discrete trials, only coherent motion is shown for a
% given period for each trial. 

% Most parameters are defined in a tabular .csv file (see below). Edit this
% file before each subject starts, as you will probably want to test
% different parameters in each session. (GUI is a WIP, where you will be
% able to edit parameters straight away.)

% To make this function run, change the root variable below to preferred
% directory.

% NB. This function uses PsychoToolBox (PTB)! Download and install it if
% you haven't already.


%%-- Input --%% 

% paramstxt                 - path to .csv file containing
%                               parameteres

% debug                     -  0 : on any other computer than mac full screen 
%                                  window and framerate set to monitor refresh rate task 
%                              1 : small window for debuging 
%                              2 : full window but monitor refresh rate set to 60hz - use
%                                  on mac 
%                              3 : small window, refresh rate set to 60hz 

% session                   - number indicating session 

% discrete_trials           - flag 1 if discrete trials are shown (used for
%                               training), 0 otherwise

% integration_window        - flag 1 if long stimulus presentation in
%                               discrete trial version, 0 short integration period used

% ordered_coherences        - flag 1 only for discrete trials, means that if we have for
%                               example coherences -0.5/0.5 -0.6/0.6 -0.7/0.7 
%                               that first trials with -0.7/0.7 coherences 
%                               are displayed in random order than trials with
%                               -0.6/0.6 and so on 
%
% filter_on                 - flag, 1 use filtered white noise for
%                               intertrial periods, 0 use jumping stimulus 



%%-- paramaters in .csv file --%%
% Note that dot sizes etc. are not in pixels or similar, but in visual
% degrees!

% subid                     - number assigned to participant 
% subgender                 - f,m
% subage                    - in years 
% expday                    - dd/mm/yy
 
% scrwidth                  - width of screen in mm 

% scrheight                 - height of screen in mm 

% subdist                   - distance of subject's eyes to centre of screen in mm 

% dotsice                   - diameter of moving dots in visual degrees 

% fixsize                   - diameter of fix dot in visual degrees 

% trgsize                   - diameter of targets in visual degrees 

%% Below should be dots/(degrees squared) ?
% density                   - density of dots in dots/squared degrees 
%% Continue

% speed                     - speed of moving dots in degrees per second 

% dot_type                  - the value provided to Screen DrawDots. Says how to render
%                               dots. 0 draws square dots. 1, 2, and 3 draw circular dots with
%                               different levels of anti-aliasing ; 1 favours performance, 2
%                               is the highest available quality supported by the hardware, and 3 is
%                               a built-in implementation which is automatically used if
%                               options 1 or 2 are not supported by the hardware. 4, which is
%                               optimised for rendering square dots of different sizes is not
%                               available as all dots will have the same size.

%% What is a 'stimulus aperture'? Also, define other things here.
% ap_radius                 - radius of stimulus aperture in visual degrees. 

% direction                 - defines whether positive coherence is defined as rightward -
%                               changes during block 

% cohlist                   - probabilities that dots are signal dots moving either to the
%                               right (+) or to the left (-) in fractions 

% block_length              - length of a single block in minutes

% target_location           - x - coordinate of target in visual degrees 

% feedback_duration         - duration of feedback in secs (fix dot colour 
%                               change after response or missed response)

% coherence_sd              - standard deviation for coherence white noise
%                               during incoherent motion period

% gap_after_last_onset      - minimum amount of time in secs for which incoherent motion
%                               is shown at end of block after

% gap_before_first_onset    - minimum amount of time in secs for which incoherent motion
%                               is shown before first trial/coherent motion period

% itishort                  - interval from which intertrial intervals 
%                               (ITIs) are randomly drawn with uniform 
%                               distribution if intertrial intervals are 
%                               defined as short. first number = lower 
%                               bound, sencond number =  mean, third 
%                               number = upper bound in seconds

% itilong                   - same as itishort just for condition that intertrialintervals are
%                               long 

% shortINT                  - duration of a single coherent motion/trial period for
%                               short integration conditions (integration
%                               is the time length of a trial)

% longINT                   - same as short INT but for condition long integration 

% point                     - points won on each trial, first number = correct response during
%                               trial, second number = incorrect response during trial, third number =
%                               response during incoherent motion, fourth number = missed response 

% linewidth                 - of cross that is shown during training in visual degrees 

% linesize                  - of cross that is shown during training in visual degrees 

% condition_vec             - vector of integers 1 to 4, indicating sequence of blocks 
%                               Options: 
%                               1 = short ITIs, short integrations
%                               2 = short ITIs, long integrations 
%                               3 = long ITIs, short integrations 
%                               4 = long ITIs, long integrations

% totaltrials               - total number of trials in discrete trials version 

% flex_feedback             - time participants can respond after coherent
%                               stimulus was on in sec

% triangle_size             - vector in visual degrees [length of hypotenuse, 
%                               height of triangle] for feedback if coherent
%                               motion stimulus has been missed 

% square_size               - lenght of one side of square in visual
%                               degrees for feedback if participant has responded 
%                               during incoherent motion period 

% triangle_pen_width        - linewidth of triangle for feedback in visual
%                               degrees 

% rewbarcol                 - after button press in continous motion,
%                             points won or lost by button press are shown 
%                             as little first white bar and then in green 
%                             for won or red for lost points at end of reward bar,
%                             this variable in seconds determines how long this is shown 

% pre_incoh_mo              - time (in seconds) of incoherent motion shown before it
%                             turns to coherent in discrete trial version 
% 
% trialsperpound            - number of correct trials needed to win 0.5 if
%                             participant would respond only corret 
%
% noise_amplitude           - factor by which the lowpass filtered noise is
%                             amplified to introduce pulses of coherent
%                             motion with different strengths 
% 
% passbandfreq              - passbandfrequency for lowpassfilter to filter
%                             incoherent motion period in hz 
%
% stopbandfreq              - stoppbandfrequence for lowpass filter also in
%                             hz 

% passrip                   - passbandripple for lowpass filter 

% stopbandatten             - stopbandattenuation for lowpass filter 

% flipSecs                  - number of screen flips per second if display
%                               stimulus at a different rate than the refresh 
%                               rate of the monitor

% mean_duraion              - for jumping stimulus mean leangth before next
%                               jump occurs, this is drawn from an exponential 
%                               distribution 

% trig_thresh               - number of jumps in coherent motion between
%                               triggers send to EEG and eyelink - this is 
%                               done for matching up behavioural and EEG 
%                               data after the recording (default 25) 

% annulus                   - radius of annulus around fix dot in which no
%                              dots are shown (in visual degrees) 

% str_train                 - amount of time for discrete trial usual rdk
%                              display as done in shadlen 
%
% rewbarlocation            - distance to border of stimulus aperture in y
%                             direction (in visual degrees) - is above
%                             screen center + is below screen center for y
%                             value, x is always centre of screen - given
%                             in x,y coordinates 
%
% rewbarsize                - width X height - visual degrees 
% 
% fixdotlocation            - in distance in visual degrees from centre of
%                              screen (x,y) and stimulus + = below centre, - = above
%                              centre for y value, x value is always centre
%                              of screen


%%-- Output --%% 
% Returns two structures that are important to run task with
% rdk_contionous_motion

% S = structure with stimulus paramaters, trial info, the field 'vp' has 
%   a copy of all the parameters in their original units 

% tconst = screen, ptb parameters 

% These structures are saved in a file in a subject-specific folder as
% described by the 'root' variable (see below) 

% Subject-specific folders follow the convention: sub000 - 000 identifiying
% subject ID 

% Stimulus files in which S and tconst are saved are named the following
% way: sub000_sess000_stim.mat -> sub000 = subject id and sess000 = session
% id 

% Maria Ruesseler, University of Oxford 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Where stimuli are saved in subject specific folders 
 % this is in the EEG lab
 % NB. This can be changed by the user!
 
 root =    'C:\experiments\Maria_contin_motion\stim';
 
% Neb: prompt user for root if want to change it
%  temp_string = strcat('Would you like to change the path to where stimuli are saved? The current root is ', root, '. 1 = Yes, 0 = No\n');
%  if input(temp_string)
%      root = input('Please enter pathway to folder to save stimuli:');
%  end
%  clear temp_string;

% This is on macs
% root = '/Users/maria/Documents/data/data.continuous_rdk/EEG_pilot/stim/'; 

% This is on eyetrack in test2 
% root =    'C:\Users\student01\Desktop\maria_ruesseler\continuous_rdk_task\stim';

  
% Add this path to your MATLAB workspace 
addpath(genpath(root));


%%-- Define parameters for the session --%% 

% Read in parameters from .csv file and determine which parameters should
% be read in as numbers - these are usually in units of visual
% degrees/seconds and will have to be transferred into units MATLAB and PTB
% can work with (see description of variable parameters above) 

par2num = {'subid';
    'scrwidth';
    'scrheight';
    'subdist';
    'dotsize';
    'fixsize';
    'trgsize';
    'density';
    'speed';
    'dot_type';
    'direction';
    'ap_rad';
    'cohlist';
    'block_length';
    'target_location';
    'feedback_duration';
    'coherence_sd';
    'gap_after_last_onset'; 
    'gap_before_first_onset';
    'itishort';
    'itilong';
    'shortINT';
    'longINT';
    'point';
    'linewidth';
    'linesize';
    'condition_vec';
    'totaltrials';
    'flex_feedback';
    'triangle_size';
    'square_size';
    'triangle_pen_width';
    'rewbarcol';
    'pre_incoh_mo';
    'trialsperpound'
    'noise_amplitude';
    'passbandfreq';
    'stopbandfreq';
    'passrip';
    'stopbandatten';
    'mean_duration'; 
    'sd_duration'; 
    'trig_thresh';
    'annulus';
    'str_train';
    'rewbarlocation';
    'rewbarsize';
    'fixdotlocation'};

% save the parameters from the xls file to the structure vpar 
vpar = readparamtxt(paramstxt, par2num);

% add the session number to this parameter set 
vpar.session = session; 


% outdir - where we save output stimfile
outfolder = sprintf('sub%03.0f',vpar.subid); % updated foldername for a subject
outdir = fullfile(root,outfolder); % complete path to output folder 

outfile = sprintf('sub%03.0f_sess%03.0f_stim.mat',vpar.subid,session); % updated filename


% check whether a stimulus file for this session already exists
if exist(outdir,'dir')  % check whether folder for subject exists first 
    if exist(fullfile(outdir,outfile),'file') == 2 % if file already exist return
      fprintf('\n\n\nA file with this subject and session already exists!\nPlease specify other session...')
      sca % PTB function, closes all screens
      return   
    end
else % if folder for subject doesn't exist in stim folder then make one 
    mkdir(outdir)
end


%% Neb: we can factorise init_task_param out from the IF statement as it's 
% common to both clauses
if discrete_trials % if discrete trials are used
    %%%--- initialise stimulus descriptor and screen parameters ---%%%
    [S,tconst] = init_task_param(vpar,debug,discrete_trials,integration_window,ordered_coherences);
    %%%--- create rdks ---%%% 
    [S] = init_stimulus(S,discrete_trials,tconst);
else % for continous motion session 
    %%%--- initialise stimulus descriptor and screen parameters ---%%%
    [S,tconst] = init_task_param(vpar,debug,discrete_trials,integration_window,ordered_coherences);
    %%%--- create continuous rdks ---%%%
    [S] = init_stimulus(S,discrete_trials,tconst,filter_on);
end % if discrete trials are used 

%%%--- save file ---%%%
savePath = fullfile(outdir,outfile);
save(savePath,'S','tconst');

end % function create_stimuli 



