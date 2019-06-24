sess = 177; 

for i = 1:100
    
    [S] = create_stimuli('parameter.xls',2,sess,0,1,0,0);
    
    for l = 1:4
    length_block(i,l) = length(S.coherence_frame_org{l}); 
    end 
    
    sess = sess + 1; 
end 

%% testing to draw circle 


Screen('Preference', 'SkipSyncTests',1);
PsychDefaultSetup(2);
screens = Screen('Screens');

% get correct screen number for screen on which we want to show task
tconst.winptr = max(screens);


    [tconst.win,tconst.rect]= PsychImaging('OpenWindow', tconst.winptr,[0.5 0.5 0.5],[0 0 1048 786]);
     tconst.framerate = Screen('FrameRate',tconst.win); % get frame rate and open small window
     
     [S.centre_x, S.centre_y] = RectCenter(tconst.rect);
     
     
     rect = [S.centre_x S.centre_y 2096 1572]; 
     
     Screen('FillOval', tconst.win, [1 1 1],rect, 10) 
     
      flipt=Screen('Flip', tconst.win);
      
      
      