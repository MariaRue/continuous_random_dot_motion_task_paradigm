function [total_points,money_counter,barfill,centre_barfill, centre_barfill_new]  = calculate_rewardbar(points_won, total_points, total_bar_points, money_per_bar, money_counter, barfill, bar_size, scr_centre, ap_radius,space_to_ap_radius)

% This function is for displaying a reward bar under the stimulus aperture
% which shows how money points and money has been won. Participants have to
% ill the bar to win money

% Input:
% points_won       = points won on current frame
% total_points     = total points since reward bar was filled last time
% total_bar_points = number of points to be collected that equal full rewardbar
% money_per_bar    = money won when bar filled once
% money_counter    = total money won across sessions
% barfill          = how far bar is currently filled
% bar_size         = size of reward bar (length x width) in pixels)
% scr_centre       = centre of screen to calculate coordinates of
%                    reward bar (x,y coordinates in pixel)
% ap_radius        = size of aperture to make sure reward bar appears
%                    below the stimulus
% space_to_ap_radius = space between aperture and rweard bar in pixels


% Output:
% total_points     = total points since reward bar was filled last time
% money_counter    = total money won across sessions updated by this
%                    round
% barfill          = how far bar is currently filled updated
% centre_barfill   = coordinates of complete bar fill for plotting
%                    with screen
% centre_barfill_new = cordinates of  bar fill amount that has been
%                      added for plotting with screen



%
barfill_new_val = 0;


barfill_new = points_won * (0.5 * bar_size(1)) / total_bar_points;


barfill = barfill + barfill_new;

if barfill < 0 && abs(barfill) > (bar_size(1)/2)  
    
    barfill = -(abs(barfill) - (bar_size(1)/2));
    
    total_points = total_points + points_won + total_bar_points;
    
    
    
    barfill_new = barfill;
    
    barfill_new_val = barfill/2; 
    
    
    money_counter = money_counter + money_per_bar;
    
elseif  barfill > 0 && barfill > (bar_size(1)/2) 
    
   
    
    
    barfill = barfill - (bar_size(1)/2);
    
    total_points = total_points + points_won - total_bar_points;
    
    
    
    barfill_new = barfill;
    
    barfill_new_val = barfill/2; 
    
    money_counter = money_counter + money_per_bar; 
    
elseif barfill >= 0  && barfill < (bar_size(1)/2) 
    
    total_points = total_points + points_won;
    
   
        
        barfill_new_val = barfill + (barfill_new/2);
        
    elseif barfill <= 0  && abs(barfill) <  (bar_size(1)/2) 
        
        barfill_new_val = barfill - (barfill_new/2);
        
        
   
    
    
end



barfill_rect = [0 0  abs(barfill)  bar_size(2)];

barfill_new_rect = [0 0 abs(barfill_new) bar_size(2)];


centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
    scr_centre(2) + ap_radius + space_to_ap_radius);


centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
    (barfill_new_val), ...
    scr_centre(2) + ap_radius + space_to_ap_radius);







