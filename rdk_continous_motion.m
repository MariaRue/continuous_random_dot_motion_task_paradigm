function [D,S,tconst] = rdk_continous_motion(training,session,rewardbar,annulus,subid,age)

%% Neb: Rename to "continUous" instead of "continous"

% PURPOSE: This function is the one which actually runs the task to display
% either (1) continous random dot or (2) discrete random dot stimuli, as
% determined by create_stimuli (which you *must* have called before calling
% this function).
%
% Two major sections to this function.

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
% To make this function run, change the root variables below to preferred
% directories and change device_number(2) to device_number(1) in
% present_rdk.mat and discrete_rdk_trials_training.mat (my mac only accepts 
% device_number(2) for some strange reason) <--------------------- ?
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

% After 10 minutes in a discrete trial session, after each block in the
% continuous rdk version and at the end of each session PMFs and rt
% distributions are plotted, within a session one has the choice to either
% continue with a session by hitting 'y' and enter or to stop the current
% session by hitting 'n' and enter. In this case, all the data is getting
% saved and programme returns to matlab terminal. Experimenter can now
% start new session that is for example more appropriate for behavioural performance of
% participant <--------- ? does this still exist

%%-- Input --%% 

% training              - 1 cross shown for first 5 trials, 0 otherwise 

% session               - number indicating session 

% reward bar            - 1 if displayed, 0 otherwise 

% subid                 - ID assigned to participant (as number), e.g. 4

% Neb: should we remove annulus and rewardbar from this function's
% parameters? They seem never to be used.


%%-- Output --%% 

% D = respMat = response output matrix, lines indicating trial or response (in continuous motin version)  
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
%                          0 incorrect response during coherent motion, 
%                          1 for correct response during coherent motion, 
%                          2 response during incoherent motion, 
%                          3 missed response to coherent motion 
%                          4 correct suppression of response during single
%                          trial version

% S = structure with stim paramaters, trial info 

% tconst = screen, ptb parameters 

% These 3 parameters are saved in a subject specific folder, e.g. sub001
% and a subject and session specifil file name, e.g.
% sub001_sess001_behav.mat 

% Additionally a sub000_reward info file is saved that is a matrix with as
% many lines as sessions and 2 columns. The first column is the total
% amount of points that are already filled in the reward bar, the second
% column indicates the total amount of pounds already won. This helps to
% keep track of the reward earned across sessions.
% participants don't have to start afresh to fill a reward
% bar when starting a new session  and to get an idea how many pounds have alreadby been won. 


%% Where stimuli files are saved in subject specific folders, created with create_stimuli
% this is for eyetracker compouter in test2
% root_stim_file = 'C:\Users\student01\Desktop\maria_ruesseler\continuous_rdk_task\stim';
% % where you want to save the output files in subject specific folders
% root_outfile =     'C:\Users\student01\Desktop\maria_ruesseler\continuous_rdk_task\behaviour';

% this is for eeglab computer
 root_stim_file =    'C:\experiments\Maria_contin_motion\stim';
% where you want to save the output files in subject specific folders
 root_outfile =      'C:\experiments\Maria_contin_motion\behaviour';

% 
% % this is for mac
%  root_stim_file =  '/Users/maria/Documents/data/data.continuous_rdk/EEG_pilot/stim'; 
% % where you want to save the output files in subject specific folders
%  root_outfile =      '/Users/maria/Documents/data/data.continuous_rdk/EEG_pilot/behaviour';
 
%%%--- 1. Set up file paths; load and save files ---%%%
infile = sprintf('sub%03.0f_sess%03.0f_stim.mat',subid,session); %updated input filename of subject and session
infolder = sprintf('sub%03.0f',subid); %updated input foldername of subject
indir = fullfile(root_stim_file,infolder); % full path to input folder
complete_path_infile = fullfile(indir,infile);

[stim_struct] = load(complete_path_infile); % load input file for session 

% save variables of input file in new structures
S = stim_struct.S; 
S.vp.subage = age; 
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
else % if folder doesnt exist yet, create folder for subject
    mkdir(outdir) 
end % if file exists

%%%--- 2. Present stimulus (i.e. what the subject sees) ---%%%
if discrete_trials % If function called to run with discrete trials...
    [D,S] = discrete_rdk_trials_training(S,tconst,rewardbar,training,outdir,outfile);
else % ...otherwise, with continuous trials 
    [S,D,tconst] = present_rdk(S, tconst, training,outdir,outfile,rewardbar,1,1,0,annulus,0); 
end

end



