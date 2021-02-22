%% Script to compare execution time of MATLAB code to generated MEX code
iter = 10;

load TC.mat % Read the preprocessed data from 5 participants, (no motion censoring has been performed)
y=TC{2}; % pick data from  participant 1| here y's size is TR's x number of ROIS


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
TC_no_AC_LS=remove_autocorrelation(y,n_ar);
%% Example 1.1. Calculate the model and make predictions
signal=TC_no_AC_LS; % pick the signal with no autocorrelation

%% Time MATLAB code
elTime = zeros(iter, 1);
for ii = 1 : iter
    tic
    [SV, R] = model_tsvd(signal, options); %calculate the SVD
    t = toc;
    elTime(ii) = t;
end
matTime = mean(elTime);
disp(['Mean MATLAB time is: ' num2str(matTime) ' seconds']);
