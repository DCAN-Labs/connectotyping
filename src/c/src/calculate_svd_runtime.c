#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <gsl/gsl_matrix_double.h>
#include <gsl/gsl_linalg.h>

#include "../include/calculate_svd_runtime.h"
#include "../include/run_svd.h"

int calculate_svd_time(void) {
  clock_t start, end;
  double cpu_time_used;
  for (int i = 0; i < 12; i++) {
    for (int j = 0; j < 12; j++) {
      long m = 1 << i;
      long n = 1 << j;
      printf("m: %ld; n: %ld; \n", m, n);
      start = clock();
      gsl_matrix *mat = gsl_matrix_alloc(m, n);
      for (int ii = 0; ii < m; ii++) {
		  for (int jj = 0; jj < n; jj++) {
			  double x = (double) rand();
			  gsl_matrix_set(mat, i, j, x);
		  }
	  } 
      run_svd(mat);
      end = clock();
      cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
      printf("cpu_time_used: %f\n", cpu_time_used);
    }
  }

  return 0;
}
