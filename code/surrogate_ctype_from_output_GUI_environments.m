function surrogate_ctype_from_output_GUI_environments(path_parcellated_folder,n_ar,options)
%%
% % For testing, input arguments
% path_parcellated_folder='V:\FAIR_HORAK\Projects\Martina_RO1\standard\Functional\List_MCMethod_power_2014_FD_only_FD_th_0_30_min_frames_165_skip_frames_5_TRseconds_2_00\Gordon_subcortical';
% n_ar=5;
% options.params.cutoff=1;
% options.params.lags=0;% use zero, to set n=0 as in eq 4 in the paper, otherwise you will include historical values in the model (one connectivity matrix per historical value) 
% options.params.autocorrelation=0; % to exclude self dependancies, since we have already take care of this. This makes the diagonal values equal to zero in the model
% options.params.concurrent=1; % must be one to include the concurrent information
% options.params.pass_th=0;
% options.perc=[0.7 0.3]; % First argument is the partition size to calculate SV, second argument is the size of the test sample
% options.rep_svd=10; % how many times to repeat the svd decomposition to maximize out of sample data predictions
% options.rep_model=1; % if number of frames not empty, how many times recalculate the model based on the minimum required frames
% options.n_replicas=100;
% inc_frames=[];
%% Read provided path
f=filesep;
folders = split(path_parcellated_folder,f);
n_folders=size(folders,1);

%% Load mask
frame_removal_mask_filename='frame_removal_mask.mat';

frame_removal_mask_path=cat_folders(folders,n_folders-1);
frame_removal_mask_path=[frame_removal_mask_path f frame_removal_mask_filename];
load(frame_removal_mask_path)

%% Detect if preselected frames
n_mask=size(mask);

preselected_frames_flag=1;
if n_mask(2)==1
    preselected_frames_flag=0;
end
preselected_frames_flag=preselected_frames_flag==1;
%% Load raw timecourses
raw_timecourses_filename='raw_timecourses.mat';
frame_removal_mask_path=[path_parcellated_folder f raw_timecourses_filename];
load(frame_removal_mask_path)
%% Count participants
n_part=size(raw_tc,1); %count the participants
%% Read timecourses

TC=cell(n_part,1);
for i=1:n_part
    TC{i}=raw_tc{i};
    if preselected_frames_flag==1
    TC{i}=TC{i};
    end
end

%% Count ROIs
y=TC{1}; % read first TC to determine TRs and ROIs
[TRs rois]=size(y);% count TRs and rois
TC_no_AC_LS=cell(n_part,1);%preallocate memory to save timecourses without autocorrelations
nTRs=zeros(n_part,1);
%% Validate mask | old/new GUI_env

validated_mask=validate_mask(mask);
%% CAT timecourses
for i=1:n_part
    
    y=TC{i};
    TC_no_AC_LS{i}=remove_autocorrelation(y,n_ar);
    signal=TC_no_AC_LS{i}; % pick the signal with no autocorrelation
    local_mask=validated_mask{i}; % define mask from motion censoring
    local_ix=find(local_mask(n_ar+1:end));
    signal=signal(local_ix,:);
    TC_no_AC_LS{i}=signal;
    nTRs(i)=size(signal,1);
end
signal=cell2mat(TC_no_AC_LS);
nTRs=mean(nTRs);
%% cholsky decomposition
sigma=cov(signal);
C=chol(sigma);
%% to visualize covariance matrices | original and surrogated data
% R=normrnd(0,1,[rois,nTRs]);
% X=C'*R;
% X=X';
% %
% subplot 121
% imagesc(cov(X))
% colorbar
% subplot 122
% imagesc(sigma)
% colorbar
%% make connectotypes
n_replicas=options.n_replicas;
m=zeros(rois,rois,n_replicas); %preallocate memory to save the models
raw_tc=cell(n_replicas,1);
for i=1:n_replicas
    
    display(['Running participant ' num2str(i)])
    R=normrnd(0,1,[rois,nTRs]);
    X=C'*R;
    signal=X';
    raw_tc{i}=signal;
    [SV, R]=model_tsvd(signal,options); %calculate the SVD
    options.min_frames=size(signal,1); %how many frames to include in the model
    options.SV=SV; %assign SV to options
    m(:,:,i)=make_model_tsvd(signal,options); % calculate the model
end
fconn=m;
%% save

n_frames=numel(local_ix);
mask=validated_mask;
new_env='surrogate_connectotyping';
folders_to_save=folders;
folders_to_save{end-3}=new_env;

connectotyping_save_path=cat_folders(folders_to_save,n_folders);
mkdir(connectotyping_save_path)

save([connectotyping_save_path f raw_timecourses_filename],'raw_tc');
save([connectotyping_save_path f 'fconn_' num2str(n_frames) '_frames'],'fconn');

% frame_removal_mask_connectotyping_path=cat_folders(folders_to_save,n_folders-1);
% save([frame_removal_mask_connectotyping_path f frame_removal_mask_filename],'mask');