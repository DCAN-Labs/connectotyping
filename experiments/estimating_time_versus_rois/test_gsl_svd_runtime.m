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
    col_count = sz(2);
    file_name = ['../../data/TC_in_', num2str(n_rois),  '_', num2str(col_count), '.csv' ];
    % Read the file.
    fake_y = readmatrix(file_name);
 
    % [U,S,V] = svd_lapack(fake_y,'econ');
    A_data = fake_y(:);
    tic;
    [U, S, V] = gsl_svd(n_rois, col_count, A_data);
    endtime = toc;
 
    disp([num2str(n_rois), ', ', num2str(endtime)]);
    
    N = N * 2;
end
