wd='/panfs/roc/groups/4/miran045/shared/projects/connectotyping/Experiments/estimating_time_versus_rois';
cd(wd)
%% load y
load y

%% get correlated data
n_rois = 2048; % change this number to redo synthetic correlated data
for ii = 1:1
    fake_y=scale_rois(y,n_rois);
    whos y fake_y

    %% Define options to connectotype
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
    %% Remove autocorrelations
    TC_no_AC_LS=remove_autocorrelation(fake_y,n_ar);
    %% Example 1.1. Calculate the model and make predictions
    signal=TC_no_AC_LS; % pick the signal with no autocorrelation
    [SV, R]=model_tsvd(signal,options); %calculate the SVD
    options.min_frames=size(signal,1); %how many frames to include in the model
    options.SV=SV; %assign SV to options
    model=make_model_tsvd(signal,options); % calculate the model
end
