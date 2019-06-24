function fixpoint_display(shape,colour,size,win,centre)
% this function defines the shape and size of the fixdot during a session
% and whether correct incorrect behaviour occure i.e. correct butoon press,
% wrong button press, missed integration period, response during intertrial
% version 

% Input: 
% shape  = square(long ITI) or circle (short ITI) - S or C 
% size   = small (short integration period) or big (long integration period) - sm or b 
% these are given as either as smC, bC, smS, bS - for different conditions 

% colour  = green - correct button press during itegration period 
%           red   - incorrect button press during integration period
%           yellow - button press during ITI 
%           blue   - missed integration period 


switch shape
    
    case 'S' 
        
       Screen('FillRect',win,colour,size) 
        
    case 'C' 
        
       Screen('Drawdots',win,[0 0],size,colour,centre,2)
    
end 









