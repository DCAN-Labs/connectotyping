# Profiling results

Profiling results are contained in 
[rois_versus_time.csv](estimating_time_versus_rois/rois_versus_time.csv),  
When the number of ROIs is less than or equal to 512, the `corr` method is 
the bottleneck; when the number of ROIs is 1024 or greater, the `svd` 
method is the bottleneck. This is also illustrated in this plot:

![plot of runtime](rois_v_computation_time.jpg)

By using `polyfit` on the first <i>n - 1</n> values and testing `polyval`
on the <i>n</i> value, we find that the computation time is linear in the 
number of ROIs.  However, this cannot be the case.  The complexity is in 
[<i>O(min(m * n^2, m & 2) * n)](https://mathoverflow.net/a/221216/33176).

The first step in optimizing the Connectotyping code is to replace the MATLAB
calls to `svd` with calls to the Gnu Scientific Library's (GSL) C implementation
of SVD.
