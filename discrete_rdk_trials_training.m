function [respMat,S] = discrete_rdk_trials_training(S,tconst,rewardbar,training,outdir,outfile)
% This function displays discrete rdk trials, displays feedback to
% participant and records participant behaviour. It also saves a
% reward_info file that holds information about how many pounds and how far
% reward bar was filled in the previous session.

% input: S = stimulus descriptor
%        tconst = PTB parameters
%        rewardbar = flag, 1 reward bar shown at end of trial, 0 no reward
%        bar
%        training = flag, 1 text describing what feedback means appears
%        above stimulus
%        outdir = folder in which reward_info and response behaviour is
%        saved
%        outfile = file name for response bevaviour

% output: S = stimulus descriptor
%         respMat = matrix with response behaviour

% and reward_info is saved

% open window

%%%--- SETUP: screens ---%%%
if S.debug == 2 || S.debug == 3
    Screen('Preference', 'SkipSyncTests',1);% 0 should be preferred but synch
    % problems on mac prohibit that. Exact synchronization not necessary because
    % integration across frames not measured as in single neuron electrophys
else
    Screen('Preference', 'SkipSyncTests',0);% 0 should be preferred but synch
    % problems on mac prohibit that. Exact synchronization for EEG experiment
  
end
PsychDefaultSetup(2);
screens = Screen('Screens');
if S.debug == 0 % hide cursor and suppress keyboard input in command window
    HideCursor;
   
end
% get correct screen number for screen on which we want to show task
tconst.winptr = max(screens);

%%%--- open window to display task ---%%%

% dev_mode=1 puts window in one corner of screen for easier debugging

if S.debug == 1|| S.debug == 3
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr,S.grey,[0 0 1048 786]);
else % use full screen window
    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr, S.grey);
    
end


disp('screen is set up');

%%%---SETUP: key response ---%%%
% Define the keyboard keys that are listened for. We will be
% using the left and right arrow keys as response keys
KbName('UnifyKeyNames');
% feedback on every trial
leftkey = KbName('A');
rightkey = KbName('L');

response_device = 'keyboard';
disp(['response device is ' response_device '.']);
[keyboardIndices, ~, ~] = GetKeyboardIndices;

% different on mac and windows, mac gives two numbers, windows only one
% indes, also for some reason on my personal laptop I have to use the 2nd
% entry, for other mac users it might be the first one
if S.debug == 2 || S.debug == 3
    device_number = keyboardIndices(2); % mac keyboard
else
    device_number = keyboardIndices; % mac keyboard
end

% create queue to wait for button press from keyboard
KbQueueCreate(device_number(1));


%%%--- SETUP: structure for behavioural responses ---%%%
respMat = NaN(S.vp.totaltrials,7);


%%%--- task instructions

Screen('TextFont',tconst.win,'Arial')
text = 'This is a discrete trial session! \n\n Press any key to move on';
DrawFormattedText(tconst.win, text, 'center', 'center', 0);

flipt=Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

text = 'You will see randomly moving dots. \n\n After a short time some of these dots will move either to the left or to the right.  \n\n Press the A key if dots move to the left and the L key if dots move the right';
DrawFormattedText(tconst.win, text, 'center', 'center', 0);
flipt=Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button

text = 'Please always try to fixate on the dot in the centre of the moving dots';
DrawFormattedText(tconst.win, text, 'center', 'center', 0);
flipt=Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button
    
if S.discrete_trials == 2
    
text = 'In this version of the task you will see that the dots change their direction between random, left and right really fast. \n\n Please try to guess in which direction the dots were most of the time moving by pressing A or L again \n\n In addition, the size of the circle will indicate how long you have to make that decision \n\n A large circle at the start means you have a longer time to integrate in comparison to a small circle';
DrawFormattedText(tconst.win, text, 'center', 'center', 0);
flipt=Screen('Flip',tconst.win);
KbStrokeWait(device_number) % next block starts after participant presses button
    
end 
 KbEventFlush(device_number);
    KbQueueStop(device_number);
%%%--- load reward matrix if exists ---%%%
% this has information about how many pounds have been one in previous
% trial and how far reward bar was filled

% check whether a reward_info file exists,
reward_file = sprintf('sub%03.0f_reward_info.mat',S.vp.subid);
if exist(fullfile(outdir,reward_file),'file')
    
    % if it does load it
    
    matrix = load(reward_file);
    reward_matrix = matrix.reward_matrix;
    
    S.coins_counter = reward_matrix(1,2); % money already won
    S.totalPoints = reward_matrix(1,1); % how far reward bar has been filled up in last session
    
