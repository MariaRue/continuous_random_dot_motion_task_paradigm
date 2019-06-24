function [PMF_fit] = PMF_RT_Plots(rt_choice_cohlevel_correct_respID,logs,Gauss)

% returns parameter fits (mean, sd for cummulative gaussian PMF fitting, b0,
% b1 for logistic) for behaviour on random dot motion task and plots respective PMF as well as
% rts for correct and failed trials

% Input:
%  rt_choice_cohlevel_correct -  a matrix data with behavioural data with columns
%                                                       1 = rt
%                                                       2 = choice
%                                                       3 = coherence
%                                                       4 = choice correct

% logs, flag if 1 fit PMF with logistic function
% Gauss, flag if 1 fit PMF with gaussian function


% transform rts to exclude rts that a longer than 2.5 sds away from
% mean

% transform data into a gaussian distribution ( 1/rt could also be used)

data = rt_choice_cohlevel_correct_respID; % make copy of behavioural data matirx

if size(rt_choice_cohlevel_correct_respID,2) == 5
    
    data_rt = rt_choice_cohlevel_correct_respID; 
    
    % prepare data for rt and PMF correct/incorrect trials 
    idx_trial_incoh = data_rt(:,5) == 2;
    data_rt = data_rt(idx_trial_incoh,:); 
    
    [~,~,~,rt_incoh,coherences_incoh] = process_PMF_data(data_rt); 
    
    if sum(sum(isnan(rt_incoh))) == numel(rt_incoh)
        rt_incoh = [];
        
    end
    
    
end


data = data(~isnan(data(:,1)),:);



rt_norm = log(data(:,1)); % transform with log

% get the standard deviation
sd = std(rt_norm);

% indices of trials that are below 2 1/2 times of sd - these are the
% indices of the trials we wnat to keep
idx_rt_keep = rt_norm < (2.5 * sd);

% get the data with rts below 2.5 * sd
data_keep = data(idx_rt_keep,:);

% if data has 5 columns it has an identy column which tells us to
% distinguish between trials that have been to early, missed or during
% coherent motion in the continous motion task 
if size(data_keep,2) == 5

    % prepare data for rt and PMF correct/incorrect trials 
    idx_trial = data_keep(:,5) == 1 | data_keep(:,5) == 0; 
    data_keep = data_keep(idx_trial,1:4);
 

end % if data from continuous motin task

 % (info needed for Y for glmfit logistic fit and to plot rt and cohrences)
[percent_right,n,confidence_interval,rt,coherences] = process_PMF_data(data_keep); 

% get data info for plotting Rts and PMFs


% range over which we evaluate fitted PMF
xrange = -1 : 0.1 :1;





% fit PMF with GAussian or Logistic regression
if Gauss
    
    % how to calculate initial guesses?
    x0 = [1,1]; % initial guesses for mean(x0(1)) and sd (x0(2))
    
    options = optimset(); % set options to default value - for fminsearch function
    
    PMF_fit = fminsearch(@cum_Gauss_loglike,x0,options,data); % find mean/sd
    
    param.b0 = PMF_fit(1); %mean
    param.b1 = PMF_fit(2); %sd
    
    [p] = cum_Gauss_PMF(xrange,param,0); % calculate cummulative Gaussian values at each xrange value for plotting later on
    
elseif logs % fit logistic
    
    Y = [percent_right .* n ./100, n]; % first column number of rightward (CCW) choices for each stim, second column number of stim representations
    
    X = [ones(length(coherences),1),coherences]; % first column is constant, second column list with coherences
    
    PMF_fit = glmfit(X,Y,'binomial','link','logit','constant','off'); %logistic fit parameters
    
    % parameter input in logist_PMF function which calculates
    % values for each point in xrange for plotting
    param.b0 = PMF_fit(1);
    param.b1 = PMF_fit(2);
    
    %
    [p] = logist_PMF(xrange,param,0); %calculate fitted PMF for each point in xrange
    
end %if Gauss


%plot PMF
%         figure
figure
subplot(1,3,1)
hold on
plot(xrange,p.*100,'k-'); %plot fitted pmf
errorbar(coherences,percent_right,confidence_interval,'ko') %plot behav. data
hold off
ylim([0 100]);


%plot labels depending on rdk or cylinder task

xlabel('(leftward motion)              coherence            (rightward motion)')
ylabel('percentage rightward motion')



% title for GAuss or log
if Gauss
    title('PMF fitted with Gaussian', 'FontSize', 14);
    
else %log
    
    title('PMF fitted with logistic regression', 'FontSize', 14);
    
end %if Gauss title



%Plot Rts

%         figure % correct rts

subplot(1,3,2)
errorbar(coherences,rt(:,1),rt(:,2),rt(:,5),'ko-') % plot rts for correct trials
hold on
errorbar(coherences,rt(:,3),rt(:,4),rt(:,6),'rd-') % plot rts for incorrect trials 


hold off

%plot labels depending on rdk or cylinder task

xlabel('(leftward motion)              coherence            (rightward motion)')
ylabel('reaction time (s)')
title('RT correct/incorrect', 'FontSize', 14);
legend('correct choices', 'false choices')




if size(rt_choice_cohlevel_correct_respID,2) == 5 && ~isempty(rt_incoh) % plot times responded during incoherent motion 
subplot(1,3,3)
errorbar(coherences_incoh,rt_incoh(:,3),rt_incoh(:,4),rt_incoh(:,6),'gd-')


xlabel('(leftward motion)              coherence            (rightward motion)')
ylabel('reaction time (s)')
title('RT responses incoh motion discrete trials', 'FontSize', 14);




end


end %function






