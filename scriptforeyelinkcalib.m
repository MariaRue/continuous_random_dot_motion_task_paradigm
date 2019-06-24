%% script for running internal eye calibration 

function [] = internal_eye_calibration(win,device_number,calib)

    
    % instructions for participant - button press leads to next display
    text = 'We will now calibrate the eyes for the task \n Press any key to move on';
    Screen('TextSize',win,25);
    Screen('TextStyle',win,1);
    DrawFormattedText(win, text, 'center', 'center', [0 0 0]);
    flipt=Screen('Flip', win);
    KbStrokeWait(device_number)
    
    rect_draw=Screen('Rect', win); % get window size - necessary? apparently this gives more accurate estimate of area of screen on which we can actually draw things
    
    text = 'Please follow the dot with your eyes';
    DrawFormattedText(win, text, 'center', 'center', [0 0 0]);
    flipt=Screen('Flip', win);
    KbStrokeWait(device_number)
    
    % Draw dots in different locations with 1.2s inbetween
    Screen('DrawDots', win, coord.fixdot, dotsize.calib, cl.black', rect(3:4)*.5, 1);
    flipt=Screen('Flip', win, flipt+1.2); % dot in center
    
    
    Screen('DrawDots', win, [rect_draw(1)+100, rect_draw(2)+100],dotsize.calib, cl.black', [0 0], 1); % left upper corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='left';
    eyelink_msg_calib(event);
    
    Screen('DrawDots', win, [rect_draw(1)+100, rect_draw(4)-100],dotsize.calib, cl.black', [0 0], 1); % left lower corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    Screen('DrawDots', win, [rect_draw(3)-100, rect_draw(4)-100],dotsize.calib, cl.black', [0 0], 1); % right lower corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='right';
    eyelink_msg_calib(event);
    
    Screen('DrawDots', win, [rect_draw(3)-100, rect_draw(2)+100],dotsize.calib, cl.black', [0 0], 1); % right upper corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    Screen('DrawDots', win, coord.sacc_targ(:,2), dotsize.calib, cl.black', rect(3:4)*.5, 1); % target on the right
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='taright';
    eyelink_msg_calib(event);
    
    Screen('DrawDots', win, [(rect_draw(3)/2), rect_draw(4)-100],dotsize.calib, cl.black', [0 0], 1); % bottom middle
    flipt=Screen('Flip', win, flipt+1.2);
    
    Screen('DrawDots', win, coord.sacc_targ(:,1), dotsize.calib, cl.black', rect(3:4)*.5, 1); % target on the left
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='taleft';
    eyelink_msg_calib(event);
    
    Screen('DrawDots', win, [(rect_draw(3)/2), rect_draw(2)+100],dotsize.calib, cl.black', [0 0], 1); % bottom middle
    flipt=Screen('Flip', win, flipt+1.2);
    
    % calibration finished, move on to main taks
    text = ['Thank you! We will move on to the task now!'];
    Screen('TextSize',win,25);
    Screen('TextStyle',win,1);
    DrawFormattedText(win, text, 'center', 'center', [0 0 0]);
    flipt=Screen('Flip', win, flipt+1.2);
    KbStrokeWait([device_number])
    
    
end