else % if first session and reward matrix doesnt exist make one
    
    reward_matrix = zeros(1,2);
    S.coins_counter = 0;
    S.totalPoints = 0;
    
end % if reward_matrix exists

topPriorityLevel = MaxPriority(tconst.win);
Priority(topPriorityLevel);

timer = tic; % this tracks time,
% so that PMF and RTs can be calculated every ten minutes

%%%--- loop through trials ---%%%
for trial = 1:S.vp.totaltrials
    
    if S.integration_window == 1 && S.discrete_trials == 2
    size = S.fixdiameter(2); % start size of fix dot that gets reduced during integration period if training flag set to 2
    
    px = size/(S.discrete_stim_duration+70); % size of pixel shrink over trial period keyboard;
    size_org = S.fixdiameter(2);
    elseif S.integration_window == 0 && S.discrete_trials == 2
    size = S.fixdiameter(1); % start size of fix dot that gets reduced during integration period if training flag set to 2

    px = size/(S.discrete_stim_duration+100); % size of pixel shrink over trial period keyboard;
    size_org = S.fixdiameter(1);
    else 
       size = S.fixdiameter(1);
        size_org = S.fixdiameter(1);
    end 
    KbQueueStart(device_number(1)); % start recording button presses
    %%% get coherence and movement direction of signal dots %%%
    
     keyIsDown = 0;
    keydown = 0; % flag that indicates that button has been pressend on
    % previous trials and that further button presses are not longer recorded
    
    what_time = toc(timer); % check how much time has passed since last tic call
    if what_time >= 600 % in seconds - if above 10min then show RTs and pMF at end of this trial - indicated by performance flag
        performance_flag = 1;
    else
        performance_flag = 0;
        
    end
    
    %%%--- Display stimulus ---%%%
    f = 1; % frame counter
    
    %%% show fix dot to get ready
    
    Screen('DrawDots' , tconst.win , [0 0], size_org, S.black,...
        S.fixdotlocation, S.vp.dot_type);
    % display dots
    flipt=Screen('Flip', tconst.win, flipt+((1/tconst.framerate)*.7));
    
    
    WaitSecs(0.5); % fix dot is shown for 0.5secs 
    
    
    Fbcolour = [0 0 0]; % set fixdot colour to black as default in case no button has been pressed before flexfeedback time starts 
    %%%--- display stimulus for set trial time ---%%%
    
    
    %%% this needs to be the trial time allowed, either short or long
    %%% integration this while loop needs to stop when participant responded
    %%% and if stimulus time is over
    
    while f <= S.discrete_stim_duration_total + S.flex_feedback
        
        
        
        if f > S.discrete_stim_duration_total % if stim duration is exceeeded, show a grey screen with fixdot 
            
          
                
                   Screen('DrawDots' , tconst.win , [0 0], size_org, Fbcolour,...
            S.fixdotlocation, S.vp.dot_type);
          
              

        else % otherwise display dots
            
            % get trial start time on first coherent dot frame of trial
                      if f == 1
                
                tstart_incoh = GetSecs;
              
                
            elseif f == S.pre_incoh_mo + 1
                
                
                tstart = GetSecs;
                
            elseif f > S.pre_incoh_mo && f <= S.discrete_stim_duration_total && S.discrete_trials == 2
                
                size = size - px; 
          
                
            end
            
            
            % which feedback shape is shown based on response of
            % participant
            if respMat(trial,7) == 1 || respMat(trial,7) == 0 % if correct or incorrect response, fix dot turns either green or blue respectively.
                

                
                if training % display what feedback means
                    
                    if Fbcolour == S.green
                        text = 'correct';
                    else
                        text = 'incorrect';
                    end
    DrawFormattedText(tconst.win, text, S.fixdotlocation(1)-50,...
                S.fixdotlocation(2)-290, 0);
                end % training
                
                colour = Fbcolour; 
                
            elseif respMat(trial,7) == 2
   
                colour = Fbcolour; 
                if training % display what feedback means
                    
                    
                    text = 'too early';
    DrawFormattedText(tconst.win, text, S.fixdotlocation(1)-50,...
                S.fixdotlocation(2)-290, 0);
                end % training
                
                
            else % black fix dot if no response occured
                
                % Submit drawing instructions to PTB

                colour = S.black; 
                
            end% which feedback shape
            
            if size > 3
             Screen('Drawdots',tconst.win,[0 0],size,colour,S.fixdotlocation,S.vp.dot_type);
             
      
            end 
            % draw moving dots
            Screen('DrawDots' , tconst.win , S.xy{trial}(:,:,f), S.dotdiameter, S.black,...
                S.centre, S.vp.dot_type);
        end % if oiutside coherent motion
        
        
        % Set appropriate alpha blending for correct anti-aliasing of dots
        Screen (  'BlendFunction'  ,  tconst.win  ,  ...
            'GL_SRC_ALPHA'  ,  'GL_ONE_MINUS_SRC_ALPHA'  ) ;
        
        
        
        % display dots
        flipt=Screen('Flip', tconst.win, flipt+((1/tconst.framerate)*.7));
        
        
        
        % increase frame idx
        f = f+1;
        
        
     if keydown == 0
        % check wheter arrow key has been pressed
        [keyIsDown,firstpress] = KbQueueCheck(device_number(1));
        
     end
        
        if keyIsDown % flag, that indicates that key has been pressed and further button presses are not recorded anymore
            
            keydown = 1;
            
