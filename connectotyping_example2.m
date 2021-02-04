%% This code shows how to connectotype with 5 participants. 
% It calculates a model for each participant. Next, each model is used to
% predict each other participant, and finally displays distributions of
% predictions (self and others)
load TC.mat % Read the preprocessed data from 5 participants, no motion censoring
n_part=size(TC,2); %count the participants
%% Read parameters
y=TC{1}; % read first TC to determine TRs and ROIs
[TRs rois]=size(y);% count TRs and rois
m=zeros(rois,rois,n_part); %preallocate memory to save the models
TC_no_AC_LS=cell(n_part,1);%preallocate memory to save timecourses without autocorrelations
%% Define options to connectotype
n_ar=5;% indicate how many autoregressibe terms to remove

options.params.cutoff=1;
options.params.lags=0;% use zero, to set n=0 as in eq 4 in the paper, otherwise you will include historical values in the model (one connectivity matrix per historical value) 
options.params.autocorrelation=0; % to exclude self dependancies, since we have already take care of this. This makes the diagonal values equal to zero in the model
options.params.concurrent=1; % must be one to include the concurrent information
options.params.pass_th=0;
options.perc=[0.7 0.3]; % First argument is the partition size to calculate SV, second argument is the size of the test sample
options.rep_svd=10; % how many times to repeat the svd decomposition to maximize out of sample data predictions
options.rep_model=1; % if number of frames not empty, how many times recalculate the model based on the minimum required frames
inc_frames=[];

%% connectotype
myCluster = parcluster('local');
poolobj = parpool(myCluster.NumWorkers);
parfor i=1:n_part
    display(['Running participant ' num2str(i)])
    y=TC{i};
    TC_no_AC_LS{i}=remove_autocorrelation(y,n_ar);
   
    signal = TC_no_AC_LS{i}; % pick the signal with no autocorrelation
    frameSV(i).signal = signal;
    [SV, R]=model_tsvd(signal,options); %calculate the SVD
   
    frameSV(i).min_frames = size(signal, 1);
    frameSV(i).SV = SV;
end
delete(poolobj);

for i = 1 : n_part
    options.min_frames= frameSV(i).min_frames; %how many frames to include in the model
    options.SV = frameSV(i).SV; %assign SV to options
    signal = frameSV(i).signal;
    m(:,:,i) = make_model_tsvd(signal, options); % calculate the model
end

%% predict self and others (apply each model to all the participants)
R_mean=zeros(n_part); % to save average R
R_label=cell(n_part^2,1); % to save labels for boxplot

c=0;
for i=1:n_part %loop on participants
    for j=1:n_part % loop in model
        pred_TC=TC_no_AC_LS{i}*m(:,:,j)';
        R_mean(i,j)=mean(diag(corr(TC_no_AC_LS{i},pred_TC)));
        
        c=c+1; %counter to index the labels
        if i==j
            R_label{c}='Self'; %same model on same participant
        else
            R_label{c}='Others';% predicting other
        end
    end
end
        
%% Show boxplot self versus others
boxplot(R_mean(:),R_label)
ylabel('Average R')

