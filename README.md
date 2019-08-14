## Table of Contents
-	<a href="#hardware-requirements">Hardware requirements</a>
- <a href="#software-requirements">Software requirements</a>
- <a href="#summary">Summary</a>
- <a href="#running-the-task">Running the task</a>
- <a href="#training-participants">Training participants</a>
- <a href="#code-explanation">Code explanation</a>
- <a href="#function-calls">Function calls</a>
- <a href="#analysis-scripts">Analysis scripts</a>
- <a href="#other">Other</a>

## Hardware requirements
-	I/O port to talk to EEG computer
-	Screen refresh rate needs to be stable (no dropping frames!)

## Software requirements
-	PTB version 3 (link: http://psychtoolbox.org/download)
-	MATLAB version 2019a
-	If using EyeLink, latest EyelinkToolbox for PTB (link: http://psychtoolbox.org/docs/EyelinkToolbox)

## Summary
These scripts run a random-dot motion perceptual decision-making task, modelled after Shadlen and Newsome (2001) and O'Connell, Dockree, and Kelly (2012). Participants are required to fixate their gaze on a central “fix dot” in the task, while dots around this fix dot move either incoherently or coherently to varying extents. The participant then makes responses regarding the direction of movement of the dots (see below) by integrating perceptual information about dot movement.

The dots in the task can be divided into two groups: **signal** and **noise dots.** Noise dots are those which move incoherently, meaning randomly in all directions. All dots are noise dots during incoherent motion periods, otherwise known as *intertrial intervals* (ITIs). Signal dots are those which move coherently (i.e. all together, in one direction) *horizontally* during coherent motion periods, and are a proportion of all dots (the rest remain noise dots). (**NB** that signal dots are only those dots which move coherently *but in a horizontal direction*: if we have dots which are moving coherently but in a vertical direction (see below—our lab has used this to control for surprise) we still classify them as “noise dots”, albeit the “vertically moving” subgroup of noise dots.)

**Coherence** is the proportion of signal dots out of total dots: if coherence is 30%, then that proportion of dots is undergoing coherent motion, while the rest are still moving noisily (in random directions).

The scripts can run one of three different types of task: (1) **discrete-committed**, (2) **discrete-averaged**, and (3) **continuous-averaged**. The first field refers to whether the trials are separated from one another by obvious gaps: if they are, they are *discrete*; if they aren’t, they are *continuous*. The second field refers to how the signal dots move. In committed trials, signal dots all move in one direction only all the time, and the participant is required to simply respond which direction it is as soon as they notice the movement. (This type is only usually used for training participants.) In averaged trials, signal dots can and do change the direction of movement through the trial, and the participant has to respond to the *average* direction of movement across the trial, thus integrating information over some period of time.

**Note:** The file *documentation_structures.xlsx* can be used as a reference for the function of different variables. This will mostly be useful when trying to understand the different scripts in the first couple of weeks; soon enough, you will learn what variables do by heart due to constant exposure and retrieval practice.

## Running the task

**First, you must do the following things**:
1. *Set up your parameter.csv file*. You need to change the following parameters in this file **before** you run your code for the first time in your lab, or it won't work:
  - **subid**: change this when creating a stimulus file for **each participant**.
  - **scrwidth**, **scrheight**, and **subdist**: these are the width and height of your screen, and the distance between the subject's eyes and the centre of the screen **in millimeters**! This is done so that the size of all stimuli in terms of visual degrees are the same across labs (the code automatically reads your resolution and converts visual degrees to pixels, don't worry).
  - **root_stim** and **root_output**: these are the paths to the folders where you want the code to output its stimulus (root_stim) and behavioural data (root_output) files.
2. *Ensure the code runs well*. Set your parameter.csv **subid** to a random number you won't use again (e.g. 777) and **block_length** to 1. Then, create three test sessions (i.e. create stimulus files, one for each session) by running these lines of code (you can run them all together). Don't worry, this document explains what these functions are/do a bit further down, but just run them for now to ensure the code works well.
> create_stimuli(‘parameter.csv’, 0, 1, 1, 1, 1, 0);

> create_stimuli(‘parameter.csv’, 0, 2, 2, 0, 0, 1);

> create_stimuli(‘parameter.csv’, 0, 3, 0, 0, 0, 0);

Then, run the following lines *individually*. Each line runs the task for a different session (one each we created above). For the first line, you should expect only to have discrete trials and committed horizontal motion. For the second, discrete trials with averaged motion *and* vertical motion, and for the third, continuous trials with averaged motion *without* vertical motion.
3. *Go through running_the_task.docx to see how we run the code.* This document contains a list of code lines you can use directly to run the code with different types of trials (e.g. discrete-committed, vertical/no vertical motion, etc.) both for training and actual experiment.

Now that everything works, let's have a look at how the code is structured and functions.

Only two functions are used to run the task. The first one creates a stimulus file for a specific subject and session (containing many things, including the X/Y positions of the random dots during the task), and this stimulus file is then loaded and rendered by the second function. They are:

1.	**create_stimuli()** must be used first for every session. This function creates a stimulus file containing all the relevant information required for a specific session, such as the type of task, the X/Y positions of all dots across all trials, the screen size, etc.
- Note that each stimulus file is specific for the parameters with which it was created (i.e. those in the parameter file, which is ‘parameter.csv’ by default). So, for example, if it was created with certain parameters about screen size (width and height) running the task using that file on a different screen would be inappropriate.
- Practically, we set up all stimuli files for all sessions before the participant has even arrived at the lab, so that they don't have to wait more than they have to.
2.	**rdk_continuous_motion()** runs the task from a specific session (i.e. stimulus) file. It can modify the task to some limited extent (e.g. whether the fix dot turns white during trials, which is used during training) but most properties are found in the file.

Their arguments are:
**create_stimuli**(paramstxt, debug, session, discrete_trials, integration_window, ordered_coherences, vert_motion)
-	paramstxt: char array, filename of parameters file (default is ‘parameter.csv’)
-	debug: flagged from 0-3, runs task with different settings to help debug
-	session: session number for creating stimulus file
-	discrete_trials: flag, 1 if discrete trials are to be used (used for training), 0 otherwise
-	integration_window: (discrete tasks only) flag 1 if participant has long integration window (i.e. long time to make a decision), or 0 for short
-	ordered_coherences: (discrete tasks only) flag 1 if coherences are to be ordered in descending order (e.g. -0.7/0.7, then -0.6/6, then -0.5/0.5, etc.) with each of the two plus/minus one having equal chance to be presented first (used only for training)
-   vert_motion (discrete-averaged and continuous trials only): flag 1 if you want to have vertical motion with "trials" corresponding to the horizontal motion used, 0 if you don't want any vertical motion

**rdk_continuous_motion**(paramstxt, training, session, rewardbar, annulus, subid, age, gender, feedback)
-	paramstxt: same as above
-	training: flag, 1 if training (turns fix dot white during trials), 0 otherwise (no change)
-	session: integer, session ID (to load relevant stimulus file)
-	rewardbar: flag, 1 if want to show reward bar after responses (used for training), 0 otherwise (e.g. during EEG task)
-	annulus: flag, 1 if you want to draw an annulus around the fix dot (a ring-shaped area of empty space, where noise and signal dots won’t appear), 0 otherwise
-	subid: integer, participant’s ID number
-	age: integer, participant’s age
-	gender: categorical string, participant’s gender (‘m’, ‘f’, or ‘o’)
- feedback: flag, 0 if no feedback after each block, 1 if feedback after each block, 2 if feedback at the end of session only

*Usually* (modify as necessary) you will call these functions like this:

When training subjects:

> create_stimuli('parameter.csv', 0, <session>, 1, 0/1, 0, 0);

When recording data (EEG and maybe Eyelink):

> create_stimuli('parameter.csv', 0, <session>, 0, 0, 0, 0);
  
Again, check running_the_task.docx to see how we run our code if you're confused.

## Training participants
This involves exposing participants to different forms of the task which become more difficult and more representative of the real task over time. An example training document (which helps you during training, especially with the respect to the code you need to run) can be found in *training_doc.docx*. The first two sessions are discrete-committed, then three (i.e. 3-5) are discrete-averaged, and the last seven (i.e. 6-12) are continuous-averaged.

## Code explanation
As explained above, all tasks are composed of two types of periods: incoherent motion (i.e. **intertrial** periods, or ITIs) and coherent motion (i.e. **trial** periods). Sessions always start and end with incoherent motion.

In coherent motion periods, some proportion of dots (determined by the coherence—for example, 0.3 coherence means 30% of dots) referred to as signal dots move in unison either to the left or to the right on average (as they can shift their direction during their movement). The participant must then integrate this motion, and correctly answer which direction they were moving in on average during the trial. In committed tasks (these are used just for doing the very beginning of the training, usually) these is just one set value of coherence (e.g. -0.6) for an entire coherent motion period, meaning some proportion of dots (e.g. here, 60%) move in one direction (here, left, because the coherence is negative). In averaged tasks, coherent motion periods have some mean (i.e. arithmetic average) coherence, and the actual coherence differs from frame to frame.

In incoherent motion periods, the coherence is not zero; instead, it varies around a mean of zero over the incoherent motion periods (this is why you can see some coherence during incoherent motion when you run the task). In continuous tasks, ITIs are subdivided into “steps” each lasting a different amount of time (in frames), sampled from an exponential distribution*. Then, each “step” is assigned a coherence (i.e. each frame in that step has the same coherence, sampled from an exponential distribution*) such that the mean of the coherences of all the steps in an ITI is zero. Once we combine these ITIs with coherent motion periods, the resulting vector (called coherence_frame, see below) looks like this:

![Image of Feedback](/coherence_frame_example.png)

As you can see, there is one coherence value for each frame (any coherences below -1.0 and above 1.0 are treated as just being -1.0/1.0 respectively, as we can’t have more than 100% of signal dots moving in unison…). If you look closely, you may be able to notice that the mean coherence varies, because this is a graph of an entire block (~10,790 frames) and thus while most of the block is incoherent motion periods (mean coherence = 0) some parts of it have a higher or lower mean coherence.

Notable variables:
-	coherence_frame: (continuous tasks only) one exists for each block in a session (saved under S.coherence_frame{block}). Length equals total number of frames in block, and holds the coherence for each frame in the block. See above for an example plot.

*Addendum:* Vertical motion.
In order to control for surprise, we must have a condition which is exactly equal to the experimental condition, but the participant is not required to respond, and is only required to integrate the movement to see whether they need to respond or not. We do this by making some dots move vertically during certain vertical motion periods, which are made and distributed just like coherent motion periods. Out of the subset of noise dots (non-horizontally moving dots) we take another subset of dots, called the vertically moving dots, and make them move up or down coherently depending on the period, very similarly to how signal dots are made to move left or right coherently during trials. We split vertical and horizontal dots into two groups because if any dot moves both horizontally and vertically at the same time, it moves diagonally. Also note that it is not possible to have a coherence above ½ (i.e. more than half of all dots are made to move horizontally during coherent motion periods) and have this control condition, because then some dots will necessarily be made both vertical and horizontal dots, and thus diagonal.

The proportion of noise dots (i.e. non-signal dots, i.e. dots which will not ever be moving horizontally in the task) which must be assigned to vertical movement is a = A/1-A, where A is the proportion of all dots. Here is the proof:
1.	If A is the proportion of signal dots, then 1-A is the proportion of noise dots.
2.	Let a be the proportion of noise dots which are made vertically moving dots. Thus, the proportion of all dots which are vertically moving dots is a(1-A).
3.	The proportions of both types of dots out of the total number of dots must be equal, i.e. A = a(1-A).
4.	Rearrangement shows a = A/1-A for all A ≠ 0.

## Function calls
Below is a list of which functions are called in which order, and by what master function (could include being called by the unmoved mover: you!)
1.	**create_stimuli**: Called by you, creates stimuli (by returning two structures)
    - readparamtxt: reads .csv file containing parameters
    - init_task_param: input structures from create_stimuli, returns both after modification
    - metpixperdeg: transforms visual degrees into pixels
    - calculate_epoch_lengths: calculates lengths of (and assigns each frame to) incoherent and coherent motion in a block
    - init_stimulus: returns sequences of x-y dot positions (for either type of trial) in S structure
    - move_dots: calculates and returns matrix of x-y positions for *each dot* in *every frame*
    - calculate_coherence_vec: calculates a ‘coherence vector’, a vector with length F (passed in as a frame number, e.g.
2.	**rdk_continuous_motion**: Called by you, runs the task
    - EITHER discrete_rdk_trials_training (runs a discrete-trials task, for training)
      - PMF_RT_Plots: plots psychometric functions
      - process_PMF_data: calculates statistics required for plots
        1.	EITHER cum_Gauss_PMF: calculates cumulative Gaussian values at each x-range value for plotting later on,
        2.	OR logist_PMF: calculates fitted PMF for each point in x-range
    - OR present_rdk (runs a continuous-trials task)
      - recalculate_xy_position: recalculates random dot positions after a response during a trial for the remainder of the period

## Analysis scripts
This is a summary of all the analysis scripts that have been used for behavioural data. **NB**. These are the only scripts you need to run (i.e. of the form XX_analyse_YY)! Every other script in the repo is called by these master scripts.

1. AFR_analyse_FAR(): Returns the means and distributions of False Alarms (FAs) per subject, per condition, either (i) per unit total time or (ii) per unit ITI time.
2. AFH_analyse_FA_HR(): Returns scatterplots of FA (false alarm number) against HR (hit rate) per condition; each dot is one session, and same coloured dots come from the same subjects
3. AW_analyse_waveforms(): Returns the mean waveform in the period leading up to a false alarm, per condition (period set by argument)
4. AR_analyse_ratios(): Returns proportion correct responses (right and left presses) per coherence, proportion misses (right and left sides) per coherence, and both of these collapsed over sides (i.e. per absolute coherence) , all per condition
5. AD_analyse_distributions(): Returns histograms (distributions) of RTs and log RTs per condition
6. ARts_analyse_rts(): Returns RTs (mean per subject, mean per session) per coherence, as well as log RTs, all per condition

## Other
-	Ensure you measure screen width and height, and participants’ distances to screen in millimetres. **You need to put these into the parameters.csv file** in order to control for differences in lab arrangements, screen sizes, etc. when it comes to task data.

Here is an quick explanation of EEG/EyeLink triggers:

 - 201	Pressing “direction: right” button during coherent motion
 - 205	Pressing “direction: left” button during incoherent motion
 - 203	Participant missed coherent motion trial
 - 202	Pressing “direction: right” button during incoherent motion
 - 206	Pressing “direction: left” button during incoherent motion
 - 11	Sent every 70s
 - 210	Sent on last frame
 - 12	(?) Sent every minute
 - 23	Sent at beginning of incoherent motion (ITI)
 - 24	(?)

## References
1.	Shadlen, M. N. & Newsome, W. T. Neural basis of a perceptual decision in the parietal cortex (area LIP) of the rhesus monkey. *J. Neurophysiol.* **86**, 1916–1936 (2001)
2.	O’Connell, R. G., Dockree, P. M., & Kelly, S. P. A supramodal accumulation-to-bound signal that determines perceptual decisions in humans. *Nat. Neurosci.* **15**, 1729-1735 (2012) 
