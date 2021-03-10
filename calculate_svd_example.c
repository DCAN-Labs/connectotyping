#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_linalg.h>

#include "run_svd.h"
#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
  const size_t M = 4;
  const size_t N = 5;
  double A_data[] = {
    1.0, 0.0, 0.0, 0.0, 2.0,
    0.0, 0.0, 3.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 2.0, 0.0, 0.0, 0.0 };
  gsl_matrix_view A = gsl_matrix_view_array(A_data, 4, 5);
  gsl_matrix * B = gsl_matrix_alloc(N, M);
  gsl_matrix * V = gsl_matrix_alloc(M, M);
  gsl_vector * S = gsl_vector_alloc(M);
  gsl_vector * work = gsl_vector_alloc(M);

  gsl_matrix_transpose_memcpy(B, &A.matrix);

  gsl_linalg_SV_decomp(B, V, S, work);

  printf("U:\n");
  pretty_print(V);

  printf("S:\n");
  pretty_print_vector(S);

  printf("V:\n");
  pretty_print(B);

  gsl_matrix_free(B);
  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);
}
