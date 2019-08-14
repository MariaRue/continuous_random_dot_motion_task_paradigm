function [coins_counter,x_rect_old,text,centeredRect,centeredFrame, centeredrewardRect,totalPoints,reward_matrix] = moneybar(x_rect_old,coins_counter,total_rect_x_size,xCenter,yCenter,ap_radius,totalPoints,totalPointsbar,p_won_cur_trial,location_bar, reward)
% PURPOSE: Calculates reward bar that indicates how many points have been
% won and to how many pounds this corresponds.
% The bar is always 500 pixels long. We always start to fill it in the
% centre. Rightwards fill indicates that the participant has earned points,
% a leftwards one mean he has lost points. Therefore, the participant has to 
% fill half a reward bar (250 pixels, which is set to 60points) to earn a
% preset unit of money (e.g. £0.40).
% The reward bar then 'resets', but carries over any "spillover" amount of
% points from filling the reward bar too much in the previous trial.
% Across sessions, this is done with totalPoints. Totalpoints gets updated
% each time the particpant makes a response, and determines how far the bar
% is filled by calculating the fraction of total points needed to earn the
% unit amount of money. If the bar is full, totalpoints is set to 0 again.

% Input: 
%   x_rect_old        = amount of pixels that points won on current trial 
%                         overshoots end of reward bar, needs to be added 
%                         to new reward bar
%   coins_counter     = counts pounds won, updated by a unit amount (see
%                         below) each time the bar is filled 
%   total_rect_size   = size of the bar in pixels 
%   xCenter, yCenter  = centre of the screen 
%   ap_radius         = size of aperture in which dots are displayed -
%                         needed so that we display reward bar below that 
%   totalPoints       = number of points won since last reward bar started 
%   totalPointsbar    = number of points that correspond to 250 pixel,
%                         needed to fill reward bar and to earn the reward 
%   reward            = amount of reward (units of money but currencyless)
%                         each time the reward bar is filled

% Output:
%   coins_counter = updated £ won on this trial
%   x_rect_old    = in case reward bar was filled up in this trial (see
%                     above in input)
%   centeredRect,
%   centeredFrame = coordinates for PTB to draw frame and bar on right
%                     location and in correct size 
%   centeredrewardRect = ???
%   totalPoints   = updated, see above in input 
%   reward_matrix = totalPoints and coins_counter saved in this for next
%                     session, in case this is last trial or last response
%                     in session

x_rect =  abs((totalPoints .* (total_rect_x_size(1)/2))/ (totalPointsbar)); % calculate length of reward bar filled
% rew_x_rect = (abs(p_won_cur_trial) .* (total_rect_x_size/2))/ (totalPointsbar);

if isnan(totalPoints)
    totalPoints = 0; % set it to 0 if it becomes NaN (plaster)
    disp('totalPoints was NaN, set to 0');
elseif isnan(coins_counter)
    coins_counter = 0; % set it to 0 if it becomes NaN (plaster)
    disp('coins_counter was NaN, set to 0');
end

if x_rect >= (total_rect_x_size(1)/2) % in case reward bar is full 
    % add reward amount of money
    if totalPoints < 0
        coins_counter = coins_counter - reward; 
    else
        coins_counter = coins_counter + reward; 
    end 
    % we need to calculate how much new bar would be filled and save that until next trial
    x_rect = abs(x_rect-(total_rect_x_size(1)/2)); % if bar is filled once then save the pixels that are over bar border 
    % now calculate how many points that would be 
    totalPoints = (totalPointsbar .* x_rect)/(total_rect_x_size(1)/2);
end

% display amoutn of £s already earned 
text = ['+',num2str(coins_counter),' £'];

% 
rew_x_rect = (p_won_cur_trial .* (total_rect_x_size(1)/2))/ (totalPointsbar);
baseRect = [0 0 x_rect total_rect_x_size(2)]; % defines how much of bar is filled
frameRect = [0 0 total_rect_x_size(1) total_rect_x_size(2)]; % defines black frame of reward bar
rewardRect =  [0 0 abs(rew_x_rect) total_rect_x_size(2)];    
% amount of points/won lost on current trial, which is first shown in white before it turns green or red
%centeredFrame = CenterRectOnPointd(frameRect, xCenter, yCenter + ap_radius + 40); % center frame on on screen
centeredFrame = CenterRectOnPointd(frameRect, location_bar(1),location_bar(2)); % center frame on on screen
% centeredrewardRect = CenterRectOnPointd(rewardRect, xCenter + (total_rect_x_size/2) + (1/2.* rew_x_rect), yCenter + ap_radius + 40); % center frame on on screen

if totalPoints >= 0 % center bar if participant has more than 0 points
    centeredRect = CenterRectOnPointd(baseRect, location_bar(1)+(1/2.*abs(x_rect)), location_bar(2)); % center bar on screen relative to frame of bar.
    % center of bar must be half of if its size away from left end of frame
    % of bar
    centeredrewardRect = CenterRectOnPointd(rewardRect, location_bar(1)+(abs(x_rect)) - ((1/2).* rew_x_rect), location_bar(2)); % center frame on on screen
else % center bar if total_points is negative
    centeredRect = CenterRectOnPointd(baseRect,location_bar(1)-(1/2.*abs(x_rect)), location_bar(2));
    centeredrewardRect = CenterRectOnPointd(rewardRect, location_bar(1) - abs(x_rect) - (1/2.* rew_x_rect), location_bar(2)); % center frame on on screen for number of points won on current trial
end % if total points is positive 

% save totalPoints and coins_counter in case this is last trial and needs
% to be transferred to next session 
reward_matrix = [totalPoints coins_counter];
end % function money bar 