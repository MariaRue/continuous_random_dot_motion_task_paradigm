function [xy] = apply_vertical_motion(xy, mean_coh, mean_coh_sd, mean_freq, mean_freq_sd, mean_length, mean_length_sd, step, ap_radius);
%%% PURPOSE: This function modifies dot X-Y positions, by applying vertical
%%% motion (upwards or downwards) of varying speeds to a varying proportion
%%% of dots (cf. signal dots in coherent motion periods) for variable
%%% lengths of time, which occur at some mean frequency (which has an SD)

% INPUT:
%   xy:             2xNdxblock_length cell array, holding XY positions of
%                   all dots across all frames in the block
%                   *Dimensions:
%                       2: X and Y coordinate of each dot in each frame
%                       Nd: amount of dots (determined in parameter.csv)
%                       block_length: length of block *in frames*
%
% Neb: can we extract block_length from xy directly, or do we need to pass
%      it separately?
%
%   mean_coh:       proportion of dots you want to move vertically
%
%   mean_coh_sd:    the standard deviation of mean_coh
%
%   mean_freq:      mean frequency of vertical motion periods (as a *number
%                   per block*, e.g. if mean_freq == 5, then on average 
%                   there will be 5 vertical motion periods per block)
%                   
%   mean_freq_sd:   the standard deviation of mean_freq

%   mean_length:    mean length of vertical motion periods *in frames*

%   mean_length_sd: the standard deviation of mean_length

%   step:           speed of vertical movement *in pixels/frame*

%   ap_radius:      radius of aperture (used to return dots if they move
%                   out of annulus)
%        
% OUTPUT:
%   xy:             2xNdxblock_length array. Everything is exactly the same
%                   as input, except all dots have had their positions 
%                   modified *vertically* according to this function.

%% Pseudocode
% PASS: xy [2xNdxblock_length cell array], mean_freq, mean_freq_sq, mean_length,
% mean_length_sd, step)
% Create FRAME VECTOR (which is as long as the entire block)
% -> Create continuous "vertical motion periods" (from mean frequency, mean length and
%    relevant SDs passed to function)
% -> Assign these periods to frames in vector
% Frame-wise modify all xy Y cells (remember, only
% vertical motion!) which coincide to "vertical motion" frames in VECTOR by
% some amount STEP (passed to function)
% Fix dots which have moved outside of aperture (copy/pasted from
% move_dots scripts)
% RETURN: xy

%% Realcode
block_length = size(xy, 3); % get total number of frames in block
coherence = normrnd(mean_coh, mean_coh_sd); % get coherence for these VMPs
% disp(['Coherence: ' num2str(coherence)]);

frame_vector = zeros(1, block_length); % create initial frame vector

%%% CALCULATE VERTICAL MOTION PERIODS (VMPs)
% calculate amount of VMPs in this block (from distribution)
number_vmps = round(normrnd(mean_freq, mean_freq_sd));

vmp = zeros(number_vmps, 1); % preallocate vmp for speed
% calculate amount of ITIs (between VMPs)
iti = zeros(number_vmps+1, 1); % +1 because there is always an ITI at beginning

for i = 1:number_vmps
    % give each VMP a length sampled from a normal distribution
    vmp(i,1) = round(normrnd(mean_length, mean_length_sd)); 
end

% Determine ITI lengths
vmp_total_frames = sum(vmp(:, 1)); % sum of VMP lengths in frames
% determine mean ITI frame length
iti_mean_frames = round((block_length - vmp_total_frames)/size(iti, 1));
if iti_mean_frames <= 0
    disp('ERROR: init_mean_frames <= 0!');
    keyboard
elseif vmp_total_frames >= block_length
    disp('ERROR: vmp_total_Frames >= block_length!');
    keyboard
end

