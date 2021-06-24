
p{1}='/group_shares/PSYCH/code/external/utilities/gifti-1.4';
p{2}='/group_shares/PSYCH/code/external/utilities/Matlab_CIFTI';
for i=1:length(p)
    addpath(genpath(p{i}));
end
%% Define the location of wb_command
path_wb_c='/usr/global/hcp_workbench/bin_linux64/wb_command'; %path to wb_command
%% Reading ciftis

cd /group_shares/PSYCH/code/development/utilities/connectotyping/xval_remove_autocorrelation/
% You can read label files (parcels like gordon), dense time courses,
% parcellated time courses, etc

% Define the file you would like to read
file_path='/group_shares/FAIR_LAB2/Projects/ADHD_HCP_biomarkers/external_data/HCP';
filename='205725_Gordon.clean.ptseries.nii';

file=[file_path '/' filename];


cii=ciftiopen(file,path_wb_c);
newcii=cii;
X=newcii.cdata;
whos X
%%
save(['/group_shares/PSYCH/code/development/utilities/connectotyping/xval_remove_autocorrelation/' filename '.mat'],'X');
