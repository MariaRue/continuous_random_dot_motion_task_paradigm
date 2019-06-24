% load data 
addpath('/Users/maria/MATLAB-Drive/fieldtrip-master'); % fieldtrip tool box to analyse data 
addpath('/Users/maria/MATLAB-Drive/eeglab14_1_2b');
addpath('/Users/maria/Documents/data/data.continous_rdk/EEG_pilot/trigger_test/')
ft_defaults % start fieldtrip 

eeglab % start eeglab


%% try to read in events
% read in list with file names - list generated in terminal ls > ....txt,
% make sure only set files are in that list


 




 cfg                        = [];
 cfg.dataset                = 'trig7.set'; % your filename with file extension;
 cfg.trialdef.eventtype     = 'trigger'; 

 cfg.trialdef.eventvalue    = [11 24 25 26]; % your event values
 cfg.trialdef.prestim       = 0.5;  % before stimulation (sec), only use positive num

 cfg.trialdef.poststim      = 0.5; % after stimulation (sec) , only use positive num

cfg                         = ft_definetrial(cfg);
%%
data   = ft_preprocessing(cfg);
%% 
cfg = [];
cfg.resamplefs = 100;
data_down = ft_resampledata(cfg,data);
%% 
load sub000_sess293_behav.mat
%% 

sampleinfo = (data.sampleinfo(:,1) + 500)/(1000/60);

for i = 1:length(sampleinfo)
    if i > 1
diff_sample(i) = sampleinfo(i) - sampleinfo(1); 
    end

end

diff_sample = diff_sample(2:end);
trig_send = zeros(length(S.coherence_frame{1}),1);
trig_send(round(diff_sample)) = 1; 

%% 
% plotting triggers from S structre and when triggers send
triggers = S.trigger_vals{1}; 

trigger1 = triggers == 24;
trigger2 = triggers == 25;
trigger3 = triggers == 26;
trigger4 = triggers == 34;
trigger5 = triggers == 35;
trigger6 = triggers == 36; 

hold on; plot(S.coherence_frame{1})
plot(S.mean_coherence_org{1},'r');
plot(trigger1,'gx'); 
plot(trigger4,'gx');  
plot(trigger2,'kx'); 
plot(trigger5,'kx');
plot(trigger3,'yx');
plot(trigger6,'yx');

plot(trig_send,'md'); 


%% calculate timing difference between both 

trig = trigger1 + trigger2 + trigger3 + trigger4 + trigger5 + trigger6; 
 vec = 1:length(trig);
trigs = vec(trig(:,1)==1);

differ = trigs - diff_sample;

figure
plot(differ,'x'); 




