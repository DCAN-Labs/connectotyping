#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <gsl/gsl_matrix_double.h>
#include <gsl/gsl_linalg.h>

#include "../include/calculate_svd_from_file.h"

int calculate_svd_from_file(void) {
  FILE *fp = fopen("./data/my_data.csv", "r");
  if (fp == NULL) {
    perror("Unable to open file!");

    exit(1);
  }
  int m = 4;
  int n = 5;

  char chunk[128];

  const char s[2] = ",";
  int i = 0;
  int j = 0;
  gsl_matrix *mat = gsl_matrix_alloc(m, n);
  while (fgets(chunk, sizeof(chunk), fp) != NULL) {
    char *token;

    token = strtok(chunk, s);
    while (token != NULL) {
       double x = atof(token);
       gsl_matrix_set(mat, i, j, x);

       j = (j + 1) % n;
       if (j == 0) {
         i = (i + 1) % m;
       }

       token = strtok(NULL, s);
    }
  }
  printf("a_matrix\n");
  pretty_print(mat);

  int result = run_svd(mat);

  fclose(fp);

  return result;
}
