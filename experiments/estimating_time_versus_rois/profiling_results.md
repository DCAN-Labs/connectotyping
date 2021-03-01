# Profiling results

Profiling results are contained in [rois_versus_time.csv](estimating_time_versus_rois/rois_versus_time.csv),  When the number of ROIs is less than or equal to 512, the `corr` method is the bottleneck; when the number of ROIs is 1024 or greater, the `svd` method is the bottleneck. This is also illustrated in [this plot](rois_v_computation_time.jpg). 
