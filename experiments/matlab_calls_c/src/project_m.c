#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_linalg.h>

#include "mex.h"

void pretty_print(const gsl_matrix * M)
{
  // Get the dimension of the matrix.
  int rows = M->size1;
  int cols = M->size2;
  // Now print out the data in a square format.
  int i, j;
  for (i = 0; i < rows; i++){
    for (j = 0; j < cols; j++){
      printf("%f ", gsl_matrix_get(M, i, j));
    }
    printf("\n");
  }
  printf("\n");
}

void pretty_print_vector(const gsl_vector * M)
{
  int j;
  int cols = M->size;
  for(j = 0; j < cols; j++){
    printf("%f ", gsl_vector_get(M, j));
  }
  printf("\n\n");
}

void run_svd(const size_t M, const size_t N, double A_data[])
{
  gsl_matrix * B;
  gsl_matrix * V;
  gsl_vector * S;
  gsl_vector * work;
  gsl_matrix_view A = gsl_matrix_view_array(A_data, M, N);
  if (N > M) {
    B = gsl_matrix_alloc(N, M);
    V = gsl_matrix_alloc(M, M);
    S = gsl_vector_alloc(M);
    work = gsl_vector_alloc(M);

    gsl_matrix_transpose_memcpy(B, &A.matrix);
  } else {
    B = gsl_matrix_alloc(M, N);
    V = gsl_matrix_alloc(N, N);
    S = gsl_vector_alloc(N);
    work = gsl_vector_alloc(N);

    gsl_matrix_memcpy(B, &A.matrix);
  }

  gsl_linalg_SV_decomp(B, V, S, work);

  if (N > M) {
    printf("U:\n");
    pretty_print(V);
  } else {
    printf("U:\n");
    pretty_print(B);
  }
  printf("S:\n");
  pretty_print_vector(S);
  if (N > M) {
    printf("V:\n");
    pretty_print(B);
  } else {
    printf("V:\n");
    pretty_print(V);
  }
  gsl_matrix_free(B);
  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);
}

static double
get_double(const mxArray *array_ptr)
{
    double *pr;
    pr = mxGetPr(array_ptr);
    double result = (double) *pr;
    
    return result;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    printf("Entering mexFunction\n");
    printf("nlhs: $d\n", nlhs);
    printf("nlhs: $d\n", nrhs);
    int i;
    (void) nlhs;     /* unused parameters */
    (void) plhs;

    /* Check to see if we are on a platform that does not support the compatibility layer. */
    #if defined(_LP64) || defined (_WIN64)
        #ifdef MX_COMPAT_32
            for (i=0; i<nrhs; i++)  {
                if (mxIsSparse(prhs[i])) {
                    mexErrMsgIdAndTxt("MATLAB:explore:NoSparseCompat",
                    "MEX-files compiled on a 64-bit platform that use sparse array functions "
                    "need to be compiled using -largeArrayDims.");
                }
            }
        #endif
    #endif

    int m = (int) get_double(prhs[0]);
    printf("m: %d\n", m);
    int n = (int) get_double(prhs[1]);
    printf("n: %d\n", n);
    
    int row = 0;
    int col = 0;
    double *mexArray =  mxGetPr(prhs[2]);
    printf("A:\n");
    for (row = 0; row < m; row++) {
        for (col = 0; col < n; col++) {
            printf("%f ", mexArray[row * n + col]);
        }
        printf("\n");
    }
    printf("\n");
    
    run_svd(m, n, mexArray);
}
