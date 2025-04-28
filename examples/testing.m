%% Define working directory

wd='/home/miran045/shared/projects/connectotyping/Experiments/time_dconn';
cd(wd)
fs= filesep;
addpath(genpath('/home/miran045/shared/projects/connectotyping/wip_repo/connectotyping'));

%%
tic
load TC.mat % Read the preprocessed data from 5 participants, (no motion censoring has been performed)
y=TC{2}; % pick data from  participant 1| here y's size is TR's x number of ROIS


% Define options to connectotype
n_ar=5;% indicate how many autoregressive terms to remove (m in equation 1 in the Connectotyping paper)

options.params.cutoff=1;
options.params.lags=0;% use zero, to set n=0 as in eq 4 in the paper, otherwise you will include historical values in the model (one connectivity matrix per historical value) 
options.params.autocorrelation=0; % to exclude self dependancies, since we have already take care of this. This makes the diagonal values equal to zero in the model
options.params.concurrent=1; % must be one to include the concurrent information
options.params.pass_th=0;
options.perc=[0.7 0.3]; % First argument is the partition size to calculate SV, second argument is the size of the test sample
options.rep_svd=10; % how many times to repeat the svd decomposition to maximize out of sample data predictions
options.rep_model=1; % if number of frames not empty, how many times recalculate the model based on the minimum required frames
inc_frames=[];
% Remove autocorrelations
TC_no_AC_LS=remove_autocorrelation(y,n_ar);

% Calculate the model and make predictions
signal=TC_no_AC_LS; % pick the signal with no autocorrelation
[SV, R]=model_tsvd(signal,options); %calculate the SVD
options.min_frames=size(signal,1); %how many frames to include in the model
options.SV=SV; %assign SV to options
model=make_model_tsvd(signal,options); % calculate the model

toc

%% Altered functions

tic
[SV, R]=model_tsvd_extended(signal,options); %calculate the SVD
options.min_frames=size(signal,1); %how many frames to include in the model
options.SV=SV; %assign SV to options
model=make_model_tsvd_extended(signal,options); % calculate the model
toc

%% Compile 
% mex /home/miran045/shared/projects/connectotyping/wip_repo/connectotyping/code/compute_svd_corr.c
% mex /home/miran045/shared/projects/connectotyping/wip_repo/connectotyping/code/model_tsvd_core.c -lmwlapack
%% Altered function with C plug in

tic
options2.perc=[0.7 0.3];
options2.rep_svd=10;
options2.use_mex= true;
options2.rep_model=1;
[SV, R]=model_tsvd_extended(signal,options2); %calculate the SVD
options2.min_frames=size(signal,1); %how many frames to include in the model
options2.SV=SV; %assign SV to options
model=make_model_tsvd_extended(signal,options2); % calculate the model
toc

%% Altered function with C plug in and log generation

tic
options3.perc=[0.7 0.3];
options3.rep_svd=10;
options3.use_mex= true;
options3.log_progress=true;
options3.rep_model=1;
[SV, R]=model_tsvd_extended(signal,options3); %calculate the SVD
options3.min_frames=size(signal,1); %how many frames to include in the model
options3.SV=SV; %assign SV to options
model=make_model_tsvd_extended(signal,options3); % calculate the model
toc