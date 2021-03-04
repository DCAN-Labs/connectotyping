#include <stdio.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>
#include <time.h>

#include "../include/run_svd.h"

/*
  gsl_matrix_printf prints a matrix as a column vector.  This function
  prints a matrix in block form.
*/
void pretty_print(const gsl_matrix * M)
{
  // Get the dimension of the matrix.
  int rows = M->size1;
  int cols = M->size2;
  // Now print out the data in a square format.
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j++){
      printf("%f ", gsl_matrix_get(M, i, j));
    }
    printf("\n");
  }
  printf("\n");
}

int run_svd(const gsl_matrix * a) {
  // Need to transpose the input
  gsl_matrix *aa;
  int m = a->size1;
  int n = a->size2;
  if (m >= n) {
    aa = gsl_matrix_alloc(m, n);
    gsl_matrix_memcpy(aa, a);
  } else {
    aa = gsl_matrix_alloc(n, m);
    gsl_matrix_transpose_memcpy(aa, a);
  }

  m = aa->size2;
  gsl_matrix * V = gsl_matrix_alloc(m, m);
  gsl_vector * S = gsl_vector_alloc(m);
  gsl_vector * work = gsl_vector_alloc(m);

  gsl_linalg_SV_decomp(aa, V, S, work);

  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);

  return 0;
}
