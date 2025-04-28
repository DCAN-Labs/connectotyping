#include "mex.h"
#include <math.h>

// Dot product utility
double dot_product(double *a, double *b, size_t len) {
    double sum = 0.0;
    for (size_t i = 0; i < len; ++i)
        sum += a[i] * b[i];
    return sum;
}

// Correlation between two vectors
double corr(double *a, double *b, size_t len) {
    double mean_a = 0, mean_b = 0;
    for (size_t i = 0; i < len; ++i) {
        mean_a += a[i];
        mean_b += b[i];
    }
    mean_a /= len;
    mean_b /= len;

    double num = 0, den_a = 0, den_b = 0;
    for (size_t i = 0; i < len; ++i) {
        double da = a[i] - mean_a;
        double db = b[i] - mean_b;
        num += da * db;
        den_a += da * da;
        den_b += db * db;
    }
    return num / sqrt(den_a * den_b + 1e-12);
}

// Entry point
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    // Inputs
    double *U = mxGetPr(prhs[0]); // [n x r]
    double *S = mxGetPr(prhs[1]); // [r x r]
    double *V = mxGetPr(prhs[2]); // [p x r]
    double *y_train = mxGetPr(prhs[3]); // [n x 1]
    double *X_test = mxGetPr(prhs[4]); // [m x p]
    double *y_test = mxGetPr(prhs[5]); // [m x 1]
    mwSize n = mxGetM(prhs[0]);
    mwSize r = mxGetN(prhs[0]);
    mwSize p = mxGetM(prhs[2]);
    mwSize m = mxGetM(prhs[4]);

    // Output
    plhs[0] = mxCreateDoubleMatrix(r, 1, mxREAL);
    double *R = mxGetPr(plhs[0]);

    // Scratch arrays
    double *x_inv = mxCalloc(p * n, sizeof(double));
    double *coeffs = mxCalloc(p, sizeof(double));
    double *y_pred = mxCalloc(m, sizeof(double));

    for (size_t k = 0; k < r; ++k) {
        // x_inv += (V_k / S_kk) * U_k'
        double s_inv = 1.0 / S[k * r + k];

        for (size_t i = 0; i < p; ++i) {
            for (size_t j = 0; j < n; ++j) {
                x_inv[i * n + j] += V[i + k * p] * s_inv * U[j + k * n];
            }
        }

        // coeffs = x_inv * y_train
        for (size_t i = 0; i < p; ++i) {
            coeffs[i] = 0;
            for (size_t j = 0; j < n; ++j) {
                coeffs[i] += x_inv[i * n + j] * y_train[j];
            }
        }

        // y_pred = X_test * coeffs
        for (size_t i = 0; i < m; ++i) {
            y_pred[i] = 0;
            for (size_t j = 0; j < p; ++j) {
                y_pred[i] += X_test[i + j * m] * coeffs[j];
            }
        }

        // Compute correlation
        R[k] = corr(y_pred, y_test, m);
    }

    mxFree(x_inv);
    mxFree(coeffs);
    mxFree(y_pred);
}
