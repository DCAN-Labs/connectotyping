#include <stdio.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>
#include <time.h>

#include "run_svd.h"

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
  int i;
  int j;
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
    for (j = 0; j < cols; j++){
      printf("%f ", gsl_vector_get(M, j));
    }
  printf("\n");
}

int run_svd(const gsl_matrix * a) {
  gsl_matrix *aa;
  int m = a->size1;
  int n = a->size2;
  if (m >= n) {
    aa = gsl_matrix_alloc(m, n);
    gsl_matrix_memcpy(aa, a);
  } else {
    aa = gsl_matrix_alloc(n, m);
	// Need to transpose the input
    gsl_matrix_transpose_memcpy(aa, a);
  }

  m = aa->size2;
  gsl_matrix * V = gsl_matrix_alloc(m, m);
  gsl_vector * S = gsl_vector_alloc(m);
  gsl_vector * work = gsl_vector_alloc(m);

  /**
   * On output the matrix A is replaced by U. The diagonal elements of 
   * the singular value matrix S are stored in the vector S. The 
   * singular values are non-negative and form a non-increasing sequence 
   * from S_1 to S_N. The matrix V contains the elements of V in 
   * untransposed form. To form the product U S V^T it is necessary to 
   * take the transpose of V. A workspace of length N is required in 
   * work.
   */
  gsl_linalg_SV_decomp(aa, V, S, work);
  printf("U:\n");
  pretty_print(aa);
  printf("S:\n");
  pretty_print_vector(S);
  printf("V:\n");
  pretty_print(V);

  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);

  return 0;
}