%             KbQueueStop;
            
        else
            keydown = 0;
        end % key is Down
        
        
        
        if keydown % if button has been pressed first time in trial, record response
            respMat(trial,6) = f;
            
            if f <= S.pre_incoh_mo
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                respMat(trial,4) = S.coherence_list(trial); % coherence of trial
                respMat(trial,7) = 2; % response made
                respMat(trial,1) = S.vp.point(3); % points lost
                
                respMat(trial,5) = 0; % too early is accounted for as wrong
                
                if firstpress(leftkey) % which key pressed
                    respMat(trial,2) = firstpress(leftkey)-tstart_incoh; % rt
                    respMat(trial,3) = 0; % choice as left
                elseif firstpress(rightkey)
                    respMat(trial,2) = firstpress(rightkey)-tstart_incoh; % rt
                    respMat(trial,3) = 1; % choice as left
                end % which key pressed
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                Fbcolour = S.yellow;
                keydown = 1;
                
            elseif respMat(trial,7) ~= 2 % in coherent motion period of trial
                
                respMat(trial,4) = S.coherence_list(trial); % coherence of trial
                
                if firstpress(leftkey) % if left arrow key has been pressed
                    
                    respMat(trial,3) = 0; % choice as left
                    respMat(trial,2) = firstpress(leftkey)-tstart; % rt
                    
                    if S.coherence_list(trial) < 0 % coherence < 0 = movement to left
                        
                        respMat(trial,5) = 1; % choice was correct
                        respMat(trial,7) = 1; % response made
                        respMat(trial,1) = S.vp.point(1); % points won
                        
                        Fbcolour = S.green; % feedback colour green fix dot
                        
                        
                    elseif S.coherence_list(trial) == 0 % randomly chose correct side
                        if rand(1,1) <= 0.5 % choose left side as correct side
                            
                            respMat(trial,5) = 1;
                            respMat(trial,7) = 1; % response made
                            respMat(trial,1) = S.vp.point(1);
                            
                            Fbcolour = S.green;
                            
                        else % randomly chosen right side as correct side
                            
                            respMat(trial,5) = 0;
                            respMat(trial,7) = 0; % response made
                            respMat(trial,1) = S.vp.point(2);
                            
                            Fbcolour = S.red;
                            
                        end % if rand < 0.5
                        
                    elseif S.coherence_list(trial) > 0 % coherence to the right
                        
                        respMat(trial,5) = 0;
                        respMat(trial,7) = 0; % response made
                        respMat(trial,1) = S.vp.point(2);
                        
                        Fbcolour = S.red;
                        
                        
                        
                    end % if movement to the left
                    
                    
                    
                    
                elseif firstpress(rightkey) % right arrow key has been pressed - same as above
                    
                    respMat(trial,3) = 1;
                    respMat(trial,2) = firstpress(rightkey)-tstart;
                    
                    if S.coherence_list(trial) < 0
                        
                        respMat(trial,5) = 0;
                        respMat(trial,7) = 0; % response made
                        respMat(trial,1) = S.vp.point(2);
                        
                        Fbcolour = S.red;
                        
                        
                    elseif S.coherence_list(trial) == 0 % randomly chose correct side
                        
                            respMat(trial,5) = 0;
                            respMat(trial,7) = 0; % response made
                            respMat(trial,1) = S.vp.point(2);
                            
                            Fbcolour = S.red;
                    
                        
                    elseif S.coherence_list(trial) > 0
                        
                        respMat(trial,5) = 1;
                        respMat(trial,7) = 1; % response made
                        respMat(trial,1) = S.vp.point(1);
                        
                        Fbcolour = S.green;
                        
                        
                        
                        
                    end % if coherence
                    
                    
                    
                    
                    
                    
                end % if left key
                
            end % if incoherent motion period or not
            
            
        end % if key is down
        
        
        % in case participant didnt make a response
        if keydown == 0 && f == (S.discrete_stim_duration_total + S.flex_feedback) && isnan(respMat(trial,7)) % last trial frame
            
            if S.coherence_list(trial) == 0 
                
                            respMat(trial,5) = 1;
                            respMat(trial,7) = 4; % response made
                            respMat(trial,1) = S.vp.point(1);
                            
                            Fbcolour = S.green;
                            
                
                
            else
            respMat(trial,6) = f;
            
            respMat(trial,1) = S.vp.point(4);
            respMat(trial,2) = S.discrete_stim_duration/tconst.framerate;
            respMat(trial,4) = S.coherence_list(trial);
            respMat(trial,5) = 0;
            respMat(trial,7) = 3; % response made
            
            Fbcolour = S.blue;
            
            end
        end
        
        
        
    end % while total num of frame is not reached
    
    
    
    
    %%% show feedback
    
    if rewardbar % show reweard bar if flag is 1
        S.totalPoints = S.totalPoints + respMat(trial,1); % calculate totalPoints,
        % previous one points plus points won on current trial, this determines how far rewardbar is filled
        
        % calculate rewardbar and how many pounds won
        [S.coins_counter,S.x_rect_old,text_reward,centeredRect,centeredFrame,centeredrewardRect,S.totalPoints,reward_m]...
            = moneybar(S.x_rect_old,S.coins_counter,S.rewbarsize,S.centre(1),...
            S.centre(2),S.ap_radius,S.totalPoints,S.totalPointsbar,respMat(trial,1),S.rewbarlocation);
        
        %%%% first half of feedback time show feedback and reward bar, with
        %%%% amount of points won in white at end of reward bar
        
        if S.totalPoints >= 0 % draw green reward bar, if participant has positive number of points
            Screen('FillRect',tconst.win,S.green, centeredRect); % display bar
            
        else % and red if noumber of total points won is negative
            Screen('FillRect',tconst.win,S.red, centeredRect); % display bar
            
        end
        
        if respMat(trial,1) > 0 
             Screen('FillRect',tconst.win,S.green, centeredrewardRect);
        else 
             Screen('FillRect',tconst.win,S.red, centeredrewardRect);
        end
        
        
        %Screen('FillRect',tconst.win,S.white, centeredrewardRect); % display bar
        
    end
    % draw black frame around reward bar
    Screen('FrameRect',tconst.win,S.black,centeredFrame,4); % display frame of bar
    DrawFormattedText(tconst.win, text_reward, S.centre(1)+round(S.rewbarsize(1)/2)+30,...
        S.rewbarlocation(2), 0);
    
  
    %display pounds won
    DrawFormattedText(tconst.win, text_reward, S.centre(1)+round(S.rewbarsize(1)/2)+30,...
       S.rewbarlocation(2), 0);
    
    
    
    
        
    
    % which feedback shape shown with reward bar at end of trial
    if respMat(trial,7) == 1 || respMat(trial,7) == 0 % fix dot changes colour as above
        

        if training
            
            if Fbcolour == S.green
                text = 'correct';
            else
                text = 'incorrect';
            end
    DrawFormattedText(tconst.win, text, S.fixdotlocation(1)-50,...
                S.fixdotlocation(2)-290, 0);
        end
        
    elseif respMat(trial,7) == 2 % response too early during incoh motion

        if training % display what feedback means
            
            
            text = 'too early';
            
            
    DrawFormattedText(tconst.win, text, S.fixdotlocation(1)-50,...
                S.fixdotlocation(2)-290, 0);
        end % training
        
    elseif respMat(trial,7) == 3 % if no response recorded show a red triangle
        
