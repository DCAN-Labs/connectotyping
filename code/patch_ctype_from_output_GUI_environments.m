function patch_ctype_from_output_GUI_environments(path_parcellated_folder,n_ar,options,varargin)
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
% inc_frames=[];



%% Dirty patch
only_save_TC_no_AC_masked=0;% default 0
%% Read provided path
f=filesep;
folders = split(path_parcellated_folder,f);
n_folders=size(folders,1);

%% Load mask



frame_removal_mask_filename='frame_removal_mask.mat';

frame_removal_mask_path=cat_folders(folders,n_folders-1);
frame_removal_mask_path=[frame_removal_mask_path f frame_removal_mask_filename];
load(frame_removal_mask_path)
%% Define defaults

% Count frames to define defaults
frames_count=min(cellfun(@sum,mask));
[n_surviving_frames]=max(frames_count);
temp_ix=var(cellfun(@sum,mask))>0;
frames_count=num2cell(frames_count);
frames_count{temp_ix}='all';

%% Read extra options, if provided

v = length(varargin);
q=1;
while q<=v
    switch lower(varargin{q})
        
        case 'n_surviving_frames'
            n_surviving_frames=varargin{q+1};
            q = q+1;
            
            

        otherwise
            disp(['Unknown option ',varargin{q}])
    end
    q = q+1;
end

%% Find ix for n_surviving_frames
n_masks=numel(frames_count);
text1=n_surviving_frames;
if isnumeric(text1)
    text1=num2str(text1);
end
for i=1:n_masks
    text2=frames_count{i};
    if isnumeric(text2)
        text2=num2str(text2);
        frames_count{i}=text2;
    end
end
ix_n_surviving_frames=find(strcmp(frames_count,text1));
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
        TC{i}=TC{i}';
    end
end

%% Count ROIs
y=TC{1}; % read first TC to determine TRs and ROIs
[TRs rois]=size(y);% count TRs and rois
m=zeros(rois,rois,n_part); %preallocate memory to save the models
TC_no_AC_LS=cell(n_part,1);%preallocate memory to save timecourses without autocorrelations
TC_no_AC_masked=cell(n_part,1);%preallocate memory to save masked timecourses without autocorrelations
%% Validate mask | old/new GUI_env

% validated_mask=validate_mask(mask);
validated_mask=mask(:,ix_n_surviving_frames);
%% COnnectotype
include_subject= @(y) and(sum(isnan(y),[1 2])==0,sum(isinf(y),[1 2])==0);
%%
for i=1:n_part
    display(['Running participant ' num2str(i)])
    y=TC{i};
    if include_subject(y)
    TC_no_AC_LS{i}=remove_autocorrelation(y,n_ar);
    
    signal=TC_no_AC_LS{i}; % pick the signal with no autocorrelation
    local_mask=validated_mask{i}; % define mask from motion censoring
    local_ix=find(local_mask(n_ar+1:end));
    signal=signal(local_ix,:);
    
    TC_no_AC_masked{i}=signal;
    if only_save_TC_no_AC_masked==0
        try
            [SV, R]=model_tsvd(signal,options); %calculate the SVD
            options.min_frames=size(signal,1); %how many frames to include in the model
            options.SV=SV; %assign SV to options
            
            m(:,:,i)=make_model_tsvd(signal,options); % calculate the model
        catch
            m(:,:,i)=nan;
        end
    end
    else
        m(:,:,i)=nan;
        display(['Participant ' num2str(i) ' has nans or inf, hence co connectotyping is calculated'])
    end
end

fconn=m;
%% save

n_frames=numel(local_ix);
mask=validated_mask;
new_env='connectotyping';
folders_to_save=folders;
folders_to_save{end-3}=new_env;

connectotyping_save_path=cat_folders(folders_to_save,n_folders);
if only_save_TC_no_AC_masked==0
    mkdir(connectotyping_save_path)
    
    save([connectotyping_save_path f raw_timecourses_filename],'raw_tc');
    save([connectotyping_save_path f 'fconn_' num2str(n_frames) '_frames'],'fconn');
    
    frame_removal_mask_connectotyping_path=cat_folders(folders_to_save,n_folders-1);
    save([frame_removal_mask_connectotyping_path f frame_removal_mask_filename],'mask');
end

%%
TC_no_AC_masked_filename='TC_no_AC_masked.mat';
save([connectotyping_save_path f TC_no_AC_masked_filename],'TC_no_AC_masked');