%
% if total_points < 0
%
%
%     if points_won <= 0 && abs(total_points - points_won) - total_bar_points < 0
%         barfill = barfill + barfill_new;
%
%
%         barfill_rect = [0 0 barfill bar_size(2)];
%         barfill_new_rect  = [0 0 barfill_new bar_size(2)];
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%             (barfill - (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         total_points = total_points - abs(points_won);
%
%
%     elseif points_won < 0 && abs(total_points - abs(points_won)) >= total_bar_points
%
%         if total_bar_points < abs(total_points - abs(points_won))
%
%             barfill = (barfill + barfill_new) - (bar_size(1)/2);
%
%             barfill_rect = [0 0 barfill bar_size(2)];
%
%             barfill_new_rect = [0 0 barfill bar_size(2)];
%
%             centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%                 (barfill/2), ...
%                 scr_centre(2) + ap_radius + space_to_ap_radius);
%
%             barfill = 0;
%
%         else
%
%             barfill = bar_szie(1)/2;
%
%             barfill_rect = [0 0 barfill bar_size(2)];
%
%             barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%
%             centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%                 (barfill-(barfill_new/2)), ...
%                 scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         end
%
%
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%
%
%         money_counter = money_counter - money_per_bar;
%
%         total_points = (total_points - points_won) + total_bar_points;
%
%
%     elseif points_won > 0 && total_points + abs(points_won) < 0
%
%         barfill = barfill - barfill_new;
%
%         barfill_rect = [0 0 barfill bar_size(2)];
%
%         barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%             (barfill-(barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         total_points = total_points + abs(points_won);
%
%     elseif points_won > 0 && total_points + abs(points_won) > 0
%
%         barfill = abs(barfill - barfill_new);
%
%         barfill_rect = [0 0 barfill bar_size(2)];
%
%          centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_rect, scr_centre(1) + ...
%             (barfill/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%           total_points = total_points + abs(points_won);
%
%     end
%
% else
%
%     if points_won > 0 && total_points + abs(points_won) < total_bar_points
%
%
%         barfill = barfill + barfill_new;
%
%          barfill_rect = [0 0 barfill bar_size(2)];
%
%           barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%             centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             (barfill - (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         total_points = total_points + abs(points_won);
%
%     elseif points_won > 0 && total_points + abs(points_won) >= total_bar_points
%
%
%         if (total_points + abs(points_won)) == total_bar_points
%             barfill = barfill + barfill_new;
%
%           barfill_rect = [0 0 barfill bar_size(2)];
%
%           barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%                     centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             (barfill - (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         barfill = 0;
%
%         else
%
%             barfill = barfill + barfill_new;
%             barfill = barfill - (bar_size(1)/2);
%
%             barfill_new = barfill;
%
%           barfill_rect = [0 0 barfill bar_size(2)];
%
%           barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%
%                        centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             (barfill/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         end
%
%         total_points = total_points + abs(points_won) - total_bar_points;
%         money_counter = money_counter + money_per_bar;
%
%     elseif points_won < 0 && (total_points - abs(points_won)) > 0
%
%
%         barfill = barfill - barfill_new;
%
%         barfill_rect = [0 0 barfill bar_size(2)];
%
%           barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
%
%                        centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             (barfill + (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         total_points = total_points - abs(points_won);
%
%
%     elseif points_won < 0 && (total_points - abs(points_won)) < 0
%
%         barfill = abs(barfill - barfill_new);
%
%         barfill_rect = [0 0 barfill bar_size(2)];
%
%           barfill_new_rect = [0 0 barfill bar_size(2)];
%
%
%                            centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%             (barfill/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%         total_points = total_points - abs(points_won);
%
%     end
%
%
%
%
%
% end % total points
%
%















%
%
% total_points = total_points + points_won; % update total points won so far
% barfill_old = barfill;
% barfill_new = abs(points_won) * (0.5 * bar_size(1)) / total_bar_points;
%
%
% if total_points < 0
%     if points_won < 0
%         barfill = barfill + barfill_new;% needed for calculating postion of newly added feedback
%     else
%         barfill = barfill - barfill_new;
%     end
% else
%     if points_won < 0
%
%         barfill = barfill - barfill_new;
%     else
%
%         barfill = barfill + barfill_new;
%     end
% end
% fillflag = 0;
%
% % if abs(total_points) > total_bar_points
% if abs(barfill) > (bar_size(1)/2)
%     % barfill = (abs(total_points) - total_bar_points) .* (0.5 * bar_size(1)) / total_bar_points;
%     barfill = abs(barfill)-(bar_size(1)/2);
%     barfill_new = barfill;
%
%     if points_won < 0
%         money_counter = money_counter - money_per_bar;
%     else
%
%         money_counter = money_counter + money_per_bar;
%
%     end
%
%     barfill_old = 0;
%
%     fillflag = 1;
%
%     % elseif abs(total_points) == total_bar_points
% elseif abs(barfill) == (bar_size(1)/2)
%     barfill_new = abs(points_won) * (0.5 * bar_size(1)) / total_bar_points;
%     barfill = (0.5 * bar_size(1));
%
%     if points_won < 0
%         money_counter = money_counter - money_per_bar;
%     else
%
%         money_counter = money_counter + money_per_bar;
%
%     end
%
%
%     fillflag = 2;
%
%
%
%
%
%
% end
%
% % create variables for PTB
% barfill_rect = [0 0 barfill bar_size(2)];
% barfill_new_rect = [0 0 barfill_new bar_size(2)];
%
% % centre rect on screen
%
% if total_points >= 0
%     if points_won >= 0
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             barfill_old + (barfill_new/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%     else
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) + (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) + ...
%             (barfill_old - (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%     end
%
% elseif total_points < 0
%     if points_won >= 0
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%             (barfill_old - (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%     else
%
%         centre_barfill = CenterRectOnPointd(barfill_rect, scr_centre(1) - (barfill/2),...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%
%         centre_barfill_new = CenterRectOnPointd(barfill_new_rect, scr_centre(1) - ...
%             (barfill_old + (barfill_new/2)), ...
%             scr_centre(2) + ap_radius + space_to_ap_radius);
%
%     end
%
%
%
% end
%
% % if abs(total_points) > total_bar_points
% if fillflag == 1
%     total_points = 0;
%
%
%     % elseif abs(total_points) == total_bar_points
% elseif fillflag == 2
%     total_points = 0;
%     barfill = 0;
%
% end


end