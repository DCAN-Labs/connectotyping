M = readmatrix('rois_versus_time.csv');
[rowCount, colCount] = size(M);
mTest = M(1 : rowCount - 1, 1:4);
T = array2table(mTest);
T.Properties.VariableNames = {'roi_count' 'time_in_seconds' 'corr' 'svd'};
roi_count_to_predict = M(rowCount, 1);
actual_runtime = M(rowCount, 4);

least_error = realmax;
best_n = -1;
for n = 1 : 5
    [p, ~, mu] = polyfit(T.roi_count, T.time_in_seconds, n);
    predicted_val = polyval(p, roi_count_to_predict, [], mu);
    error = abs(actual_runtime - predicted_val);
    if error < least_error
        least_error = error;
        best_n = n;
    end
end
disp(best_n);
