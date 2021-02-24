M = readmatrix('rois_versus_time.csv')
col1 = M(:, 1);
col2 = M(:, 2);
col3 = M(:, 3);
figure
plot(col1, col2,'DisplayName','Without parfor')
hold on 
plot(col1, col3,'DisplayName','With parfor in model_tsvd')
hold off
title('ROI count versus computation time')
xlabel('Number of ROIs') 
ylabel('Computation time (in seconds)') 
legend('Location', 'best')
