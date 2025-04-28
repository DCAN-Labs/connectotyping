function save_group_covM(path_surv_txt,...
    path_standard,...
    local_parcel_string,...
    path_timecourses,...
    this_mask)

%% count survivors

n=size(this_mask,1);

%% Read covariances
% scout cov for size
j=1;
local_path_timecourses=path_timecourses{j};
local_mask=this_mask(j);
scout_C=get_covariance(local_path_timecourses,'path_mask',local_mask);
C=nan(size(scout_C,1),size(scout_C,1),n);
C(:,:,j)=scout_C;
for j=2:n
    C(:,:,j)=get_covariance(local_path_timecourses,'path_mask',local_mask);
    j
end

%% Define path to save 

[filepath,name,ext] = fileparts(path_surv_txt);
N=unique(cellfun(@sum,this_mask));

root_path=path_standard;
depth=1;
string_to_match=[name filesep local_parcel_string filesep '*' num2str(N) '*'];
list=get_path_to_file(root_path,depth,string_to_match);
list=char(list);

old='standard';
new='covariance';
fullFilename = strrep(list,old,new);

old='fconn_';
new='cov_';
fullFilename = strrep(fullFilename,old,new);
%% Make folder if does not exist

[filepath,name,ext] = fileparts(fullFilename);
if ~isdir(filepath)
    mkdir(filepath)
end
%% save

save_planB(fullFilename,C);
