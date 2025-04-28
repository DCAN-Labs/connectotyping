function C =get_covariance(path_timecourses,varargin)


% Define default options
options = [];
user_provided_options_flag=0;

path_mask_flag=0;

output_folder_mask=0;

n_ar=5;
%% Read extra options, if provided

v = length(varargin);
q=1;
while q<=v
    switch (varargin{q})
        
        case 'path_mask'
            path_mask=varargin{q+1};
            path_mask_flag=1;
            q = q+1;
            
        case 'output_folder'
            output_folder=varargin{q+1};
            output_folder_mask=1;
            q = q+1;
            
        case 'options'
            user_provided_options_flag=1;
            options=varargin{q+1};
            q = q+1;
            
        case 'n_ar'
            n_ar=varargin{q+1};
            q = q+1;
            
        otherwise
            disp(['Unknown option ',varargin{q}])
    end
    q = q+1;
end
user_provided_options_flag=user_provided_options_flag==1;
path_mask_flag=path_mask_flag==1;
output_folder_mask=output_folder_mask==1;
%% Load timeseries
% path_imaging='C:\Users\oscar\Box\UCDavis_conData\output_GUI_env\connectotyping\Functional\path_sbj_MCMethod_power_2014_FD_only_FD_th_0_40_min_frames_130_skip_frames_5_TRseconds_2_30\BezginRM2008_timeseries.ptseries\fconn_384_frames.mat';
% path_timecourses='C:\Users\oscar\OneDrive\matlab_code\GUI_environments\data\anonymized_human\fake_ID_01\fake_visit_1\func\fake_ID_01_fake_visit_1_task-rest_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.ptseries.nii';

% timecourses = cifti2mat(path_timecourses);
timecourses = load_imaging_data(path_timecourses);

%% Load options

options=update_options(options);
options.params.cutoff=1;
options.params.lags=0;% use zero, to set n=0 as in eq 4 in the paper, otherwise you will include historical values in the model (one connectivity matrix per historical value)
options.params.autocorrelation=0; % to exclude self dependancies, since we have already take care of this. This makes the diagonal values equal to zero in the model
options.params.concurrent=1; % must be one to include the concurrent information
options.params.pass_th=0;
options.perc=[0.7 0.3]; % First argument is the partition size to calculate SV, second argument is the size of the test sample
options.rep_svd=10; % how many times to repeat the svd decomposition to maximize out of sample data predictions
options.rep_model=1; % if number of frames not empty, how many times recalculate the model based on the minimum required frames
inc_frames=[];
%% load mask

whos_mask=whos('path_mask');
switch whos_mask.class
    case 'cell'
        mask=path_mask{1};
end
mask=mask==1;

%% Load mask
% path_mask='C:\Users\oscar\OneDrive\matlab_code\GUI_environments\README\output_GUI_env\standard\Functional\all_dtseries_list_N_14_MCMethod_power_2014_FD_only_FD_th_0_20_min_frames_375_skip_frames_5_TRseconds_0_80\mask_as_csvs\fake_ID_01_fake_visit_1_N_frames_375.csv';
% if path_mask_flag
%     mask=csvread(path_mask);
% else
%     mask=ones(size(timecourses,2),1);
% end


%% Remove autocorrelations
y=timecourses';
TC_no_AC_LS=remove_autocorrelation(y,n_ar);

signal=TC_no_AC_LS; % pick the signal with no autocorrelation
local_mask=mask; % define mask from motion censoring
local_ix=find(local_mask(n_ar+1:end));
signal=signal(local_ix,:);
%% get covariance
C=cov(signal);
