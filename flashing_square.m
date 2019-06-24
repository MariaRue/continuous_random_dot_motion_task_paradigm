function flashing_square


flipt = Screen('Preference', 'SkipSyncTests',1);% 0 should be preferred but synch
%     % problems on mac prohibit that. Exact synchronization for EEG experiment
% end



PsychDefaultSetup(2);
screens = Screen('Screens');


% get correct screen number for screen on which we want to show task
tconst.winptr = max(screens);



% set up screen 
 [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr, [0.5 0.5 0.5]);
 
 % measure flip interval 
 tconst.flipint = Screen('GetFlipInterval',tconst.win);
 
 
 
 % get centre of screen 
 [S.centre_x, S.centre_y] = RectCenter(tconst.rect);
 
 
 % square for photo-diode in upperleft corner of screen 
S.square_diode_length = 60; % in pix 
S.square_diode_vector = [0 0 S.square_diode_length S.square_diode_length]; 
S.square_diode_centred = CenterRectOnPointd(S.square_diode_vector,S.centre_x, S.centre_y); 
S.square_diode_colour = [0 0 0];


keyisdown = 0; 
while keyisdown == 0
    
Screen('FillRect',tconst.win, abs(S.square_diode_colour), S.square_diode_centred);
Screen('Flip', tconst.win, flipt+(1-0.5) * tconst.flipint);
 

 S.square_diode_colour = abs(S.square_diode_colour)-1;
 
 
 keyisdown = KbCheck; 
     
end

sca

end