Fbcolour = S.blue; 
        
        if training
            text = 'missed';
    DrawFormattedText(tconst.win, text, S.fixdotlocation(1)-50,...
                S.fixdotlocation(2)-290, 0);
        end
    end % which feedback shape
    
    % display dots
            Screen('DrawDots' , tconst.win , [0 0], size_org, Fbcolour,...
            S.fixdotlocation, S.vp.dot_type);
        
    flipt=Screen('Flip', tconst.win, flipt+(0.5 * S.vp.feedback_duration));
    
    %%% show grey screen
    
    DrawFormattedText(tconst.win, '', 'center', 'center', 0);
    
    % display screen
    flipt=Screen('Flip', tconst.win, flipt+(0.5.*S.vp.feedback_duration));
    
    WaitSecs(1);
    
    
    if performance_flag % if 10min since last tic call have passed, break
        
        
        DrawFormattedText(tconst.win, 'Please take a break!', 'center', 'center', 0);
        flipt=Screen('Flip', tconst.win);
        WaitSecs(1);
        
        % save behavioural data so far
        savePath = fullfile(outdir,outfile);
        save(savePath,'respMat','S','tconst');
        
        % save info about current amount of £ won and how far rewardbar is
        % filled
        reward_matrix(1,:) = reward_m;
        
