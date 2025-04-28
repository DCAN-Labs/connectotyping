#include "mex.h"
#include "lapacke.h"
#include <math.h>

/*
 * model_tsvd_core(TC_in, SV_vec)
 * - TC_in: [inc_frames x rois] input matrix
 * - SV_vec: [1 x rois] vector of #SV to keep per ROI
 * Output:
 * - model_out: [rois x rois]
 */

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
    double *TC_in = mxGetPr(prhs[0]);
    double *SV_vec = mxGetPr(prhs[1]);

    mwSize T = mxGetM(prhs[0]);  // time points
    mwSize R = mxGetN(prhs[0]);  // ROIs

    plhs[0] = mxCreateDoubleMatrix(R, R, mxREAL);
    double *model_out = mxGetPr(plhs[0]);

    // Temporary workspace
    double *A = mxMalloc(T * (R-1) * sizeof(double));
    double *y = mxMalloc(T * sizeof(double));

    double *S = mxMalloc((R-1) * sizeof(double));
    double *U = mxMalloc(T * (R-1) * sizeof(double));
    double *VT = mxMalloc((R-1) * (R-1) * sizeof(double));
    double *superb = mxMalloc((R-1) * sizeof(double));

    for (mwSize j = 0; j < R; j++) {
        // Build A = TC_in(:, mask~=j)
        mwSize col = 0;
        for (mwSize k = 0; k < R; k++) {
            if (k == j) continue;
            for (mwSize t = 0; t < T; t++) {
                A[t + T * col] = TC_in[t + T * k];
            }
            col++;
        }

        // y = TC_in(:,j)
        for (mwSize t = 0; t < T; t++) {
            y[t] = TC_in[t + T * j];
        }

        // Compute SVD of A (T x (R-1)) => U, S, VT
        LAPACKE_dgesvd(LAPACK_COL_MAJOR, 'S', 'S', T, R-1, A, T, S, U, T, VT, R-1, superb);

        mwSize sv_k = (mwSize)SV_vec[j];

        // Compute x_inv = V(:,1:k) * inv(S(1:k)) * U(:,1:k)' * y
        // x_inv = (R-1 x k) * (k x T) * (T x 1)
        double *x_inv = mxCalloc(R-1, sizeof(double));
        for (mwSize r = 0; r < R-1; r++) {
            for (mwSize s = 0; s < sv_k; s++) {
                double dot = 0.0;
                for (mwSize t = 0; t < T; t++) {
                    dot += U[t + T * s] * y[t];
                }
                x_inv[r] += VT[s + (R-1) * r] * (dot / S[s]);
            }
        }

        // Fill output model row for j
        mwSize out_idx = 0;
        for (mwSize k = 0; k < R; k++) {
            if (k == j) continue;
            model_out[j + R * k] = x_inv[out_idx++];
        }

        mxFree(x_inv);
    }

    mxFree(A); mxFree(y);
    mxFree(S); mxFree(U); mxFree(VT); mxFree(superb);
}
