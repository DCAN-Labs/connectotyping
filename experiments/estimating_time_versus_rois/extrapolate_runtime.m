M = readmatrix('rois_versus_time.csv');
T = array2table(M);
T.Properties.VariableNames = {'roi_count' 'time_in_seconds' 'parfor_model_tsvd'};
roi_count = M(:, 1);
time_in_seconds = M(:, 3);

plot(roi_count, time_in_seconds, 'o','DisplayName','Actual runtimes')

[p, ~, mu] = polyfit(T.roi_count, T.time_in_seconds, 5);
bigger_rois = reshape([1024, 2048], [2, 1]);
size(bigger_rois)
size(roi_count)
extended_roi_count = [roi_count; bigger_rois];

f = polyval(p, roi_count, [], mu);
hold on
plot(roi_count, f,'DisplayName','Fitted polynomial runtimes')
title('Fitted polynomial of computation time')
xlabel('Number of ROIs') 
ylabel('Computation time (in seconds)') 
legend('Location', 'best')

hold off

polyval(p, [92000], [], mu)
