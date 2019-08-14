function [S,D,tconst] = rdk_continuous_motion(paramstxt, training, session, rewardbar, annulus, subid, age, gender, feedback)

%% Neb: Also change flags for EEG and elink below (when calling present_rdk)! Important!

% PURPOSE: This function is the one which actually runs the task to display
% continous random dot stimuli, as determined by create_stimuli (which you 
% *must* have called before calling this function).

% During a session of continous random dots, periods of incoherent and
% coherent dot motion are interleaved. In the coherent motion periods,
% some dots will move either to the left or to the right while the others 
% continue to move randomly. Each session consists of several blocks in 
% which the length of incoherent and coherent motion periods can be 
% altered (see block_length and condition_vec below).
% 
% In sessions with discrete trials, only coherent motion is shown for a
% given period for each trial (see integration_window below). 
% 
% To make this function run on a desktop, change the root variables below 
% to preferred directories and change device_number(2) to device_number(1)
% in present_rdk.mat and discrete_rdk_trials_training.mat (some laptops 
% only accept device_number(2) for some strange reason).
%
% Responses are made by pressing the letters A (left) and L (right)
% 
% Feedback is given after each trial by changing colour of fix dot in the 
% centre of moving dots: 
%      Green   - correct response during
%                coherent motion 
%      Red     - incorrect response during
%                coherent motion 
%      Blue    - missed coherent motion 
%      Yellow  - response during incoherent
%                motion (this cue is not in discrete trial version)

%%-- Input --%% 

% training  = (flag) if 1, fixdot is white during trials, otherwise no
% session   = number indicating session 
% rewardbar = 1 if displayed, 0 otherwise (passed on)
% annulus   = 0/1 if no/yes presence for annulus (empty ring around fixdot)
% subid     = ID assigned to participant (as number), e.g. 4
% age       = participant age
% eeg       = 0 if you haven't got them connected, 1 if yes
% feedback  = whether to show feedback after each block (0 no, 1 yes)

%%-- Output --%% 

% D = respMat = response output matrix, lines indicating trial or response (in continuous motion version)  
%               column: 
%                       1: points won on current trial or for current
%                           response (check paramte.csv and create stimuli for
%                           more details on exact points that can be won or
%                           lost for a response)
%                       2: reaction time in secs 
%                       3: choice, 0 left, 1 right 
%                       4: coherence of dots 
%                       5: choice correct 1, incorrect 0  
%                       6: frame on which response
%                          occured 
%                       7: flag for type of response,
%                          0 incorrect response during coherent motion 
%                              (pressed one button when should've pressed
%                              the other) 
%                          1 for correct response during coherent motion 
%                          2 early response during incoherent motion
%                              (pressed left or right during incoh.)
%                          3 missed response to coherent motion (should've 
%                              pressed either left or right, depending on 
%                              trial, but missed it) 
%                          4 correct suppression of response during single
%                          trial version
% S          = structure with stim paramaters and trial info 
% tconst     = screen and PTB parameters 
% (See documentation for the fields of each of these structures.)
%
% These 3 parameters are saved in a subject specific folder, e.g. sub001
% and a subject and session specifil file name, e.g.
% sub001_sess001_behav.mat 

% Additionally a sub000_reward info file is saved that is a matrix with as
% many lines as sessions and 2 columns. The first column is the total
% amount of points that are already filled in the reward bar, the second
% column indicates the total amount of pounds already won. This helps to
% keep track of the reward earned across sessions.
% Participants don't have to start afresh to fill a reward
% bar when starting a new session, and it keeps track of how many pounds 
% have already been won. 

%%% STIMULUS AND BEHAVIOURAL OUTPUT FILE LOCATIONS %%%

% input directories
paths = readparamtxt(paramstxt, []);
% where you keep the stimulus files
root_stim_file = paths.root_stim;
% where you keep participants' output (i.e. behaviour)
root_outfile = paths.root_output; 
% do we have eeg and/or eyelink connected?
eeg = paths.eeg;
eyelink = paths.eyelink;
 
%%%--- 1. Set up file paths; load and save files ---%%%
infile = sprintf('sub%03.0f_sess%03.0f_stim.mat',subid,session); %updated input filename of subject and session
infolder = sprintf('sub%03.0f',subid); %updated input foldername of subject
indir = fullfile(root_stim_file,infolder); % full path to input folder
complete_path_infile = fullfile(indir,infile);

[stim_struct] = load(complete_path_infile); % load input file for session 

% save variables of input file in new structures
S = stim_struct.S; 
S.vp.subage = age;
S.vp.subgender = gender;
tconst = stim_struct.tconst; 
 
discrete_trials = S.discrete_trials; 

% outdir - where we save output file
outfolder = sprintf('sub%03.0f',subid); %updated foldername subject specific
outdir=fullfile(root_outfile,outfolder); % root to subject specific folder
outfile=sprintf('sub%03.0f_sess%03.0f_behav.mat',subid,session); %updated filename ouf output 

% add path to subject folder, needed later to load reward_info file which
% stores information about how many points and coins participant has
% already won in previous sessions 
addpath(outdir); 

% check whether this file and session already exist for subject 

if exist(outdir,'dir') % check whether folder exists  
    if exist(fullfile(outdir,outfile),'file') == 2 % if file already exist return 
        fprintf('\n\n\nA File with this subject and session already exists!\nPlease specify other session...')
        sca
        return
    end
else % if folder doesn't exist yet, create folder for subject
    mkdir(outdir) 
end % if file exists

%%%--- 2. Present stimulus (i.e. what the subject sees) ---%%%
if discrete_trials % If function called to run with discrete trials...
    [D,S] = discrete_rdk_trials_training(S,tconst,rewardbar,training,outdir,outfile);
else % ...otherwise, with continuous trials 
    [S,D,tconst] = present_rdk(S, tconst, training,outdir,outfile,rewardbar,eeg,eyelink,0,annulus, feedback); 
end

end