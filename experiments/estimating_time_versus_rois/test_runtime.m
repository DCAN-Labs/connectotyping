wd = '/panfs/roc/groups/4/miran045/reine097/projects/connectotyping/experiments/estimating_time_versus_rois';
cd(wd);
%% load y
load y;

%% get correlated data
N = 256; % change this number to redo synthetic correlated for data
while N < 2 * 92000
    n_rois = N;
    fake_y = scale_rois(y, n_rois);
    fake_y = fake_y';
    sz = size(fake_y);
    file_name = ['../../data/TC_in_', num2str(n_rois),  '_', num2str(sz(2)), '.csv' ];
    % Save the file.
    writematrix(fake_y, file_name) 
    tic
    [U,S,V] = svd(fake_y,'econ');
    endtime = toc;
    disp([num2str(n_rois), ', ', num2str(endtime)]);
    
    N = N * 2;
end