% Create each ITI with specific frame amount
for i = 1:size(iti, 1)
    length_decided = round(normrnd(iti_mean_frames, iti_mean_frames*.15)); 
    iti(i, 1) = iti(i, 1) + length_decided;
    if i ~= size(iti, 1) % unless we are on the last index...
        % add the excess or subtract the lack of frames (due to normrnd)
        % from our current ITI to the next one (if it exists). This helps
        % always balance (algebraically) the length of one ITI with the one
        % coming after it
        iti(i+1, 1) = iti(i+1, 1) + (length_decided - iti_mean_frames);
    end
end

first_frame = iti(1, 1) + 1; % determine first frame of first VMP

%%% ASSIGN VMPs TO FRAMES
for i = 1:number_vmps
    last_frame = first_frame + vmp(i, 1); % determine last frame of VMP
    % assign frames to vector, making them either upwards-moving (value 1)
    % or downwards-moving (value -1) w/ equal probability
    if randi(2) == 1 % going up
        frame_vector(1,first_frame:last_frame) = 1;
    else % going down
        frame_vector(1,first_frame:last_frame) = -1;
    end
    
    % assign first frame of next VMP (for next loop iteration)
    first_frame = last_frame + iti(i+1,1) + 1;
end

%%% MODIFY FRAME-WISE
% we now have frame_vector filled in, use that to change the Y values *of
% each dot* in xy

% The following is to determine which dots are signal dots (i.e. will
% move vertically when needed) - borrowed from move_dots.m, check it out

% create array of probabilities (0 to 1) with as many cells as dots
coh_prob = rand(1, size(xy, 2));
% create array of indices of signal dots
index_signal = find(coh_prob <= coherence);
% index_noise = coh_prob > coherence; % array of noise dots (i.e.
                                         % everybody else)

%%% MOVE DOTS %%%
for f = 4:block_length % for all frames (except initial three)
    % Neb: maybe can optimise above, so that somehow we only go through
    % all the frames where frame_vector is non-zero?
    xy(2,index_signal,f) = xy(2,index_signal,f-3) - (step * frame_vector(1,f) * 3); % change y pos
    % NB. frame_vector(1,f) = 0 for all frames w/o vertical motion, so
    % there will be no changes for those
    

    %%% REFLECT DOTS IF MOVED OUT OF APERTURE
    % borrowed and modified from move_dots.m
    % calculate distance to aperture centre
    distance_x_centre = sqrt(xy(1,index_signal,f).^2 + xy(2,index_signal,f).^2);

    % get array of signal dots that have a distance greater than the radius
    % meaning that they are outside the aperture
    idx_dist = index_signal(distance_x_centre >= ap_radius);
    if ~isempty(idx_dist) % if some have been found
        % replex y and x coordinates of the dots to a place on the opposite
        % site of the aperture
        
        % give them a random X coordinate
        xy(1,idx_dist,f) = 2 .* ap_radius .* rand(size(idx_dist)) - ap_radius;
        % give them a Y coordinate, such that they're on the edge of the annulus
        xy(2,idx_dist,f) = sqrt((ap_radius^2) - (xy(1,idx_dist,f).^2));
        
        % move signal dots back into aperture
        xy(2,idx_dist,f) = xy(2,idx_dist,f) - rand(size(idx_dist)) .* step .* 3;
        
        % needs to be mirrored if coherence is positive
        if frame_vector(1, f) < 0 % has to be > 0 (not < 0 or ~= 0) ???
            xy(2,idx_dist,f) = - xy(2,idx_dist,f);
        end
    end
end
end

%% additional functions
% xypos function - creates randomised x and y coordinates for n number of
% dots, for a given aperture radius r 
% Returns a 2xn double, with rows for x and y coordinates, and one column 
% for each dot
% Borrowed from move_dots.m

function [XY] = xypos(n, r)

% create random angle (in radians) for EACH dot
theta = 2*pi*rand(1,n);

% create random radius (in pixels) for EACH dot
radius = r * sqrt(rand(1,n));

% back to cartesian coordinate system
XY = [radius.*cos(theta); radius.*sin(theta)];

end %xypos