%         filename = sprintf('sub%03.0f_reward_info.mat',S.vp.subid); %updated filename ouf output
        savePath = fullfile(outdir, reward_file);
        save(savePath,'reward_matrix');
        
        Screen('CloseAll') % close PTB screen
        
        % display psychometric function and rt ditribution
        rt_choice_cohlevel_correct = respMat; % copy of behaviour
        
        % get performance info needed
        rt_choice_cohlevel_correct = rt_choice_cohlevel_correct(:,2:7);
        
        % remove frame col
        rt_choice_cohlevel_correct(:,5) = [];
        
        % remove nan trials
        rt_choice_cohlevel_correct = rt_choice_cohlevel_correct(~isnan(rt_choice_cohlevel_correct(:,2)),:);
        
        % plot PMF and RTs
        PMF_RT_Plots(rt_choice_cohlevel_correct,1,0);
        
        % determine whether to continue with session or not
        answer = '';
        while isempty(answer) %to validate input
            prompt = 'Do you want to continue with the current session? y/n: ';
            answer = input(prompt,'s');
            
            switch answer
                
                case 'y' % continue with session
                    if S.debug == 1
                        [tconst.win,tconst.rect]= PsychImaging('OpenWindow',...
                            tconst.winptr,S.grey,[0 0 1048 786]);
                        
                        
                        
                    else % use full screen window
                        [tconst.win,tconst.rect]= PsychImaging('OpenWindow',...
                            tconst.winptr, S.grey);
                        
                    end
                    timer = tic;
                    % make PTB priority again
                    topPriorityLevel = MaxPriority(tconst.win);
                    Priority(topPriorityLevel);
                    
                case 'n' % close session
                    
                    return;
                    
                otherwise
                    
                    answer = '';
            end % switch answer
        end % while loop
    end % if performance flag
    
    
    
    KbQueueFlush(device_number(1));
    KbQueueStop;
    
    
    
    
end %%% loop through trials

%%%%% show feedback after last trial

%%% show performance and total pounds/points earned
performance = (sum(respMat(~isnan(respMat(:,5)),5))/S.vp.totaltrials) .* 100;
feedback_block = ['Well done! \n', num2str(performance),' % correct \n \n You have earned ',...
    num2str(S.coins_counter),' £'];

DrawFormattedText(tconst.win, feedback_block, 'center', 'center', 0);
Screen('Flip', tconst.win, flipt);
WaitSecs(4);


% save reward related info
reward_matrix(1,:) = reward_m;

savePath = fullfile(outdir,reward_file);
save(savePath,'reward_matrix');

% after all blocks finished save response data, and S and tconst structs
savePath = fullfile(outdir,outfile);
save(savePath,'respMat','S','tconst');

sca

% display psychometric function and rt ditribution
rt_choice_cohlevel_correct = [respMat(:,2),respMat(:,3),respMat(:,4),respMat(:,5),respMat(:,7)];

rt_choice_cohlevel_correct = rt_choice_cohlevel_correct(~isnan(rt_choice_cohlevel_correct(:,2)),:);
PMF_RT_Plots(rt_choice_cohlevel_correct,1,0);



end % function discrete trials

