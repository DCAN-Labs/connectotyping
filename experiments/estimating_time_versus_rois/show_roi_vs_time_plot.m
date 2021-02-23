M = readmatrix('rois_versus_time.csv')
col1 = M(:, 1);
col2 = M(:, 2);
figure
plot(col1, col2)
title('ROI count versus computation time')
xlabel('Number of ROIs') 
ylabel('Computation time (in seconds)') 
