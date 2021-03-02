# Profiling results

Profiling results are contained in 
[rois_versus_time.csv](./rois_versus_time.csv).  When the number of ROIs is less than or equal to 512, the `corr` method is 
the bottleneck; when the number of ROIs is 1024 or greater, the `svd` 
method is the bottleneck. This is also illustrated in this plot:

![plot of runtime](rois_v_computation_time.jpg)

By using `polyfit` on the first <i>n - 1</i> values and testing `polyval`
on the <i>n</i>th value, we find that the computation time is linear in the 
number of ROIs.  Code determining this is in [*fit_runtime.m*](./fit_runtime.m).  However, this cannot be the case.  The complexity is in 
[<i>O(min(m * n^2, m^2 * n)</i>](https://mathoverflow.net/a/221216/33176).  (Our estimate that the time is linear is probably a result of our small sample size). 

The first step in optimizing the Connectotyping code is to replace the MATLAB
calls to `svd` with calls to the Gnu Scientific Library's (GSL) C implementation
of SVD.
