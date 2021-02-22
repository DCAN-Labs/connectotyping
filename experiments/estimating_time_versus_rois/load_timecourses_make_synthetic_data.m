wd='/panfs/roc/groups/4/miran045/shared/projects/connectotyping/Experiments/estimating_time_versus_rois';
cd(wd)
%% load y
load y

%% get correlated data
n_rois=1000; % change this number to redo synthetic correlated data

fake_y=scale_rois(y,n_rois);
whos y fake_y