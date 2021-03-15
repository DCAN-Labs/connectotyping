/****************************************************************************
 * Paul Reiners
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_linalg.h>

#include "../include/run_svd.h"

void pretty_print(const gsl_matrix * M)
{
  // Get the dimension of the matrix.
  int rows = M->size1;
  printf("rows: %d\n", rows);
  int cols = M->size2;
  printf("rows: %d\n", cols);
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
  printf("\n");
}

void run_svd_example() {
  const size_t M = 4;
  const size_t N = 5;
  double A_data[] = {1.0, 0.0, 0.0, 0.0, 2.0,
                     0.0, 0.0, 3.0, 0.0, 0.0,
		     0.0, 0.0, 0.0, 0.0, 0.0,
                     0.0, 2.0, 0.0, 0.0, 0.0};
  run_svd(M, N, A_data);
}

void run_svd(const size_t M, const size_t N, double A_data[])
{
  gsl_matrix * B;
  gsl_matrix * V;
  gsl_vector * S;
  gsl_vector * work;
  if (N > M) {
    gsl_matrix_view A = gsl_matrix_view_array(A_data, M, N);
    B = gsl_matrix_alloc(N, M);
    V = gsl_matrix_alloc(M, M);
    S = gsl_vector_alloc(M);
    work = gsl_vector_alloc(M);

    gsl_matrix_transpose_memcpy(B, &A.matrix);
  } else {
    gsl_matrix_view A = gsl_matrix_view_array(A_data, M, N);
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
    printf("S:\n");
    pretty_print_vector(S);
    printf("V:\n");
    pretty_print(B);
  } else {
    printf("U:\n");
    pretty_print(B);
    printf("S:\n");
    pretty_print_vector(S);
    printf("V:\n");
    pretty_print(V);
  }
  gsl_matrix_free(B);
  gsl_matrix_free(V);
  gsl_vector_free(S);
  gsl_vector_free(work);
}
