%% Code to implement connectotyping, as described in:
% Miranda-Dominguez O, Mills BD, Carpenter SD, Grant KA, Kroenke CD, Nigg JT, Fair DA (2014) 
% Connectotyping: Model Based Fingerprinting of the Functional Connectome. PLoS One 9.

%% This code shows how to connectotype one single run
if ispc 
cd P:\code\development\utilities\connectotyping\xval_remove_autocorrelation
else 
cd /group_shares/PSYCH/code/development/utilities/connectotyping/xval_remove_autocorrelation/
end
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
lag_perc=[.7 .1];
options_remove_autocorrelation=[];
options_remove_autocorrelation=8;
options_remove_autocorrelation=struct;
options_remove_autocorrelation.perc_train_pred=[.8 .1];
options_remove_autocorrelation.n=[ ];
TC_no_AC_LS=remove_autocorrelation(y,options_remove_autocorrelation);
[TC_no_AC_LS, R,optimal_lag,R_mean_out]=remove_autocorrelation(y,options_remove_autocorrelation);
%% Example 1.1. Calculate the model and make predictions
signal=TC_no_AC_LS; % pick the signal with no autocorrelation
[SV, R]=model_tsvd(signal,options); %calculate the SVD
options.min_frames=size(signal,1); %how many frames to include in the model
options.SV=SV; %assign SV to options
model=make_model_tsvd(signal,options); % calculate the model

% Make predictions
pred_TC=signal*model';% predicting timecourses using the model | yes, model needs to be transposed here
R=corr(signal,pred_TC); % calculate correlation coefficient predicted and measured TC (without autocorrelation)
Rd=diag(R); %take the diagonal

subplot 211
plot(Rd) % show how good the prediccions are per ROI
xlabel('ROIs')
ylabel('R')
title('Correlations between predicted and observed time courses per ROI')

subplot 212
hist(Rd,21) % show how good the prediccions are per ROI
xlabel('ROIs')
ylabel('R')
title('Distributions of correlations between predicted and observed time courses per ROI')
%% Example 1.2, calculate the SV and model using fresh data
clear model
signal=TC_no_AC_LS; % pick the signal with no autocorrelation

% Make the partitions
n_TRs=size(signal,1);% Count how many TRs survivef
ix=randperm(n_TRs); % randomize the order 
fraction_model=0.9; % Define the fraction of TRs used to calculate the model
n_model=round(n_TRs*fraction_model); % count frames used to calculate the model
n_test=n_TRs-n_model; % count the frames used to test the predictions

ix_model=ix(1:n_model); % assign the random indices for modeling
ix_test=ix(n_model+1:end);% assign the random indices for test

signal_model=signal(ix_model,:); % assign the signal used for modeling
signal_test=signal(ix_test,:); % assign the signal used for test

% Calculate the SVD
[SV, R]=model_tsvd(signal_model,options); %calculate the SVD
options.min_frames=n_model; %how many frames to include in the model
options.SV=SV; %assign SV to options
% Once defined the SV to use per ROI, calculate the model
model=make_model_tsvd(signal_model,options); % calculate the model

% Make predictions
pred_TC=signal_test*model';% predicting timecourses using the model and fresh data (signal_test)| yes, model needs to be transposed here
R=corr(signal_test,pred_TC); % calculate correlation coefficient predicted and measured TC (without autocorrelation)
Rd=diag(R); %take the diagonal

subplot 211
plot(Rd) % show how good the prediccions are per ROI
xlabel('ROIs')
ylabel('R')
title('Correlations between predicted and observed time courses per ROI')

subplot 212
hist(Rd,21) % show how good the prediccions are per ROI
xlabel('ROIs')
ylabel('R')
title('Distributions of correlations between predicted and observed time courses per ROI')
