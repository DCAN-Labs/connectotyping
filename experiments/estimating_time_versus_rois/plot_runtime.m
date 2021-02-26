M = readmatrix('rois_versus_time.csv');
M = M(:, 1:4);
T = array2table(M);
T.Properties.VariableNames = {'roi_count' 'time_in_seconds' 'corr' 'svd'};
roi_count = M(:, 1);
time_in_seconds = M(:, 2);
corr_time = M(:, 3);
svd_time = M(:, 4);

plot(roi_count, time_in_seconds, 'DisplayName','Total runtime')
hold on
plot(roi_count, corr_time, 'DisplayName','corr')
plot(roi_count, svd_time, 'DisplayName','svd')
title('Computation time')
xlabel('Number of ROIs') 
ylabel('Computation time (in seconds)') 
legend('Location', 'best')

hold off
