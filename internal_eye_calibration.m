function [flipt] = internal_eye_calibration(win,pixperdeg,centre,flipt)

% dotsize of calibration dot transformed from vis degrees to pixels, same
dotsize = 0.5 .* pixperdeg;

 rect_draw=Screen('Rect', win); % get window size - necessary? apparently this gives more accurate estimate of area of screen on which we can actually draw things
    
    % Draw dots in different locations with 1.2s inbetween
    Screen('DrawDots', win, centre, dotsize, [0 0 0], [0 0], 1);
    flipt=Screen('Flip', win, flipt+1.2); % dot in center
    
        event='centre';
               Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
    
    
    Screen('DrawDots', win, [rect_draw(1)+100, rect_draw(2)+100],dotsize, [0 0 0], [0 0], 1); % left upper corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='leftup';
               Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
       
    
    Screen('DrawDots', win, [rect_draw(1)+100, rect_draw(4)-100],dotsize, [0 0 0], [0 0], 1); % left lower corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    event = 'leftdo';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
          
    
    Screen('DrawDots', win, [rect_draw(3)-100, rect_draw(4)-100],dotsize, [0 0 0], [0 0], 1); % right lower corner
    flipt=Screen('Flip', win, flipt+1.2);
    
    event='right';
    
        event = 'rightdo';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
    
    
    Screen('DrawDots', win, [rect_draw(3)-100, rect_draw(2)+100],dotsize, [0 0 0], [0 0], 1); % right upper corner
    flipt=Screen('Flip', win, flipt+1.2);
    
           event = 'rightup';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
    
    
    Screen('DrawDots', win, [rect_draw(3)-100 (rect_draw(4)/2)], dotsize, [0 0 0], [0 0], 1); % target on the right
    flipt=Screen('Flip', win, flipt+1.2);
    
              event = 'rightmi';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
   
    
    Screen('DrawDots', win, [(rect_draw(3)/2), rect_draw(4)-100],dotsize, [0 0 0], [0 0], 1); % bottom middle
    flipt=Screen('Flip', win, flipt+1.2);
    
                     event = 'botmi';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
    
    Screen('DrawDots', win, [rect_draw(1)+100 (rect_draw(4)/2)], dotsize, [0 0 0],[0 0], 1); % target on the left
    flipt=Screen('Flip', win, flipt+1.2);
    
                 event = 'leftmi';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);
  
    
    Screen('DrawDots', win, [(rect_draw(3)/2), rect_draw(2)+100],dotsize, [0 0 0], [0 0], 1); % bottom middle
    flipt=Screen('Flip', win, flipt+1.2);
                         event = 'topmi';
                Eyelink('Message', event);
            Eyelink('Command', ['record_status_message ', event]);

    
end