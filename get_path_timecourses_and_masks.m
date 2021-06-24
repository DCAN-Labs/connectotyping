function [path_timecourses,this_mask]=get_path_timecourses_and_masks(path_surv_txt,path_standard,parcel_string,path_BIDs_derivs)


%%
fs=filesep;

%% 
[filepath,name,ext] = fileparts(path_surv_txt);
%% Read mask

path_pask=[path_standard fs 'Functional' fs name fs 'frame_removal_mask.mat'];
load(path_pask);
ix=1;
if size(mask,2)==3
    ix=3;
end
this_mask=mask(:,ix);
%% Read subjects

list=importdata(path_surv_txt);
list=split(list,filesep);
ID=list(:,end-1);
visit=list(:,end);
n=size(ID,1);
%% read all the participants from BIDS
root_path=path_BIDs_derivs;
depth=3;
string_to_match=parcel_string;
list_all=get_path_to_file(root_path,depth,string_to_match);

%% string to match

%%
path_timecourses=cell(n,1);
for i=1:n
    ix1=contains(list_all,ID{i});
    ix2=contains(list_all,visit{i});
    ix=and(ix1,ix2);
    path_timecourses{i}=list_all{ix};
end
